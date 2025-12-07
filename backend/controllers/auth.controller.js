const authService = require('../services/auth.service');
const firestoreService = require('../services/firestore.service');
const emailService = require('../services/email.service');

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res) => {
  try {
    const { fullName, email, password } = req.body;

    // Check if user exists in Firebase Auth
    const existingUser = await authService.getUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Create user in Firebase Auth
    const userRecord = await authService.createUser(email, password, fullName);

    // Create user document in Firestore with timestamps
    const now = new Date();
    const userData = {
      fullName,
      email,
      profilePhoto: null,
      bio: null,
      phoneNumber: null,
      clubId: null,
      districtId: null,
      role: 'member',
      isVerified: false,
      createdAt: now,
      updatedAt: now
    };

    await firestoreService.createWithId('users', userRecord.uid, userData);

    // Generate session token
    const token = authService.generateSessionToken(userRecord.uid, 'member');

    res.status(201).json({
      token,
      user: {
        id: userRecord.uid,
        fullName: userData.fullName,
        email: userData.email,
        profilePhoto: userData.profilePhoto,
        bio: userData.bio,
        phoneNumber: userData.phoneNumber,
        leoClub: userData.clubId,
        district: userData.districtId,
        role: userData.role,
        isVerified: userData.isVerified,
        createdAt: now.toISOString(),
        updatedAt: now.toISOString()
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    // Verify password using Firebase REST API
    let passwordVerification;
    try {
      passwordVerification = await authService.verifyPassword(email, password);
    } catch (error) {
      // If password verification fails, return 401
      return res.status(401).json({ message: error.message || 'Invalid credentials' });
    }

    // Get user by email from Firebase Auth
    const userRecord = await authService.getUserByEmail(email);
    if (!userRecord) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check if user is disabled
    if (userRecord.disabled) {
      return res.status(401).json({ message: 'This account has been disabled' });
    }

    // Get user data from Firestore
    const userData = await firestoreService.getById('users', userRecord.uid);
    if (!userData) {
      return res.status(401).json({ message: 'User data not found' });
    }

    // Update last login time
    await firestoreService.update('users', userRecord.uid, {
      lastLoginAt: new Date(),
      updatedAt: new Date()
    });

    // Generate session token
    const token = authService.generateSessionToken(userRecord.uid, userData.role || 'member');

    res.json({
      token,
      user: {
        id: userRecord.uid,
        fullName: userData.fullName,
        email: userData.email,
        profilePhoto: userData.profilePhoto || null,
        bio: userData.bio || null,
        phoneNumber: userData.phoneNumber || null,
        leoClub: userData.clubId || null,
        district: userData.districtId || null,
        leoId: userData.leoId || null,  // Include Leo ID if verified
        role: userData.role || 'member',
        isVerified: userData.isVerified || false,
        createdAt: userData.createdAt?._seconds 
          ? new Date(userData.createdAt._seconds * 1000).toISOString()
          : new Date().toISOString(),
        updatedAt: userData.updatedAt?._seconds
          ? new Date(userData.updatedAt._seconds * 1000).toISOString()
          : new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: error.message || 'Login failed' });
  }
};

// @desc    Check if user exists and get display info
// @route   POST /api/auth/check-user
// @access  Public
exports.checkUser = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    // Check if user exists in Firebase Auth
    const userRecord = await authService.getUserByEmail(email);
    
    if (!userRecord) {
      return res.status(404).json({ 
        exists: false,
        message: 'User not found' 
      });
    }

    // Get user data from Firestore
    const userData = await firestoreService.getById('users', userRecord.uid);

    res.json({
      exists: true,
      user: {
        fullName: userData?.fullName || userRecord.displayName || email.split('@')[0],
        email: userData?.email || userRecord.email,
        profilePhoto: userData?.profilePhoto || userRecord.photoURL || null,
      }
    });
  } catch (error) {
    console.error('Check user error:', error);
    // Return not found for any error (don't leak info about existing users)
    res.status(404).json({ 
      exists: false,
      message: 'User not found' 
    });
  }
};

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const userData = await firestoreService.getById('users', req.user.id);
    
    if (!userData) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Return user data in format expected by Flutter app
    res.json({
      id: req.user.id,
      fullName: userData.fullName,
      email: userData.email,
      profilePhoto: userData.profilePhoto || null,
      bio: userData.bio || null,
      phoneNumber: userData.phoneNumber || null,
      leoClub: userData.clubId || null,  // Flutter expects 'leoClub' as string ID
      district: userData.districtId || null,  // Flutter expects 'district' as string ID
      leoId: userData.leoId || null,  // Include Leo ID if verified
      role: userData.role || 'member',
      isVerified: userData.isVerified || false,
      createdAt: userData.createdAt?._seconds 
        ? new Date(userData.createdAt._seconds * 1000).toISOString()
        : new Date().toISOString(),
      updatedAt: userData.updatedAt?._seconds
        ? new Date(userData.updatedAt._seconds * 1000).toISOString()
        : new Date().toISOString()
    });
  } catch (error) {
    console.error('Get me error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Forgot password - Send OTP via email
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const user = await authService.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'No account found with this email address' });
    }

    // Get user name from Firestore
    const userData = await firestoreService.getById('users', user.uid);
    const userName = userData?.fullName || 'User';

    // Send OTP via email
    const result = await emailService.sendPasswordResetOTP(email, userName);

    // Check if email was sent successfully
    if (!result.success) {
      console.warn(`⚠️ Password reset OTP generated but email not sent: ${result.message}`);
      // Still return success with OTP for development/testing
      return res.json({ 
        message: result.message || 'OTP generated. Email service may not be configured.',
        email: email.replace(/(.{2})(.*)(@.*)/, '$1***$3'), // Mask email
        ...(process.env.NODE_ENV !== 'production' && { otp: result.otp }) // Dev only
      });
    }

    res.json({ 
      message: result.message || 'OTP sent to your email address',
      email: email.replace(/(.{2})(.*)(@.*)/, '$1***$3'), // Mask email
      ...(process.env.NODE_ENV !== 'production' && { otp: result.otp }) // Dev only
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ message: error.message || 'Failed to send OTP' });
  }
};

