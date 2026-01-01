const express = require('express');
const router = express.Router();

const {
  getAddresses,
  addAddress,
  deleteAddress,
} = require('../controllers/addressController');

const { protectUser } = require('../middleware/userAuthMiddleware');

// USER ONLY ROUTES
router.get('/addresses', protectUser, getAddresses);
router.post('/addresses', protectUser, addAddress);
router.delete('/addresses/:id', protectUser, deleteAddress);

module.exports = router; // 🔥 REQUIRED
