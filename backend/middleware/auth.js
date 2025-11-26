const authService = require('../services/auth.service');
const firestoreService = require('../services/firestore.service');

exports.protect = async (req, res, next) => {
  try {
    let token;

    // Check for token in headers
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({ message: 'Not authorized to access this route' });
    }

    try {
      let decodedToken;
      
      // Try to verify as session token (JWT) first - for app authentication
      try {
        decodedToken = await authService.verifySessionToken(token);
        
        // Get user data from Firestore
        const userData = await firestoreService.getById('users', decodedToken.uid);
        
        if (!userData) {
          return res.status(401).json({ message: 'User not found' });
        }

        // Attach user to request
        req.user = {
          id: decodedToken.uid,
          ...userData,
          role: userData.role || 'member'
        };

        return next();
      } catch (sessionError) {
        // If session token fails, try Firebase ID token (for future Firebase client SDK integration)
        try {
          decodedToken = await authService.verifyToken(token);
          
          // Get user data from Firestore
          const userData = await firestoreService.getById('users', decodedToken.uid);
          
          if (!userData) {
            return res.status(401).json({ message: 'User not found' });
          }

          // Attach user to request
          req.user = {
            id: decodedToken.uid,
            ...userData,
            role: userData.role || 'member'
          };

          return next();
        } catch (idTokenError) {
          console.error('Token verification failed:', sessionError.message, idTokenError.message);
          return res.status(401).json({ message: 'Invalid or expired token' });
        }
      }
    } catch (err) {
      console.error('Auth error:', err.message);
      return res.status(401).json({ message: 'Not authorized to access this route' });
    }
  } catch (error) {
    console.error('Server error in auth middleware:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: `User role ${req.user.role} is not authorized to access this route` 
      });
    }
    next();
  };
};
