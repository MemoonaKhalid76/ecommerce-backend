const express = require('express');
const router = express.Router();

const {
  placeOrder,
  getAllOrders,
  getMyOrders,
  updateOrderStatus,
} = require('../controllers/orderController');

// 🔐 MIDDLEWARES
const { protectUser } = require('../middleware/userAuthMiddleware');
const { protectAdmin } = require('../middleware/authMiddleware');


// =========================
// 👤 USER ROUTES (PROTECTED)
// =========================

// 🔹 Place order (logged-in user only)
// Guest + User
const { optionalAuth } = require('../middleware/optionalAuthMiddleware');

// 🔹 Place order (Logged-in or Guest)
router.post('/orders', optionalAuth, placeOrder);

// User-only
router.get('/orders/my', protectUser, getMyOrders);




// =========================
// 🛠️ ADMIN ROUTES (PROTECTED)
// =========================

// 🔹 Get all orders (admin panel)
router.get('/orders', protectAdmin, getAllOrders);

// 🔹 Update order status (admin only)
router.put('/orders/:id/status', protectAdmin, updateOrderStatus);


module.exports = router;
