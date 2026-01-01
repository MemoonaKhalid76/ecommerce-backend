const Admin = require('../models/Admin');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// =======================
// ADMIN REGISTER
// =======================
exports.registerAdmin = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password required' });
    }

    const adminExists = await Admin.findOne({ email });
    if (adminExists) {
      return res.status(400).json({ message: 'Admin already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const admin = await Admin.create({
      email,
      password: hashedPassword,
    });

    const token = jwt.sign(
      { id: admin._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'Admin registered successfully',
      token,
      adminId: admin._id,
    });

  } catch (error) {
    console.error('REGISTER ERROR:', error);
    next(error); // 👈 NOW next EXISTS
  }
};

// =======================
// ADMIN LOGIN
// =======================
exports.loginAdmin = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // 1️⃣ Validation
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required',
      });
    }

    // 2️⃣ Find admin
    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(401).json({
        message: 'Invalid email or password',
      });
    }

    // 3️⃣ Compare password
   console.log('LOGIN INPUT PASSWORD:', password);
console.log('DB PASSWORD:', admin.password);

const isMatch = await bcrypt.compare(password, admin.password);
console.log('COMPARE RESULT:', isMatch);

    if (!isMatch) {
      return res.status(401).json({
        message: 'Invalid email or password',
      });
    }

    // 4️⃣ Generate token
    const token = jwt.sign(
      { id: admin._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // 5️⃣ Response
    res.status(200).json({
      message: 'Login successful',
      token,
      admin: {
        id: admin._id,
        email: admin.email,
      },
    });

  } catch (error) {
    console.error('LOGIN ERROR:', error);
    next(error);
  }
};
