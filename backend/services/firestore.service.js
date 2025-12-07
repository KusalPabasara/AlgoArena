const { getFirestore, FieldValue, Timestamp } = require('../config/firebase');

class FirestoreService {
  constructor() {
    this.db = getFirestore();
  }

  // Generic CRUD operations

  /**
   * Create a document in a collection
   */
  async create(collection, data) {
    try {
      const docRef = await this.db.collection(collection).add({
        ...data,
        createdAt: Timestamp.now()
      });
      return { id: docRef.id, ...data, createdAt: new Date() };
    } catch (error) {
      throw new Error(`Error creating document in ${collection}: ${error.message}`);
    }
  }

  /**
   * Create a document with a specific ID
   */
  async createWithId(collection, id, data) {
    try {
      await this.db.collection(collection).doc(id).set({
        ...data,
        createdAt: Timestamp.now()
      });
      return { id, ...data, createdAt: new Date() };
    } catch (error) {
      throw new Error(`Error creating document with ID in ${collection}: ${error.message}`);
    }
  }

  /**
   * Get a document by ID
   */
  async getById(collection, id) {
    try {
      const doc = await this.db.collection(collection).doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return { id: doc.id, ...doc.data() };
    } catch (error) {
      throw new Error(`Error getting document from ${collection}: ${error.message}`);
    }
  }

  /**
   * Get all documents in a collection
   */
  async getAll(collection, options = {}) {
    try {
      let query = this.db.collection(collection);

      // Apply filters
      if (options.where) {
        options.where.forEach(([field, operator, value]) => {
          query = query.where(field, operator, value);
        });
      }

      // Apply ordering
      if (options.orderBy) {
        const [field, direction = 'asc'] = options.orderBy;
        query = query.orderBy(field, direction);
      }

      // Apply limit
      if (options.limit) {
        query = query.limit(options.limit);
      }

      // Apply offset
      if (options.offset) {
        query = query.offset(options.offset);
      }

      const snapshot = await query.get();
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      throw new Error(`Error getting documents from ${collection}: ${error.message}`);
    }
  }

  /**
   * Update a document
   */
  async update(collection, id, data) {
    try {
      await this.db.collection(collection).doc(id).update({
        ...data,
        updatedAt: Timestamp.now()
      });
      return { id, ...data };
    } catch (error) {
      throw new Error(`Error updating document in ${collection}: ${error.message}`);
    }
  }

  /**
   * Delete a document
   */
  async delete(collection, id) {
    try {
      await this.db.collection(collection).doc(id).delete();
      return { success: true };
    } catch (error) {
      throw new Error(`Error deleting document from ${collection}: ${error.message}`);
    }
  }

  /**
   * Query documents with custom conditions
   * Supports two formats:
   * 1. query(collection, conditions) - where conditions is an array
   * 2. query(collection, field, operator, value) - single condition
   */
  async query(collection, conditionsOrField, operator, value) {
    try {
      let query = this.db.collection(collection);
      let conditions;

      // Handle both formats
      if (Array.isArray(conditionsOrField)) {
        // Format 1: query(collection, [{field, operator, value}, ...])
        conditions = conditionsOrField;
      } else if (operator && value !== undefined) {
        // Format 2: query(collection, field, operator, value)
        conditions = [{ field: conditionsOrField, operator, value }];
      } else {
        throw new Error('Invalid query parameters');
      }

      conditions.forEach(condition => {
        query = query.where(condition.field, condition.operator, condition.value);
      });

      const snapshot = await query.get();
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      throw new Error(`Error querying ${collection}: ${error.message}`);
    }
  }

  /**
   * Query documents with custom conditions (alias for query)
   * This method exists for backward compatibility
   */
  async queryCollection(collection, conditions) {
    return await this.query(collection, conditions);
  }

  /**
   * Get document count
   */
  async count(collection, conditions = []) {
    try {
      let query = this.db.collection(collection);

      conditions.forEach(condition => {
        query = query.where(condition.field, condition.operator, condition.value);
      });

      const snapshot = await query.count().get();
      return snapshot.data().count;
    } catch (error) {
      throw new Error(`Error counting documents in ${collection}: ${error.message}`);
    }
  }

