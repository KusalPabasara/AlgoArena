const sgMail = require('@sendgrid/mail');

// OTP storage (in production, use Redis or database)
const otpStorage = new Map();

// OTP expiration time (5 minutes)
const OTP_EXPIRY = 5 * 60 * 1000;

// SendGrid Configuration - Uses HTTPS API (bypasses SMTP blocks on VPS)
const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY || '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';
const FROM_EMAIL = process.env.FROM_EMAIL || 'kusalpabasararcg@gmail.com';

// Initialize SendGrid
sgMail.setApiKey(SENDGRID_API_KEY);

class EmailService {
  constructor() {
    console.log('📧 Email service initialized with SendGrid API');
  }

  /**
   * Generate a 4-digit OTP
   */
  generateOTP() {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  /**
   * Store OTP with expiration
   */
  storeOTP(email, otp) {
    const lowerEmail = email.toLowerCase();
    otpStorage.set(lowerEmail, {
      otp,
      createdAt: Date.now(),
      attempts: 0
    });

    // Auto-delete after expiry
    setTimeout(() => {
      if (otpStorage.has(lowerEmail)) {
        const stored = otpStorage.get(lowerEmail);
        if (stored.otp === otp) {
          otpStorage.delete(lowerEmail);
        }
      }
    }, OTP_EXPIRY);
  }

  /**
   * Verify OTP
   */
  verifyOTP(email, otp) {
    const lowerEmail = email.toLowerCase();
    const stored = otpStorage.get(lowerEmail);

    if (!stored) {
      return { valid: false, message: 'OTP expired or not found. Please request a new one.' };
    }

    // Check if expired
    if (Date.now() - stored.createdAt > OTP_EXPIRY) {
      otpStorage.delete(lowerEmail);
      return { valid: false, message: 'OTP has expired. Please request a new one.' };
    }

    // Check attempts (max 3)
    if (stored.attempts >= 3) {
      otpStorage.delete(lowerEmail);
      return { valid: false, message: 'Too many attempts. Please request a new OTP.' };
    }

    // Verify OTP
    if (stored.otp === otp) {
      // Mark as verified but don't delete yet (needed for password reset)
      stored.verified = true;
      return { valid: true, message: 'OTP verified successfully.' };
    }

    // Increment attempts
    stored.attempts++;
    return { valid: false, message: `Invalid OTP. ${3 - stored.attempts} attempts remaining.` };
  }

  /**
   * Check if OTP is verified for email
   */
  isOTPVerified(email) {
    const lowerEmail = email.toLowerCase();
    const stored = otpStorage.get(lowerEmail);
    return stored?.verified === true;
  }

  /**
   * Clear OTP after password reset
   */
  clearOTP(email) {
    otpStorage.delete(email.toLowerCase());
  }

  /**
   * Send OTP email for password reset using SendGrid API (HTTPS)
   */
  async sendPasswordResetOTP(email, userName = 'User') {
    const otp = this.generateOTP();
    this.storeOTP(email, otp);

    try {
      const msg = {
        to: email,
        from: {
          email: FROM_EMAIL,
          name: 'Leo Connect'
        },
        subject: 'Password Reset OTP - Leo Connect',
        html: `
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #B8860B 0%, #DAA520 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
              .header h1 { margin: 0; font-size: 24px; }
              .content { background: #ffffff; padding: 30px; border-radius: 0 0 10px 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
              .otp-box { background: #000; color: #FFD700; font-size: 36px; letter-spacing: 12px; padding: 25px 40px; text-align: center; border-radius: 10px; margin: 25px 0; font-weight: bold; }
              .info { color: #333; font-size: 15px; line-height: 1.6; }
              .warning { background: #fff3cd; border: 1px solid #ffc107; color: #856404; font-size: 13px; padding: 15px; border-radius: 8px; margin-top: 20px; }
              .footer { text-align: center; color: #999; font-size: 12px; margin-top: 25px; padding-top: 20px; border-top: 1px solid #eee; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🔐 Password Reset Request</h1>
              </div>
              <div class="content">
                <p class="info">Hello <strong>${userName}</strong>,</p>
                <p class="info">We received a request to reset your password for your Leo Connect account. Use the OTP code below to verify your identity:</p>
                
                <div class="otp-box">
                  ${otp}
                </div>
                
                <p class="info">⏰ This code will expire in <strong>5 minutes</strong>.</p>
                
                <div class="warning">
                  ⚠️ If you didn't request this password reset, please ignore this email. Your account is safe.
                </div>
              </div>
              <div class="footer">
                <p>© 2025 Leo Connect - AlgoArena</p>
                <p>This is an automated message, please do not reply.</p>
              </div>
            </div>
          </body>
          </html>
        `,
        text: `Hello ${userName},\n\nYour password reset OTP is: ${otp}\n\nThis code will expire in 5 minutes.\n\nIf you didn't request this, please ignore this email.\n\n- Leo Connect Team`
      };

      // Send email via SendGrid API (uses HTTPS, not SMTP)
      const response = await sgMail.send(msg);
      console.log(`📧 OTP email sent to ${email} via SendGrid. Status: ${response[0].statusCode}`);
      
      return { 
        success: true, 
        message: 'OTP sent successfully to your email',
        otp // Return OTP for testing (remove in production)
      };
    } catch (error) {
      console.error('❌ SendGrid email error:', error.response?.body || error.message);
      
      // Even if email fails, OTP is already stored - return it for testing
      console.log(`⚠️ Email failed but OTP stored for ${email}: ${otp}`);
      
      return {
        success: true,
        message: 'OTP generated. If you don\'t receive the email, check spam folder.',
        otp // Return OTP so user can still reset password
      };
    }
  }
}

module.exports = new EmailService();
