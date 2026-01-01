const express = require('express');
const router = express.Router();

const {
  registerAdmin,
  loginAdmin
} = require('../controllers/adminController');

router.post('/admin/register', registerAdmin);
router.post('/admin/login', loginAdmin);

module.exports = router;
