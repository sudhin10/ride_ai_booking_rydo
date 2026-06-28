const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const { protect } = require('../middleware/auth');
const c = require('../controllers/authController');

const router = express.Router();

router.post(
  '/register',
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Valid email required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be 6+ chars'),
  ],
  validate,
  c.register
);

router.post(
  '/login',
  [body('email').isEmail(), body('password').notEmpty()],
  validate,
  c.login
);

router.post('/refresh', c.refresh);
router.post('/logout', protect, c.logout);
router.get('/me', protect, c.me);
router.post('/forgot-password', [body('email').isEmail()], validate, c.forgotPassword);
router.post(
  '/reset-password',
  [body('email').isEmail(), body('code').notEmpty(), body('newPassword').isLength({ min: 6 })],
  validate,
  c.resetPassword
);

module.exports = router;