  /**
   * Run a transaction
   */
  async runTransaction(callback) {
    try {
      return await this.db.runTransaction(callback);
    } catch (error) {
      throw new Error(`Transaction error: ${error.message}`);
    }
  }

  /**
   * Array union (add to array)
   */
  arrayUnion(...elements) {
    return FieldValue.arrayUnion(...elements);
  }

  /**
   * Array remove (remove from array)
   */
  arrayRemove(...elements) {
    return FieldValue.arrayRemove(...elements);
  }

  /**
   * Increment a field
   */
  increment(value) {
    return FieldValue.increment(value);
  }

  // Collection-specific operations

  /**
   * Get posts with pagination
   */
  async getPosts(page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    const posts = await this.getAll('posts', {
      orderBy: ['createdAt', 'desc'],
      limit,
      offset
    });
    const total = await this.count('posts');
    return {
      posts,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      totalPosts: total
    };
  }

  /**
   * Add comment to post (using subcollection)
   */
  async addComment(postId, commentData) {
    try {
      const createdAt = Timestamp.now();
      const commentRef = await this.db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          ...commentData,
          createdAt: createdAt
        });

      // Increment comment count on post
      await this.db.collection('posts').doc(postId).update({
        commentsCount: FieldValue.increment(1)
      });

      // Return the comment with the createdAt timestamp
      return { 
        id: commentRef.id, 
        ...commentData,
        createdAt: createdAt
      };
    } catch (error) {
      throw new Error(`Error adding comment: ${error.message}`);
    }
  }

  /**
   * Get comments for a post
   */
  async getComments(postId) {
    try {
      const snapshot = await this.db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', 'asc')
        .get();

      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      throw new Error(`Error getting comments: ${error.message}`);
    }
  }

  /**
   * Update a comment
   */
  async updateComment(postId, commentId, text) {
    try {
      await this.db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
          text: text,
          updatedAt: Timestamp.now()
        });

      return { id: commentId, text: text };
    } catch (error) {
      throw new Error(`Error updating comment: ${error.message}`);
    }
  }

  /**
   * Delete a comment
   */
  async deleteComment(postId, commentId) {
    try {
      await this.db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

      // Decrement comment count on post
      await this.db.collection('posts').doc(postId).update({
        commentsCount: FieldValue.increment(-1)
      });

      return { success: true };
    } catch (error) {
      throw new Error(`Error deleting comment: ${error.message}`);
    }
  }

  /**
   * Toggle like on post
   */
  async toggleLike(postId, userId) {
    try {
      const postRef = this.db.collection('posts').doc(postId);
      const post = await postRef.get();

      if (!post.exists) {
        throw new Error('Post not found');
      }

      const likes = post.data().likes || [];
      const isLiked = likes.includes(userId);

      if (isLiked) {
        // Unlike
        await postRef.update({
          likes: FieldValue.arrayRemove(userId),
          likesCount: FieldValue.increment(-1)
        });
        return { liked: false, likesCount: (post.data().likesCount || likes.length) - 1 };
      } else {
        // Like
        await postRef.update({
          likes: FieldValue.arrayUnion(userId),
          likesCount: FieldValue.increment(1)
        });
        return { liked: true, likesCount: (post.data().likesCount || likes.length) + 1 };
      }
    } catch (error) {
      throw new Error(`Error toggling like: ${error.message}`);
    }
  }

  /**
   * Get user's posts
   */
  async getUserPosts(userId) {
    return await this.getAll('posts', {
      where: [['authorId', '==', userId]],
      orderBy: ['createdAt', 'desc']
    });
  }

  /**
   * Get clubs by district
   */
  async getClubsByDistrict(districtId) {
    return await this.getAll('clubs', {
      where: [['districtId', '==', districtId]]
    });
  }
}

module.exports = new FirestoreService();
