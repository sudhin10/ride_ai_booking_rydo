const express = require('express');
const { protect } = require('../middleware/auth');
const c = require('../controllers/aiController');

const router = express.Router();
router.use(protect);
router.post('/assistant', c.assistant);
router.post('/predict-fare', c.predictFare);

module.exports = router;
