const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// 📧 NODEMAILER CONFIG
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/* =========================
   HELPER: GENERATE OTP
========================= */
const generateOtp = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/* =========================
   REQUEST OTP
========================= */
exports.requestOtp = async (req, res) => {
  let otp; // Define otp outside try block for access in catch
  try {
    const { phone, email } = req.body;

    // 🛠️ TEST ACCOUNT BYPASS
    if (email === 'test@gmail.com') {
      const otp = '123456';
      const otpExpires = Date.now() + 5 * 60 * 1000;

      let user = await User.findOne({ email });
      if (!user) {
        user = await User.create({ email, otp, otpExpires });
      } else {
        user.otp = otp;
        user.otpExpires = otpExpires;
        await user.save();
      }

      return res.json({
        message: 'Test Account: Use OTP 123456'
      });
    }

    // For now, ENFORCE Email for OTP as SMS is not set up
    if (!email) {
      return res.status(400).json({
        message: 'Please provide an email address for OTP.',
      });
    }

    otp = generateOtp();
    const otpExpires = Date.now() + 5 * 60 * 1000; // 5 minutes

    // Upsert User
    let user = await User.findOne({ email });
    if (!user) {
      if (phone) {
        // If phone was passed but user found by email, or creating new
        user = await User.create({ phone, email, otp, otpExpires });
      } else {
        user = await User.create({ email, otp, otpExpires });
      }
    } else {
      user.otp = otp;
      user.otpExpires = otpExpires;
      if (phone) user.phone = phone; // Update phone if provided
      await user.save();
    }

    // 📧 SEND EMAIL
    const mailOptions = {
      from: '"Fareed Book Centre" <' + process.env.EMAIL_USER + '>',
      to: email,
      subject: 'Your Login OTP - Fareed Book Centre',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #333;">Login Verification</h2>
          <p>Your OTP code is:</p>
          <h1 style="color: #007bff; letter-spacing: 5px;">${otp}</h1>
          <p>This code expires in 5 minutes.</p>
          <p style="font-size: 12px; color: #888;">If you did not request this, please ignore this email.</p>
        </div>
      `,
    };

    // 🔥 LOG OTP TO CONSOLE (For debugging/dev if email fails)
    console.log(`\n🔑 DEV OTP for ${email}: ${otp}\n`);

    let emailSent = false;

    // Check if config looks plausible (App Passwords are usually 16 chars, definitely > 8)
    const hasValidConfig = process.env.EMAIL_USER &&
      process.env.EMAIL_PASS &&
      process.env.EMAIL_PASS.length > 8;

    if (hasValidConfig) {
      try {
        await transporter.sendMail(mailOptions);
        console.log(`📧 OTP email sent to ${email}`);
        emailSent = true;
      } catch (emailError) {
        console.error("❌ Email sending failed:", emailError.message);
        // Continue to return success with text fallback
      }
    } else {
      console.log("⚠️ Invalid Email Config detected (PASS too short or missing). Skipping email send.");
    }

    if (emailSent) {
      res.json({ message: 'OTP sent to your email.' });
    } else {
      // 🌍 CHECK ENVIRONMENT
      if (process.env.NODE_ENV === 'production') {
        // 🔒 PRODUCTION MODE: Secure! Never show OTP.
        return res.status(500).json({
          message: 'Email service failed. Please contact support.'
        });
      } else {
        // 🧪 DEV MODE: Helpful! Show OTP.
        res.json({
          message: `(DEV MODE) OTP is ${otp}. Use this to login.`
        });
      }
    }

  } catch (error) {
    console.error("Unexpected error in requestOtp:", error);
    res.status(500).json({
      message: 'Something went wrong. check console.'
    });
  }
};

/* =========================
   VERIFY OTP
========================= */
exports.verifyOtp = async (req, res) => {
  try {
    const { phone, email, otp } = req.body;

    const user = await User.findOne({
      $or: [{ phone }, { email }],
    });

    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    // 🔥 MAIN FIX IS HERE
    if (
      user.otp !== String(otp) ||   // ✅ STRING MATCH
      user.otpExpires < Date.now()
    ) {
      return res.status(400).json({
        message: 'Invalid or expired OTP',
      });
    }

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Clear OTP after success
    user.otp = null;
    user.otpExpires = null;
    await user.save();

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        phone: user.phone,
        email: user.email,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
