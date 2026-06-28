const express = require('express');

const router = express.Router();

router.use('/auth', require('./authRoutes'));
router.use('/users', require('./userRoutes'));
router.use('/drivers', require('./driverRoutes'));
router.use('/rides', require('./rideRoutes'));
router.use('/cards', require('./cardRoutes'));
router.use('/transactions', require('./transactionRoutes'));
router.use('/ai', require('./aiRoutes'));
router.use('/reviews', require('./reviewRoutes'));

router.get('/health', (req, res) => res.json({ success: true, status: 'ok', time: new Date().toISOString() }));

module.exports = router;
