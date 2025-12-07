const firestoreService = require('../services/firestore.service');
const storageService = require('../services/storage.service');

// @desc    Get all pages
// @route   GET /api/pages
// @access  Private
exports.getAllPages = async (req, res) => {
  try {
    const pages = await firestoreService.getAll('pages', {
      orderBy: ['createdAt', 'desc']
    });

    // Populate webmaster data
    const pagesWithData = await Promise.all(
      pages.map(async (page) => {
        const webmasters = await Promise.all(
          (page.webmasterIds || []).map(async (leoId) => {
            // Find user by Leo ID
            const leoIds = await firestoreService.getAll('leoIds');
            const leoIdData = leoIds.find(l => l.leoId === leoId);
            if (leoIdData) {
              const users = await firestoreService.getAll('users');
              const user = users.find(u => u.email === leoIdData.email);
              return user ? {
                leoId: leoId,
                fullName: user.fullName,
                email: user.email
              } : { leoId: leoId, email: leoIdData.email };
            }
            return { leoId: leoId };
          })
        );

        return {
          ...page,
          webmasters: webmasters.filter(Boolean)
        };
      })
    );

    res.json({ pages: pagesWithData });
  } catch (error) {
    console.error('Get all pages error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create page
// @route   POST /api/pages
// @access  Private (Super Admin only)
exports.createPage = async (req, res) => {
  try {
    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can create pages' });
    }

    const { name, type, description, logo, coverPhoto, clubId, districtId, webmasterIds: webmasterIdsRaw } = req.body;

    console.log('📝 Create Page Request:');
    console.log('  - name:', name);
    console.log('  - type:', type);
    console.log('  - webmasterIdsRaw:', webmasterIdsRaw);
    console.log('  - webmasterIdsRaw type:', typeof webmasterIdsRaw);

    if (!name || !type) {
      return res.status(400).json({ message: 'Name and type are required' });
    }

    // Parse webmasterIds - it might come as JSON string from multipart form
    let webmasterIds = webmasterIdsRaw;
    if (typeof webmasterIds === 'string') {
      try {
        webmasterIds = JSON.parse(webmasterIds);
        console.log('  - Parsed webmasterIds:', webmasterIds);
      } catch (e) {
        console.log('  - JSON parse failed, trying comma split');
        // If parsing fails, treat as single value or split by comma
        webmasterIds = webmasterIds.split(',').map(id => id.trim()).filter(id => id.length > 0);
        console.log('  - Split webmasterIds:', webmasterIds);
      }
    }

    console.log('  - Final webmasterIds:', webmasterIds);
    console.log('  - Is array:', Array.isArray(webmasterIds));
    console.log('  - Length:', webmasterIds?.length);

    if (!webmasterIds || !Array.isArray(webmasterIds) || webmasterIds.length === 0) {
      return res.status(400).json({ message: 'At least one webmaster Leo ID is required' });
    }

    // Verify all webmaster Leo IDs exist and are verified
    const leoIds = await firestoreService.getAll('leoIds');
    const invalidLeoIds = [];
    const unverifiedLeoIds = [];
    
    for (const leoId of webmasterIds) {
      const leoIdRecord = leoIds.find(l => l.leoId === leoId);
      if (!leoIdRecord) {
        invalidLeoIds.push(leoId);
      } else if (!leoIdRecord.isUsed) {
        unverifiedLeoIds.push(leoId);
      } else {
        // Check if the user associated with this Leo ID is verified
        if (leoIdRecord.userId) {
          const user = await firestoreService.getById('users', leoIdRecord.userId);
          if (!user || !user.isVerified) {
            unverifiedLeoIds.push(leoId);
          }
        } else {
          unverifiedLeoIds.push(leoId);
        }
      }
    }
    
    if (invalidLeoIds.length > 0) {
      return res.status(400).json({ 
        message: `Invalid Leo IDs: ${invalidLeoIds.join(', ')}` 
      });
    }
    
    if (unverifiedLeoIds.length > 0) {
      return res.status(400).json({ 
        message: `The following Leo IDs are not verified: ${unverifiedLeoIds.join(', ')}. Only verified users can be webmasters.` 
      });
    }

    // Upload logo if provided
    let logoUrl = logo || null;
    let mapImageUrl = null;
    
    // Handle file uploads (can be single file or fields)
    if (req.file) {
      // Single file upload (backward compatibility)
      try {
        const uploadResult = await storageService.uploadFile(req.file, 'pages');
        logoUrl = uploadResult.url;
      } catch (uploadError) {
        console.error('Logo upload error:', uploadError);
        return res.status(500).json({ message: 'Failed to upload logo image' });
      }
    } else if (req.files) {
      // Multiple file uploads (for district pages with logo and map)
      if (req.files['logo'] && req.files['logo'][0]) {
        try {
          const uploadResult = await storageService.uploadFile(req.files['logo'][0], 'pages');
          logoUrl = uploadResult.url;
        } catch (uploadError) {
          console.error('Logo upload error:', uploadError);
          return res.status(500).json({ message: 'Failed to upload logo image' });
        }
      }
      
      // Upload map image if provided (for district pages)
      if (req.files['mapImage'] && req.files['mapImage'][0]) {
        try {
          const uploadResult = await storageService.uploadFile(req.files['mapImage'][0], 'pages');
          mapImageUrl = uploadResult.url;
        } catch (uploadError) {
          console.error('Map image upload error:', uploadError);
          return res.status(500).json({ message: 'Failed to upload map image' });
        }
      }
    }

    // Update all webmaster users' roles to 'webmaster'
    for (const leoId of webmasterIds) {
      const leoIdRecord = leoIds.find(l => l.leoId === leoId);
      if (leoIdRecord && leoIdRecord.userId) {
        const user = await firestoreService.getById('users', leoIdRecord.userId);
        if (user && user.role !== 'webmaster' && user.role !== 'superadmin' && user.role !== 'super_admin') {
          await firestoreService.update('users', leoIdRecord.userId, {
            role: 'webmaster',
            updatedAt: new Date()
          });
          console.log(`✅ Updated user ${user.email} role to webmaster for page ${name}`);
        }
      }
    }

    const now = new Date();
    const pageData = {
      name,
      type, // 'club' or 'district'
      description: description || null,
      logo: logoUrl,
      mapImage: mapImageUrl, // Map image for district pages
      coverPhoto: coverPhoto || null,
      clubId: clubId || null,
      districtId: districtId || null,
      webmasterIds: webmasterIds,
      followersCount: 0,
      createdAt: now,
      updatedAt: now
    };

    const page = await firestoreService.create('pages', pageData);

    // Create notification for page creation
    try {
      const { createNotificationHelper } = require('./notification.controller');
      await createNotificationHelper(
        'page_created',
        'New Page Created',
        `A new ${type} page "${name}" has been created.`,
        {
          iconUrl: logoUrl,
          pageId: page.id,
        }
      );
    } catch (notifError) {
      console.error('Error creating page notification:', notifError);
      // Don't fail the request if notification creation fails
    }

    res.status(201).json({
      page: {
        id: page.id,
        ...pageData,
        createdAt: now.toISOString(),
        updatedAt: now.toISOString()
      }
    });
  } catch (error) {
    console.error('Create page error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update page
// @route   PUT /api/pages/:id
// @access  Private (Webmaster or Super Admin)
exports.updatePage = async (req, res) => {
  try {
    const pageId = req.params.id;
    const page = await firestoreService.getById('pages', pageId);

    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Check if user is webmaster or super admin
    const userData = await firestoreService.getById('users', req.user.id);
    const userLeoId = userData?.leoId;
    const isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    if (!isWebmaster && !isSuperAdmin) {
      return res.status(403).json({ 
        message: 'Only webmasters of this page can edit it' 
      });
    }

    const { name, description, logo, webmasterIds: webmasterIdsRaw } = req.body;
    const updates = {};

    // Upload new logo if provided
    let logoUrl = logo || page.logo;
    let mapImageUrl = page.mapImage || null;
    
    // Handle file uploads (can be single file or fields)
    if (req.file) {
      // Single file upload (backward compatibility)
      try {
        const uploadResult = await storageService.uploadFile(req.file, 'pages');
        logoUrl = uploadResult.url;
      } catch (uploadError) {
        console.error('Logo upload error:', uploadError);
        return res.status(500).json({ message: 'Failed to upload logo image' });
      }
    } else if (req.files) {
      // Multiple file uploads (for district pages with logo and map)
      if (req.files['logo'] && req.files['logo'][0]) {
        try {
          const uploadResult = await storageService.uploadFile(req.files['logo'][0], 'pages');
          logoUrl = uploadResult.url;
        } catch (uploadError) {
          console.error('Logo upload error:', uploadError);
          return res.status(500).json({ message: 'Failed to upload logo image' });
        }
      }
      
      // Upload map image if provided (for district pages)
      if (req.files['mapImage'] && req.files['mapImage'][0]) {
        try {
          const uploadResult = await storageService.uploadFile(req.files['mapImage'][0], 'pages');
          mapImageUrl = uploadResult.url;
        } catch (uploadError) {
          console.error('Map image upload error:', uploadError);
          return res.status(500).json({ message: 'Failed to upload map image' });
        }
      }
    }

    if (name) updates.name = name;
    if (description !== undefined) updates.description = description || null;
    if (logoUrl) updates.logo = logoUrl;
    if (mapImageUrl != null) updates.mapImage = mapImageUrl;
    
    // Super admin can update webmasters
    if (webmasterIdsRaw && isSuperAdmin) {
      // Parse webmasterIds - it might come as JSON string from multipart form
      let webmasterIds = webmasterIdsRaw;
      if (typeof webmasterIds === 'string') {
        try {
          webmasterIds = JSON.parse(webmasterIds);
        } catch (e) {
          webmasterIds = webmasterIds.split(',').map(id => id.trim()).filter(id => id.length > 0);
        }
      }
      
      if (Array.isArray(webmasterIds) && webmasterIds.length > 0) {
        // Verify all webmaster Leo IDs exist and are verified
        const leoIds = await firestoreService.getAll('leoIds');
        const invalidLeoIds = [];
        const unverifiedLeoIds = [];
        
        for (const leoId of webmasterIds) {
          const leoIdRecord = leoIds.find(l => l.leoId === leoId);
          if (!leoIdRecord) {
            invalidLeoIds.push(leoId);
          } else if (!leoIdRecord.isUsed) {
            unverifiedLeoIds.push(leoId);
          } else {
            // Check if the user associated with this Leo ID is verified
            if (leoIdRecord.userId) {
              const user = await firestoreService.getById('users', leoIdRecord.userId);
              if (!user || !user.isVerified) {
                unverifiedLeoIds.push(leoId);
              }
            } else {
              unverifiedLeoIds.push(leoId);
            }
          }
        }
        
        if (invalidLeoIds.length > 0) {
          return res.status(400).json({ 
            message: `Invalid Leo IDs: ${invalidLeoIds.join(', ')}` 
          });
        }
        
        if (unverifiedLeoIds.length > 0) {
          return res.status(400).json({ 
            message: `The following Leo IDs are not verified: ${unverifiedLeoIds.join(', ')}. Only verified users can be webmasters.` 
          });
        }
        
        updates.webmasterIds = webmasterIds;
        
        // Update all newly assigned webmaster users' roles to 'webmaster'
        const allLeoIds = await firestoreService.getAll('leoIds');
        for (const leoId of webmasterIds) {
          const leoIdRecord = allLeoIds.find(l => l.leoId === leoId);
          if (leoIdRecord && leoIdRecord.userId) {
            const user = await firestoreService.getById('users', leoIdRecord.userId);
            if (user && user.role !== 'webmaster' && user.role !== 'superadmin' && user.role !== 'super_admin') {
              await firestoreService.update('users', leoIdRecord.userId, {
                role: 'webmaster',
                updatedAt: new Date()
              });
              console.log(`✅ Updated user ${user.email} role to webmaster for page ${page.name}`);
            }
          }
        }
      }
    }
    
    updates.updatedAt = new Date();

    await firestoreService.update('pages', pageId, updates);

    const updatedPage = await firestoreService.getById('pages', pageId);

    res.json({
      message: 'Page updated successfully',
      page: {
        id: updatedPage.id,
        ...updatedPage,
        createdAt: updatedPage.createdAt?._seconds 
          ? new Date(updatedPage.createdAt._seconds * 1000).toISOString()
          : new Date().toISOString(),
        updatedAt: updatedPage.updatedAt?._seconds
          ? new Date(updatedPage.updatedAt._seconds * 1000).toISOString()
          : new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Update page error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete page
// @route   DELETE /api/pages/:id
// @access  Private (Super Admin only)
exports.deletePage = async (req, res) => {
  try {
    const pageId = req.params.id;

    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can delete pages' });
    }

    // Get the page
    const page = await firestoreService.getById('pages', pageId);
    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Delete all posts associated with this page
    const posts = await firestoreService.query('posts', 'pageId', '==', pageId);
    for (const post of posts) {
      await firestoreService.delete('posts', post.id);
    }

    // Delete all events associated with this page
    const events = await firestoreService.query('events', 'pageId', '==', pageId);
    for (const event of events) {
      await firestoreService.delete('events', event.id);
    }

    // Delete all follow records for this page
    const follows = await firestoreService.query('userPageFollows', [
      { field: 'pageId', operator: '==', value: pageId }
    ]);
    for (const follow of follows) {
      await firestoreService.delete('userPageFollows', follow.id);
    }

    // Delete the page
    await firestoreService.delete('pages', pageId);

    res.json({ message: 'Page deleted successfully' });
  } catch (error) {
    console.error('Delete page error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get page by ID
// @route   GET /api/pages/:id
// @access  Private
exports.getPageById = async (req, res) => {
  try {
    const page = await firestoreService.getById('pages', req.params.id);

    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Populate webmaster data
    const leoIds = await firestoreService.getAll('leoIds');
    const webmasters = await Promise.all(
      (page.webmasterIds || []).map(async (leoId) => {
        const leoIdData = leoIds.find(l => l.leoId === leoId);
        if (leoIdData) {
          const users = await firestoreService.getAll('users');
          const user = users.find(u => u.email === leoIdData.email);
          return user ? {
            leoId: leoId,
            fullName: user.fullName,
            email: user.email
          } : { leoId: leoId, email: leoIdData.email };
        }
        return { leoId: leoId };
      })
    );

    res.json({
      page: {
        ...page,
        webmasters: webmasters.filter(Boolean)
      }
    });
  } catch (error) {
    console.error('Get page by ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get pages where current user is a webmaster
// @route   GET /api/pages/my-pages
// @access  Private
exports.getMyPages = async (req, res) => {
  try {
    // Get user's Leo ID
    const userData = await firestoreService.getById('users', req.user.id);
    const userLeoId = userData?.leoId;

    if (!userLeoId) {
      return res.json({ pages: [] }); // User has no Leo ID, return empty
    }

    // Get all pages
    const allPages = await firestoreService.getAll('pages', {
      orderBy: ['createdAt', 'desc']
    });

    // Filter pages where user is a webmaster
    const myPages = allPages.filter(page => 
      (page.webmasterIds || []).includes(userLeoId)
    );

    // Populate webmaster data
    const pagesWithData = await Promise.all(
      myPages.map(async (page) => {
        const webmasters = await Promise.all(
          (page.webmasterIds || []).map(async (leoId) => {
            const leoIds = await firestoreService.getAll('leoIds');
            const leoIdData = leoIds.find(l => l.leoId === leoId);
            if (leoIdData) {
              const users = await firestoreService.getAll('users');
              const user = users.find(u => u.email === leoIdData.email);
              return user ? {
                leoId: leoId,
                fullName: user.fullName,
                email: user.email
              } : { leoId: leoId, email: leoIdData.email };
            }
            return { leoId: leoId };
          })
        );

        return {
          ...page,
          webmasters: webmasters.filter(Boolean)
        };
      })
    );

    res.json({ pages: pagesWithData });
  } catch (error) {
    console.error('Get my pages error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Follow/Unfollow a page
// @route   POST /api/pages/:id/follow
// @access  Private
exports.toggleFollow = async (req, res) => {
  try {
    const pageId = req.params.id;
    const userId = req.user.id;

    // Get the page
    const page = await firestoreService.getById('pages', pageId);
    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Get user's follow data
    const userFollows = await firestoreService.query('userPageFollows', [
      { field: 'userId', operator: '==', value: userId },
      { field: 'pageId', operator: '==', value: pageId }
    ]);

    if (userFollows.length > 0) {
      // Unfollow - delete the follow record
      await firestoreService.delete('userPageFollows', userFollows[0].id);
      
      // Decrement followers count
      const newFollowersCount = Math.max(0, (page.followersCount || 0) - 1);
      await firestoreService.update('pages', pageId, { followersCount: newFollowersCount });

      res.json({ 
        message: 'Unfollowed successfully',
        isFollowing: false,
        followersCount: newFollowersCount
      });
    } else {
      // Follow - create follow record
      await firestoreService.create('userPageFollows', {
        userId: userId,
        pageId: pageId,
        createdAt: new Date(),
        updatedAt: new Date()
      });

      // Increment followers count
      const newFollowersCount = (page.followersCount || 0) + 1;
      await firestoreService.update('pages', pageId, { followersCount: newFollowersCount });

      res.json({ 
        message: 'Followed successfully',
        isFollowing: true,
        followersCount: newFollowersCount
      });
    }
  } catch (error) {
    console.error('Toggle follow error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Check if user is following a page
// @route   GET /api/pages/:id/follow-status
// @access  Private
exports.getFollowStatus = async (req, res) => {
  try {
    const pageId = req.params.id;
    const userId = req.user.id;

    const userFollows = await firestoreService.query('userPageFollows', [
      { field: 'userId', operator: '==', value: userId },
      { field: 'pageId', operator: '==', value: pageId }
    ]);

    res.json({ isFollowing: userFollows.length > 0 });
  } catch (error) {
    console.error('Get follow status error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get page stats (followers, posts count, events count)
// @route   GET /api/pages/:id/stats
// @access  Private
exports.getPageStats = async (req, res) => {
  try {
    const pageId = req.params.id;

    // Get page
    const page = await firestoreService.getById('pages', pageId);
    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Get posts count
    const posts = await firestoreService.query('posts', 'pageId', '==', pageId);
    const postsCount = posts.length;

    // Get events count
    const events = await firestoreService.query('events', 'pageId', '==', pageId);
    const eventsCount = events.length;

    res.json({
      followersCount: page.followersCount || 0,
      postsCount: postsCount,
      eventsCount: eventsCount
    });
  } catch (error) {
    console.error('Get page stats error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Check if user is webmaster of a page
// @route   GET /api/pages/:id/webmaster/:leoId
// @access  Private
exports.checkWebmaster = async (req, res) => {
  try {
    const page = await firestoreService.getById('pages', req.params.id);

    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    const isWebmaster = (page.webmasterIds || []).includes(req.params.leoId);

    res.json({ isWebmaster });
  } catch (error) {
    console.error('Check webmaster error:', error);
    res.status(500).json({ message: error.message });
  }
};