// @desc    Verify OTP for password reset
// @route   POST /api/auth/verify-otp
// @access  Public
exports.verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ message: 'Email and OTP are required' });
    }

    const result = emailService.verifyOTP(email, otp);

    if (!result.valid) {
      return res.status(400).json({ message: result.message });
    }

    res.json({ 
      message: result.message,
      verified: true
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ message: error.message || 'Failed to verify OTP' });
  }
};

// @desc    Resend OTP for password reset
// @route   POST /api/auth/resend-otp
// @access  Public
exports.resendOTP = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const user = await authService.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'No account found with this email address' });
    }

    // Get user name from Firestore
    const userData = await firestoreService.getById('users', user.uid);
    const userName = userData?.fullName || 'User';

    // Send new OTP via email
    const result = await emailService.sendPasswordResetOTP(email, userName);

    res.json({ 
      message: 'New OTP sent to your email address',
      ...(process.env.NODE_ENV !== 'production' && { otp: result.otp }) // Dev only
    });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ message: error.message || 'Failed to resend OTP' });
  }
};

// @desc    Reset password with OTP verification
// @route   POST /api/auth/reset-password
// @access  Public
exports.resetPassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).json({ message: 'Email and new password are required' });
    }

    // Check password strength
    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    // Verify that OTP was verified for this email
    if (!emailService.isOTPVerified(email)) {
      return res.status(400).json({ message: 'Please verify OTP first' });
    }

    // Get user by email
    const user = await authService.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update password in Firebase Auth
    await authService.updateUser(user.uid, { password: newPassword });

    // Clear OTP after successful password reset
    emailService.clearOTP(email);

    // Update user record in Firestore
    await firestoreService.update('users', user.uid, {
      passwordUpdatedAt: new Date(),
      updatedAt: new Date()
    });

    res.json({ 
      message: 'Password reset successfully',
      success: true
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ message: error.message || 'Failed to reset password' });
  }
};

