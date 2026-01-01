const Order = require('../models/Order');

// =======================
// USER: PLACE ORDER (COD)
// =======================
exports.placeOrder = async (req, res) => {
  try {
    const order = await Order.create({
      user: req.user ? req.user._id : null, // ✅ FIX

      products: req.body.products,
      totalAmount: req.body.totalAmount,
      customerName: req.body.customerName,
      customerPhone: req.body.customerPhone,
      customerAddress: req.body.customerAddress,
    });

    res.status(201).json(order);
  } catch (error) {
    console.error('ORDER ERROR:', error);
    res.status(400).json({ message: error.message });
  }
};



// =======================
// ADMIN: GET ALL ORDERS
// =======================
exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate('products.product')
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user._id })
      .populate('products.product') // Corrected from productId to product
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


// =======================
// ADMIN: UPDATE ORDER STATUS
// =======================
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ message: 'Status is required' });
    }

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    order.status = status;
    await order.save(); // 🔥 IMPORTANT

    const populatedOrder = await Order.findById(order._id).populate(
      'products.product'
    );

    res.json({
      message: 'Order status updated successfully',
      order: populatedOrder,
    });
  } catch (error) {
    console.error('STATUS UPDATE ERROR:', error.message);
    res.status(500).json({ message: error.message });
  }
};
