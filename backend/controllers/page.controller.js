const firestoreService = require('../services/firestore.service');

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

    const { name, type, description, logo, coverPhoto, clubId, districtId, webmasterIds } = req.body;

    if (!name || !type) {
      return res.status(400).json({ message: 'Name and type are required' });
    }

    if (!webmasterIds || !Array.isArray(webmasterIds) || webmasterIds.length === 0) {
      return res.status(400).json({ message: 'At least one webmaster Leo ID is required' });
    }

    // Verify all webmaster Leo IDs exist
    const leoIds = await firestoreService.getAll('leoIds');
    const invalidLeoIds = webmasterIds.filter(leoId => !leoIds.find(l => l.leoId === leoId));
    if (invalidLeoIds.length > 0) {
      return res.status(400).json({ 
        message: `Invalid Leo IDs: ${invalidLeoIds.join(', ')}` 
      });
    }

    const now = new Date();
    const pageData = {
      name,
      type, // 'club' or 'district'
      description: description || null,
      logo: logo || null,
      coverPhoto: coverPhoto || null,
      clubId: clubId || null,
      districtId: districtId || null,
      webmasterIds: webmasterIds,
      followersCount: 0,
      createdAt: now,
      updatedAt: now
    };

    const page = await firestoreService.create('pages', pageData);

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

