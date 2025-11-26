const { getStorage } = require('../config/firebase');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

class StorageService {
  constructor() {
    this.bucket = null;
  }

  /**
   * Initialize storage bucket
   */
  getBucket() {
    if (!this.bucket) {
      const storage = getStorage();
      this.bucket = storage.bucket();
    }
    return this.bucket;
  }

  /**
   * Upload file to Firebase Storage
   */
  async uploadFile(file, folder = 'uploads') {
    try {
      const bucket = this.getBucket();
      const fileName = `${folder}/${uuidv4()}${path.extname(file.originalname)}`;
      const fileUpload = bucket.file(fileName);

      const stream = fileUpload.createWriteStream({
        metadata: {
          contentType: file.mimetype,
          metadata: {
            originalName: file.originalname
          }
        }
      });

      return new Promise((resolve, reject) => {
        stream.on('error', (error) => {
          reject(new Error(`Upload error: ${error.message}`));
        });

        stream.on('finish', async () => {
          // Make the file public
          await fileUpload.makePublic();

          // Get public URL
          const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
          resolve({
            fileName,
            url: publicUrl,
            contentType: file.mimetype
          });
        });

        stream.end(file.buffer);
      });
    } catch (error) {
      throw new Error(`Error uploading file: ${error.message}`);
    }
  }

  /**
   * Upload multiple files
   */
  async uploadFiles(files, folder = 'uploads') {
    try {
      const uploadPromises = files.map(file => this.uploadFile(file, folder));
      return await Promise.all(uploadPromises);
    } catch (error) {
      throw new Error(`Error uploading files: ${error.message}`);
    }
  }

  /**
   * Delete file from Firebase Storage
   */
  async deleteFile(fileName) {
    try {
      const bucket = this.getBucket();
      const file = bucket.file(fileName);
      await file.delete();
      return { success: true };
    } catch (error) {
      throw new Error(`Error deleting file: ${error.message}`);
    }
  }

  /**
   * Delete multiple files
   */
  async deleteFiles(fileNames) {
    try {
      const deletePromises = fileNames.map(fileName => this.deleteFile(fileName));
      return await Promise.all(deletePromises);
    } catch (error) {
      throw new Error(`Error deleting files: ${error.message}`);
    }
  }

  /**
   * Get file metadata
   */
  async getFileMetadata(fileName) {
    try {
      const bucket = this.getBucket();
      const file = bucket.file(fileName);
      const [metadata] = await file.getMetadata();
      return metadata;
    } catch (error) {
      throw new Error(`Error getting file metadata: ${error.message}`);
    }
  }

  /**
   * Get signed URL for private files
   */
  async getSignedUrl(fileName, expirationMinutes = 60) {
    try {
      const bucket = this.getBucket();
      const file = bucket.file(fileName);
      
      const [url] = await file.getSignedUrl({
        action: 'read',
        expires: Date.now() + expirationMinutes * 60 * 1000
      });

      return url;
    } catch (error) {
      throw new Error(`Error getting signed URL: ${error.message}`);
    }
  }

  /**
   * Check if file exists
   */
  async fileExists(fileName) {
    try {
      const bucket = this.getBucket();
      const file = bucket.file(fileName);
      const [exists] = await file.exists();
      return exists;
    } catch (error) {
      throw new Error(`Error checking file existence: ${error.message}`);
    }
  }

  /**
   * Extract file name from URL
   */
  extractFileNameFromUrl(url) {
    try {
      const urlParts = url.split('/');
      const fileNameWithFolder = urlParts[urlParts.length - 1];
      return decodeURIComponent(fileNameWithFolder);
    } catch (error) {
      return null;
    }
  }
}

module.exports = new StorageService();
