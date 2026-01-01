const jwt = require('jsonwebtoken');
const User = require('../models/User');

const optionalAuth = async (req, res, next) => {
  try {
    let token;

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = await User.findById(decoded.userId).select('-password');
    }

    next();
  } catch (error) {
    // If token invalid, just continue as guest (req.user remains undefined)
    console.log('Optional Auth: Token invalid or expired, proceeding as guest.');
    next();
  }
};

module.exports = { optionalAuth };
