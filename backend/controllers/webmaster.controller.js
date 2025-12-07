/**
 * Webmaster Controller - Manage webmasters and Leo IDs
 * Only Super Admins can access these endpoints
 */

const firestoreService = require('../services/firestore.service');
const emailService = require('../services/email.service');

// Generate a unique Leo ID (format: LEO-XXXXX)
const generateLeoId = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = 'LEO-';
  for (let i = 0; i < 5; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

// @desc    Get all registered users (for super admin to select webmasters)
// @route   GET /api/webmasters/users
// @access  Super Admin only
exports.getAllUsers = async (req, res) => {
  try {
    const users = await firestoreService.getAll('users');
    
    // Return users with relevant info only
    const userList = users.map(user => ({
      id: user._id || user.id,
      fullName: user.fullName,
      email: user.email,
      profilePhoto: user.profilePhoto,
      role: user.role || 'member',
      leoId: user.leoId || null,
      pendingLeoId: user.pendingLeoId || null,
      leoClub: user.leoClub || null,
      isVerified: user.isVerified || false,
      createdAt: user.createdAt,
    }));

    // Sort by creation date (newest first)
    userList.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    res.json(userList);
  } catch (error) {
    console.error('Get all users error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all Leo IDs (generated webmaster credentials)
// @route   GET /api/webmasters/leo-ids
// @access  Super Admin only
exports.getAllLeoIds = async (req, res) => {
  try {
    const leoIds = await firestoreService.getAll('leoIds');
    res.json(leoIds || []);
  } catch (error) {
    console.error('Get Leo IDs error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a new Leo ID for a user (make them webmaster)
// @route   POST /api/webmasters/create-leo-id
// @access  Super Admin only
exports.createLeoId = async (req, res) => {
  try {
    const { userId, clubId, clubName } = req.body;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    // Get the user
    const user = await firestoreService.getById('users', userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if user already has a Leo ID or pending Leo ID
    if (user.leoId) {
      return res.status(400).json({ message: 'User already has a Leo ID assigned' });
    }

    if (user.pendingLeoId) {
      return res.status(400).json({ 
        message: 'User already has a pending Leo ID: ' + user.pendingLeoId 
      });
    }

    // Generate unique Leo ID
    let leoId = generateLeoId();
    
    // Check if Leo ID already exists using proper query format
    let existingLeoId = await firestoreService.query('leoIds', [
      { field: 'leoId', operator: '==', value: leoId }
    ]);
    while (existingLeoId.length > 0) {
      leoId = generateLeoId();
      existingLeoId = await firestoreService.query('leoIds', [
        { field: 'leoId', operator: '==', value: leoId }
      ]);
    }

    // Create Leo ID record
    const leoIdRecord = {
      leoId: leoId,
      userId: userId,
      userEmail: user.email,
      userName: user.fullName,
      clubId: clubId || 'leo-club-colombo',
      clubName: clubName || 'Leo Club of Colombo',
      isUsed: false, // Will be true when user verifies
      createdBy: req.user._id || req.user.id,
      createdAt: new Date().toISOString(),
    };

    await firestoreService.create('leoIds', leoIdRecord);

    // Update user with pending Leo ID (not verified yet)
    await firestoreService.update('users', userId, {
      pendingLeoId: leoId,
      assignedClub: clubId || 'leo-club-colombo',
      assignedClubName: clubName || 'Leo Club of Colombo',
    });

    // Send Leo ID via email
    try {
      if (user.email) {
        await emailService.sendLeoIdEmail(
          user.email,
          leoId,
          user.fullName || user.email.split('@')[0]
        );
        console.log(`📧 Leo ID email sent to ${user.email} for Leo ID: ${leoId}`);
      } else {
        console.warn(`⚠️ User ${userId} has no email address. Leo ID created but email not sent.`);
      }
    } catch (emailError) {
      console.error('❌ Failed to send Leo ID email:', emailError);
      // Don't fail the request if email fails, but log it
      // The Leo ID is still created successfully
    }

    res.status(201).json({
      message: 'Leo ID created successfully',
      leoId: leoId,
      user: {
        id: userId,
        fullName: user.fullName,
        email: user.email,
      },
      club: {
        id: clubId || 'leo-club-colombo',
        name: clubName || 'Leo Club of Colombo',
      }
    });
  } catch (error) {
    console.error('Create Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Verify Leo ID (user submits their assigned Leo ID)
// @route   POST /api/webmasters/verify-leo-id
// @access  Protected (any authenticated user)
exports.verifyLeoId = async (req, res) => {
  try {
    const { leoId } = req.body;
    const userId = req.user._id || req.user.id;

    if (!leoId) {
      return res.status(400).json({ message: 'Leo ID is required' });
    }

    // Find the Leo ID record using proper query format
    const leoIdRecords = await firestoreService.query('leoIds', [
      { field: 'leoId', operator: '==', value: leoId.toUpperCase() }
    ]);
    
    if (leoIdRecords.length === 0) {
      return res.status(400).json({ message: 'Invalid Leo ID. Please check and try again.' });
    }

    const leoIdRecord = leoIdRecords[0];

    // Check if Leo ID is assigned to this user
    if (leoIdRecord.userId !== userId) {
      return res.status(400).json({ message: 'This Leo ID is not assigned to your account.' });
    }

    // Check if already used
    if (leoIdRecord.isUsed) {
      return res.status(400).json({ message: 'This Leo ID has already been verified.' });
    }

    // Mark Leo ID as used
    await firestoreService.update('leoIds', leoIdRecord._id || leoIdRecord.id, {
      isUsed: true,
      verifiedAt: new Date().toISOString(),
    });

    // Update user role to webmaster and verify
    await firestoreService.update('users', userId, {
      role: 'webmaster',
      leoId: leoId.toUpperCase(),
      leoClub: leoIdRecord.clubId,
      leoClubName: leoIdRecord.clubName,
      isVerified: true,
      verifiedAt: new Date().toISOString(),
      pendingLeoId: null, // Clear pending
    });

    // Get updated user
    const updatedUser = await firestoreService.getById('users', userId);

    res.json({
      message: 'Leo ID verified successfully! You are now a webmaster.',
      user: {
        id: updatedUser._id || updatedUser.id,
        fullName: updatedUser.fullName,
        email: updatedUser.email,
        role: updatedUser.role,
        leoId: updatedUser.leoId,
        leoClub: updatedUser.leoClub,
        leoClubName: updatedUser.leoClubName,
        isVerified: updatedUser.isVerified,
      }
    });
  } catch (error) {
    console.error('Verify Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Revoke webmaster status
// @route   DELETE /api/webmasters/:userId
// @access  Super Admin only
exports.revokeWebmaster = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await firestoreService.getById('users', userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Remove webmaster role
    await firestoreService.update('users', userId, {
      role: 'member',
      leoId: null,
      leoClub: null,
      leoClubName: null,
      isVerified: false,
      pendingLeoId: null,
      assignedClub: null,
      assignedClubName: null,
    });

    // Also mark Leo ID as revoked if exists
    if (user.leoId) {
      const leoIdRecords = await firestoreService.query('leoIds', [
        { field: 'leoId', operator: '==', value: user.leoId }
      ]);
      if (leoIdRecords.length > 0) {
        await firestoreService.update('leoIds', leoIdRecords[0]._id || leoIdRecords[0].id, {
          isRevoked: true,
          revokedAt: new Date().toISOString(),
          revokedBy: req.user._id || req.user.id,
        });
      }
    }

    res.json({ message: 'Webmaster status revoked successfully' });
  } catch (error) {
    console.error('Revoke webmaster error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get webmasters only
// @route   GET /api/webmasters
// @access  Super Admin only
exports.getWebmasters = async (req, res) => {
  try {
    const webmasters = await firestoreService.query('users', [
      { field: 'role', operator: '==', value: 'webmaster' }
    ]);
    
    const webmasterList = webmasters.map(user => ({
      id: user._id || user.id,
      fullName: user.fullName,
      email: user.email,
      profilePhoto: user.profilePhoto,
      leoId: user.leoId,
      leoClub: user.leoClub,
      leoClubName: user.leoClubName,
      isVerified: user.isVerified,
      verifiedAt: user.verifiedAt,
    }));

    res.json(webmasterList);
  } catch (error) {
    console.error('Get webmasters error:', error);
    res.status(500).json({ message: error.message });
  }
};
