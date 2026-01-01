const Product = require('../models/Product');

// GET all products OR filtered products
exports.getAllProducts = async (req, res) => {
  try {
    const { category, subCategory } = req.query;

    let filter = {};
    if (category) filter.category = category;
    if (subCategory) filter.subCategory = subCategory;

    const products = await Product.find(filter);
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET single product
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ADMIN: Add product
exports.createProduct = async (req, res) => {
  try {
    let imagePaths = [];
    if (req.files && req.files.length > 0) {
      // Construct full URL for each image
      const protocol = req.protocol;
      const host = req.get('host');
      imagePaths = req.files.map(
        (file) => `${protocol}://${host}/uploads/${file.filename}`
      );
    }

    // ✅ HANDLE MANUAL IMAGE URLS (from text input)
    let manualImages = [];
    if (req.body.manualImages) {
      if (Array.isArray(req.body.manualImages)) {
        manualImages = req.body.manualImages;
      } else {
        manualImages = [req.body.manualImages]; // Convert single string to array
      }
    }

    // Merge both sources (Files + Manual URLs)
    const finalImages = [...imagePaths, ...manualImages].filter(img => img && img.trim() !== '');

    const productData = {
      ...req.body,
      image: finalImages // This array now contains both uploaded files and manual URLs
    };

    const product = await Product.create(productData);
    res.status(201).json(product);

  } catch (error) {
    console.error('CREATE PRODUCT ERROR:', error);
    res.status(400).json({ message: error.message });
  }
};



// ADMIN: Update product
exports.updateProduct = async (req, res) => {
  try {
    const updated = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.json(updated);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// ADMIN: Delete product
exports.deleteProduct = async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
