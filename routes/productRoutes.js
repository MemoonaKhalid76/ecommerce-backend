const express = require('express');
const router = express.Router();

const {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct
} = require('../controllers/productController');

const { protectAdmin } = require('../middleware/adminAuth');

// PUBLIC
router.get('/products', getAllProducts);
router.get('/products/:id', getProductById);

const upload = require('../middleware/uploadMiddleware');

// ADMIN (JWT REQUIRED)
router.post('/products', protectAdmin, upload.array('images', 5), createProduct);
router.put('/products/:id', protectAdmin, upload.array('images', 5), updateProduct);
router.delete('/products/:id', protectAdmin, deleteProduct);

module.exports = router;
