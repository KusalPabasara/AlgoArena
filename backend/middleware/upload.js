const multer = require('multer');
const path = require('path');

// Configure storage for memory (Firebase will handle the actual storage)
const storage = multer.memoryStorage();

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  // Check MIME type if provided, otherwise rely on extension
  // Accept if extension matches OR MIME type matches (more lenient)
  const mimetype = file.mimetype ? allowedTypes.test(file.mimetype) : true;

  if (extname || mimetype) {
    cb(null, true);
  } else {
    console.error('File filter rejected:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      extname: path.extname(file.originalname).toLowerCase(),
      extnameMatch: extname,
      mimetypeMatch: mimetype
    });
    cb(new Error('Only images are allowed (jpeg, jpg, png, gif, webp)'));
  }
};

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: fileFilter
});

module.exports = upload;
