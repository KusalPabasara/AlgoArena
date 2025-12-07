const fs = require('fs').promises;
const path = require('path');
const { v4: uuidv4 } = require('uuid');

class StorageService {
  constructor() {
    this.uploadsDir = path.join(process.cwd(), 'uploads');
    this.baseUrl = process.env.BASE_URL || 'http://152.42.240.220:5000';
    this._dirsInitialized = false;
    // Initialize directories (fire and forget, will be checked in uploadFile)
    this._ensureUploadsDir().catch(err => {
      console.error('⚠️ Error initializing uploads directories:', err);
    });
  }

  /**
   * Ensure uploads directory structure exists
   */
  async _ensureUploadsDir() {
    try {
      const dirs = [
        this.uploadsDir,
        path.join(this.uploadsDir, 'posts'),
        path.join(this.uploadsDir, 'pages'),
        path.join(this.uploadsDir, 'events'),
        path.join(this.uploadsDir, 'profiles')
      ];

      for (const dir of dirs) {
        try {
          await fs.access(dir);
        } catch {
          await fs.mkdir(dir, { recursive: true });
          console.log(`✅ Created uploads directory: ${dir}`);
        }
      }
      this._dirsInitialized = true;
    } catch (error) {
      console.error('❌ Error creating uploads directories:', error);
      throw error;
    }
  }

  /**
   * Upload file to local filesystem
   */
  async uploadFile(file, folder = 'uploads') {
    try {
      // Ensure directories are initialized
      if (!this._dirsInitialized) {
        await this._ensureUploadsDir();
      }
      
      // Ensure directory exists
      const folderPath = path.join(this.uploadsDir, folder);
      await fs.mkdir(folderPath, { recursive: true });

      // Generate unique filename
      const fileExt = path.extname(file.originalname).toLowerCase();
      const fileName = `${uuidv4()}${fileExt}`;
      const filePath = path.join(folderPath, fileName);

      // Write file to disk
      await fs.writeFile(filePath, file.buffer);

      // Generate public URL
      const publicUrl = `${this.baseUrl}/uploads/${folder}/${fileName}`;

      console.log(`✅ File uploaded: ${filePath}`);
      console.log(`   Public URL: ${publicUrl}`);

      return {
        fileName: `${folder}/${fileName}`,
        url: publicUrl,
        contentType: file.mimetype,
        size: file.buffer.length
      };
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
   * Delete file from local filesystem
   */
  async deleteFile(fileName) {
    try {
      const filePath = path.join(this.uploadsDir, fileName);
      
      // Check if file exists
      try {
        await fs.access(filePath);
      } catch {
        // File doesn't exist, return success anyway
        return { success: true, message: 'File not found, already deleted' };
      }

      await fs.unlink(filePath);
      console.log(`✅ File deleted: ${filePath}`);
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
      const filePath = path.join(this.uploadsDir, fileName);
      const stats = await fs.stat(filePath);
      
      return {
        size: stats.size,
        createdAt: stats.birthtime,
        modifiedAt: stats.mtime
      };
    } catch (error) {
      throw new Error(`Error getting file metadata: ${error.message}`);
    }
  }

  /**
   * Get signed URL for private files (for compatibility, returns public URL)
   */
  async getSignedUrl(fileName, expirationMinutes = 60) {
    try {
      const publicUrl = `${this.baseUrl}/uploads/${fileName}`;
      return publicUrl;
    } catch (error) {
      throw new Error(`Error getting signed URL: ${error.message}`);
    }
  }

  /**
   * Check if file exists
   */
  async fileExists(fileName) {
    try {
      const filePath = path.join(this.uploadsDir, fileName);
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Extract file name from URL
   */
  extractFileNameFromUrl(url) {
    try {
      // Extract filename from URL like: http://152.42.240.220:5000/uploads/posts/uuid.jpg
      const urlParts = url.split('/uploads/');
      if (urlParts.length > 1) {
        return urlParts[1]; // Returns: posts/uuid.jpg
      }
      return null;
    } catch (error) {
      return null;
    }
  }
}

module.exports = new StorageService();
