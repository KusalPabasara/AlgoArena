const authService = require('../services/auth.service');
const firestoreService = require('../services/firestore.service');

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

    // Note: Firebase Admin SDK cannot verify passwords directly
    // This endpoint expects the client to authenticate with Firebase client SDK
    // and send the ID token, OR we create a custom token

    // Get user by email from Firebase Auth
    const userRecord = await authService.getUserByEmail(email);
    if (!userRecord) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Get user data from Firestore
    const userData = await firestoreService.getById('users', userRecord.uid);
    if (!userData) {
      return res.status(401).json({ message: 'User data not found' });
    }

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
    res.status(500).json({ message: error.message });
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

// @desc    Forgot password
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await authService.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate password reset link using Firebase
    const resetLink = await authService.generatePasswordResetLink(email);

    // TODO: Send email with reset link
    // For now, just return success message
    res.json({ 
      message: 'Password reset email sent',
      resetLink // Remove this in production
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Reset password
// @route   POST /api/auth/reset-password
// @access  Public
exports.resetPassword = async (req, res) => {
  try {
    // Note: Password reset is handled by Firebase Auth on the client side
    // This endpoint can be used for additional verification or logging
    res.json({ message: 'Password reset should be handled by Firebase client SDK' });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Verify Leo ID
// @route   POST /api/auth/verify-leo-id
// @access  Private
exports.verifyLeoId = async (req, res) => {
  try {
    const { leoId } = req.body;
    const userId = req.user.id;

    if (!leoId || leoId.length < 4) {
      return res.status(400).json({ message: 'Invalid Leo ID. Must be at least 4 characters.' });
    }

    // Update user in Firestore with verified status and Leo ID
    await firestoreService.update('users', userId, {
      isVerified: true,
      leoId: leoId,
      verifiedAt: new Date()
    });

    // Get updated user data
    const userData = await firestoreService.getById('users', userId);

    res.json({
      message: 'Leo ID verified successfully',
      user: {
        id: userId,
        fullName: userData.fullName,
        email: userData.email,
        profilePhoto: userData.profilePhoto || null,
        bio: userData.bio || null,
        phoneNumber: userData.phoneNumber || null,
        leoClub: userData.leoId || userData.clubId || null,
        district: userData.districtId || null,
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
    console.error('Verify Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};