// @desc    Verify Leo ID
// @route   POST /api/auth/verify-leo-id
// @access  Private
exports.verifyLeoId = async (req, res) => {
  try {
    const { leoId } = req.body;
    const userId = req.user.id;

    if (!leoId) {
      return res.status(400).json({ message: 'Leo ID is required' });
    }

    // Find the Leo ID record
    const leoIdRecords = await firestoreService.query('leoIds', [
      { field: 'leoId', operator: '==', value: leoId.toUpperCase().trim() }
    ]);
    
    if (leoIdRecords.length === 0) {
      return res.status(400).json({ message: 'Invalid Leo ID. Please check and try again.' });
    }

    const leoIdRecord = leoIdRecords[0];

    // Get current user data
    const userData = await firestoreService.getById('users', userId);
    if (!userData) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if Leo ID is assigned to this user's email
    if (leoIdRecord.email && leoIdRecord.email.toLowerCase() !== userData.email.toLowerCase()) {
      return res.status(400).json({ message: 'This Leo ID is not assigned to your email address.' });
    }

    // Check if already used by another user
    if (leoIdRecord.isUsed && leoIdRecord.userId && leoIdRecord.userId !== userId) {
      return res.status(400).json({ message: 'This Leo ID has already been verified by another user.' });
    }

    // Mark Leo ID as used
    await firestoreService.update('leoIds', leoIdRecord.id || leoIdRecord._id, {
      isUsed: true,
      userId: userId,
      verifiedAt: new Date(),
      updatedAt: new Date()
    });

    // Check if this Leo ID is assigned as a webmaster to any page
    const allPages = await firestoreService.getAll('pages');
    const isWebmaster = allPages.some(page => 
      (page.webmasterIds || []).includes(leoId.toUpperCase().trim())
    );

    // Update user with verified status, Leo ID, and role (if webmaster)
    const updateData = {
      isVerified: true,
      leoId: leoId.toUpperCase().trim(),
      verifiedAt: new Date(),
      updatedAt: new Date()
    };

    // If user is a webmaster, update role to webmaster
    if (isWebmaster) {
      updateData.role = 'webmaster';
    }

    await firestoreService.update('users', userId, updateData);

    // Get updated user data
    const updatedUserData = await firestoreService.getById('users', userId);

    res.json({
      message: 'Leo ID verified successfully',
      user: {
        id: userId,
        fullName: updatedUserData.fullName,
        email: updatedUserData.email,
        profilePhoto: updatedUserData.profilePhoto || null,
        bio: updatedUserData.bio || null,
        phoneNumber: updatedUserData.phoneNumber || null,
        leoClub: updatedUserData.clubId || null,
        district: updatedUserData.districtId || null,
        role: updatedUserData.role || 'member',
        isVerified: true,
        leoId: updatedUserData.leoId || leoId.toUpperCase().trim(),
        createdAt: updatedUserData.createdAt?._seconds 
          ? new Date(updatedUserData.createdAt._seconds * 1000).toISOString()
          : new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Verify Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Sign in with Google
// @route   POST /api/auth/google-signin
// @access  Public
exports.googleSignIn = async (req, res) => {
  try {
    const { idToken, accessToken, email, displayName, photoUrl, googleId } = req.body;

    if (!email || !googleId) {
      return res.status(400).json({ message: 'Email and Google ID are required' });
    }

    // Use googleId as the unique identifier (prefixed to avoid collision with regular users)
    const uniqueId = `google_${googleId}`;

    // Check if user exists in Firestore by googleId
    let userData = await firestoreService.getById('users', uniqueId);
    let isNewUser = false;

    if (!userData) {
      // Also check if user exists with same email (might have registered normally first)
      const existingUsers = await firestoreService.queryCollection('users', [
        { field: 'email', operator: '==', value: email }
      ]);

      if (existingUsers && existingUsers.length > 0) {
        // User exists with email, link Google account
        const existingUser = existingUsers[0];
        await firestoreService.update('users', existingUser.id, {
          googleId: googleId,
          authProvider: existingUser.authProvider === 'google' ? 'google' : 'email_and_google',
          updatedAt: new Date(),
          lastLoginAt: new Date()
        });
        
        // Generate token with existing user ID
        const token = authService.generateSessionToken(existingUser.id, existingUser.role || 'member');
        
        return res.json({
          token,
          isNewUser: false,
          user: {
            id: existingUser.id,
            fullName: existingUser.fullName,
            email: existingUser.email,
            profilePhoto: existingUser.profilePhoto || photoUrl || null,
            bio: existingUser.bio || null,
            phoneNumber: existingUser.phoneNumber || null,
            leoClub: existingUser.clubId || null,
            district: existingUser.districtId || null,
            leoId: existingUser.leoId || null,  // Include Leo ID if verified
            role: existingUser.role || 'member',
            isVerified: existingUser.isVerified || false,
            authProvider: existingUser.authProvider || 'google',
            createdAt: existingUser.createdAt?._seconds 
              ? new Date(existingUser.createdAt._seconds * 1000).toISOString()
              : new Date().toISOString(),
            updatedAt: new Date().toISOString()
          }
        });
      }

      // Create new user in Firestore
      isNewUser = true;
      const now = new Date();
      userData = {
        fullName: displayName || email.split('@')[0],
        email,
        profilePhoto: photoUrl || null,
        bio: null,
        phoneNumber: null,
        clubId: null,
        districtId: null,
        role: 'member',
        isVerified: false, // Users must verify with Leo ID
        authProvider: 'google',
        googleId: googleId,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now
      };

      await firestoreService.createWithId('users', uniqueId, userData);
    } else {
      // Update last login and profile photo if changed
      const updates = {
        updatedAt: new Date(),
        lastLoginAt: new Date()
      };
      
      // Update photo if user doesn't have one but Google provides it
      if (!userData.profilePhoto && photoUrl) {
        updates.profilePhoto = photoUrl;
      }
      
      await firestoreService.update('users', uniqueId, updates);
      userData = { ...userData, ...updates };
    }

    // Generate session token
    const token = authService.generateSessionToken(uniqueId, userData.role || 'member');

    res.json({
      success: true,
      token,
      isNewUser,
      user: {
        id: uniqueId,
        fullName: userData.fullName,
        email: userData.email,
        profilePhoto: userData.profilePhoto || photoUrl || null,
        bio: userData.bio || null,
        phoneNumber: userData.phoneNumber || null,
        leoClub: userData.clubId || null,
        district: userData.districtId || null,
        leoId: userData.leoId || null,  // Include Leo ID if verified
        role: userData.role || 'member',
        isVerified: userData.isVerified || false,
        authProvider: userData.authProvider || 'google',
        createdAt: userData.createdAt?._seconds 
          ? new Date(userData.createdAt._seconds * 1000).toISOString()
          : new Date().toISOString(),
        updatedAt: userData.updatedAt?._seconds
          ? new Date(userData.updatedAt._seconds * 1000).toISOString()
          : new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Google sign-in error:', error);
    res.status(500).json({ message: error.message || 'Failed to sign in with Google' });
  }
};

// @desc    Sign in with Apple
// @route   POST /api/auth/apple-signin
// @access  Public
exports.appleSignIn = async (req, res) => {
  try {
    const { userIdentifier, identityToken, authorizationCode, email, displayName, givenName, familyName } = req.body;

    if (!userIdentifier) {
      return res.status(400).json({ message: 'User identifier is required' });
    }

    // Use userIdentifier as the unique identifier (prefixed to avoid collision with regular users)
    const uniqueId = `apple_${userIdentifier}`;

    // Check if user exists in Firestore by appleId
    let userData = await firestoreService.getById('users', uniqueId);
    let isNewUser = false;

    if (!userData) {
      // Also check if user exists with same email (might have registered normally first)
      // Note: Apple may not always provide email, so this check is conditional
      if (email) {
        const existingUsers = await firestoreService.queryCollection('users', [
          { field: 'email', operator: '==', value: email }
        ]);

        if (existingUsers && existingUsers.length > 0) {
          // User exists with email, link Apple account
          const existingUser = existingUsers[0];
          await firestoreService.update('users', existingUser.id, {
            appleId: userIdentifier,
            authProvider: existingUser.authProvider === 'apple' ? 'apple' : 
                         existingUser.authProvider === 'google' ? 'google_and_apple' :
                         existingUser.authProvider === 'email_and_google' ? 'email_google_apple' :
                         'email_and_apple',
            updatedAt: new Date(),
            lastLoginAt: new Date()
          });
          
          // Generate token with existing user ID
          const token = authService.generateSessionToken(existingUser.id, existingUser.role || 'member');
          
          return res.json({
            token,
            isNewUser: false,
            user: {
              id: existingUser.id,
              fullName: existingUser.fullName,
              email: existingUser.email,
              profilePhoto: existingUser.profilePhoto || null,
              bio: existingUser.bio || null,
              phoneNumber: existingUser.phoneNumber || null,
              leoClub: existingUser.clubId || null,
              district: existingUser.districtId || null,
              leoId: existingUser.leoId || null,  // Include Leo ID if verified
              role: existingUser.role || 'member',
              isVerified: existingUser.isVerified || false,
              authProvider: existingUser.authProvider || 'apple',
              createdAt: existingUser.createdAt?._seconds 
                ? new Date(existingUser.createdAt._seconds * 1000).toISOString()
                : new Date().toISOString(),
              updatedAt: new Date().toISOString()
            }
          });
        }
      }

      // Create new user in Firestore
      isNewUser = true;
      const now = new Date();
      userData = {
        fullName: displayName || givenName || familyName || email?.split('@')[0] || 'Apple User',
        email: email || null, // Apple may not provide email on subsequent sign-ins
        profilePhoto: null, // Apple doesn't provide profile photos
        bio: null,
        phoneNumber: null,
        clubId: null,
        districtId: null,
        role: 'member',
        isVerified: false, // Users must verify with Leo ID
        authProvider: 'apple',
        appleId: userIdentifier,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now
      };

      await firestoreService.createWithId('users', uniqueId, userData);
    } else {
      // Update last login and name if provided
      const updates = {
        updatedAt: new Date(),
        lastLoginAt: new Date()
      };
      
      // Update name if user doesn't have one but Apple provides it
      if (!userData.fullName && displayName) {
        updates.fullName = displayName;
      } else if (!userData.fullName && (givenName || familyName)) {
        updates.fullName = [givenName, familyName].filter(n => n).join(' ') || userData.fullName;
      }
      
      // Update email if not set and Apple provides it
      if (!userData.email && email) {
        updates.email = email;
      }
      
      await firestoreService.update('users', uniqueId, updates);
      userData = { ...userData, ...updates };
    }

    // Generate session token
    const token = authService.generateSessionToken(uniqueId, userData.role || 'member');

    res.json({
      success: true,
      token,
      isNewUser,
      user: {
        id: uniqueId,
        fullName: userData.fullName,
        email: userData.email || email || null,
        profilePhoto: userData.profilePhoto || null,
        bio: userData.bio || null,
        phoneNumber: userData.phoneNumber || null,
        leoClub: userData.clubId || null,
        district: userData.districtId || null,
        leoId: userData.leoId || null,  // Include Leo ID if verified
        role: userData.role || 'member',
        isVerified: userData.isVerified || false,
        authProvider: userData.authProvider || 'apple',
        createdAt: userData.createdAt?._seconds 
          ? new Date(userData.createdAt._seconds * 1000).toISOString()
          : new Date().toISOString(),
        updatedAt: userData.updatedAt?._seconds
          ? new Date(userData.updatedAt._seconds * 1000).toISOString()
          : new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Apple sign-in error:', error);
    res.status(500).json({ message: error.message || 'Failed to sign in with Apple' });
  }
};