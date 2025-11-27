const express = require('express');
const router = express.Router();
const { 
  register, 
  login, 
  getMe, 
  checkUser,
  forgotPassword, 
  verifyOTP,
  resendOTP,
  resetPassword,
  verifyLeoId,
  googleSignIn
} = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth');

router.post('/register', register);
router.post('/login', login);
router.post('/check-user', checkUser);
router.get('/me', protect, getMe);
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOTP);
router.post('/resend-otp', resendOTP);
router.post('/reset-password', resetPassword);
router.post('/verify-leo-id', protect, verifyLeoId);
router.post('/google-signin', googleSignIn);

module.exports = router;
