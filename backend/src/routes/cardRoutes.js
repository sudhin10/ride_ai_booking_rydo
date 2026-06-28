const express = require('express');
const { protect } = require('../middleware/auth');
const c = require('../controllers/cardController');

const router = express.Router();
router.use(protect);
router.get('/', c.list);
router.post('/', c.add);
router.patch('/:id/default', c.setDefault);
router.delete('/:id', c.remove);

module.exports = router;
