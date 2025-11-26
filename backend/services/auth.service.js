const { getAuth } = require('../config/firebase');
const jwt = require('jsonwebtoken');

// JWT secret for session tokens (in production, use env variable)
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const JWT_EXPIRE = '7d';

class AuthService {
  constructor() {
    this.auth = getAuth();
  }

  /**
   * Create a new user with email and password
   */
  async createUser(email, password, displayName) {
    try {
      const userRecord = await this.auth.createUser({
        email,
        password,
        displayName,
        emailVerified: false
      });
      return userRecord;
    } catch (error) {
      throw new Error(`Error creating user: ${error.message}`);
    }
  }

  /**
   * Get user by UID
   */
  async getUserById(uid) {
    try {
      const userRecord = await this.auth.getUser(uid);
      return userRecord;
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        return null;
      }
      throw new Error(`Error getting user: ${error.message}`);
    }
  }

  /**
   * Get user by email
   */
  async getUserByEmail(email) {
    try {
      const userRecord = await this.auth.getUserByEmail(email);
      return userRecord;
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        return null;
      }
      throw new Error(`Error getting user: ${error.message}`);
    }
  }

  /**
   * Update user
   */
  async updateUser(uid, updates) {
    try {
      const userRecord = await this.auth.updateUser(uid, updates);
      return userRecord;
    } catch (error) {
      throw new Error(`Error updating user: ${error.message}`);
    }
  }

  /**
   * Delete user
   */
  async deleteUser(uid) {
    try {
      await this.auth.deleteUser(uid);
      return { success: true };
    } catch (error) {
      throw new Error(`Error deleting user: ${error.message}`);
    }
  }

  /**
   * Verify ID token from client
   */
  async verifyToken(idToken) {
    try {
      const decodedToken = await this.auth.verifyIdToken(idToken);
      return decodedToken;
    } catch (error) {
      throw new Error(`Error verifying token: ${error.message}`);
    }
  }

  /**
   * Generate session token (JWT)
   * This is used for app-to-backend authentication
   */
  generateSessionToken(uid, role = 'member') {
    try {
      const payload = {
        uid,
        role,
        type: 'session'
      };
      return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRE });
    } catch (error) {
      throw new Error(`Error generating session token: ${error.message}`);
    }
  }

  /**
   * Verify session token (JWT)
   */
  async verifySessionToken(token) {
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      return decoded;
    } catch (error) {
      throw new Error(`Error verifying session token: ${error.message}`);
    }
  }

  /**
   * Create custom token
   */
  async createCustomToken(uid, additionalClaims = {}) {
    try {
      const customToken = await this.auth.createCustomToken(uid, additionalClaims);
      return customToken;
    } catch (error) {
      throw new Error(`Error creating custom token: ${error.message}`);
    }
  }

  /**
   * Generate password reset link
   */
  async generatePasswordResetLink(email) {
    try {
      const link = await this.auth.generatePasswordResetLink(email);
      return link;
    } catch (error) {
      throw new Error(`Error generating password reset link: ${error.message}`);
    }
  }

  /**
   * Set custom user claims (for roles)
   */
  async setCustomClaims(uid, claims) {
    try {
      await this.auth.setCustomUserClaims(uid, claims);
      return { success: true };
    } catch (error) {
      throw new Error(`Error setting custom claims: ${error.message}`);
    }
  }

  /**
   * List users with pagination
   */
  async listUsers(maxResults = 100, pageToken) {
    try {
      const listUsersResult = await this.auth.listUsers(maxResults, pageToken);
      return {
        users: listUsersResult.users,
        pageToken: listUsersResult.pageToken
      };
    } catch (error) {
      throw new Error(`Error listing users: ${error.message}`);
    }
  }

  /**
   * Disable user account
   */
  async disableUser(uid) {
    try {
      await this.auth.updateUser(uid, { disabled: true });
      return { success: true };
    } catch (error) {
      throw new Error(`Error disabling user: ${error.message}`);
    }
  }

  /**
   * Enable user account
   */
  async enableUser(uid) {
    try {
      await this.auth.updateUser(uid, { disabled: false });
      return { success: true };
    } catch (error) {
      throw new Error(`Error enabling user: ${error.message}`);
    }
  }
}

module.exports = new AuthService();
