const express = require('express');
const { protect } = require('../middleware/auth');
const c = require('../controllers/reviewController');

const router = express.Router();
router.use(protect);
router.post('/', c.create);
router.get('/', c.list);
router.get('/insights', c.insights);

module.exports = router;
