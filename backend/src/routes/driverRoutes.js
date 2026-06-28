const express = require('express');
const { protect } = require('../middleware/auth');
const c = require('../controllers/driverController');

const router = express.Router();
router.use(protect);
router.get('/nearby', c.listNearby);
router.get('/:id', c.getById);

module.exports = router;
