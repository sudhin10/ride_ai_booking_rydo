const express = require('express');
const { protect } = require('../middleware/auth');
const c = require('../controllers/rideController');

const router = express.Router();
router.use(protect);
router.post('/estimate', c.estimate);
router.post('/', c.createRide);
router.get('/', c.myRides);
router.get('/active', c.activeRide);
router.get('/:id', c.getRide);
router.patch('/:id/status', c.updateStatus);
router.post('/:id/rate', c.rateRide);

module.exports = router;
