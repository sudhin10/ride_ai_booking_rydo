const express = require('express');
const { protect } = require('../middleware/auth');
const c = require('../controllers/userController');

const router = express.Router();
router.use(protect);
router.patch('/profile', c.updateProfile);
router.patch('/preferences', c.updatePreferences);
router.patch('/password', c.changePassword);
router.post('/wallet/topup', c.topUpWallet);

module.exports = router;
