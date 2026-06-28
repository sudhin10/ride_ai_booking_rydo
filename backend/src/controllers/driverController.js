const Driver = require('../models/Driver');
const asyncHandler = require('../utils/asyncHandler');
const { distanceKm } = require('../utils/geo');

exports.listNearby = asyncHandler(async (req, res) => {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const drivers = await Driver.find({ isOnline: true, isAvailable: true });
  const withDistance = drivers
    .map((d) => {
      const dl = { lat: d.location.coordinates[1], lng: d.location.coordinates[0] };
      const dist = Number.isFinite(lat) && Number.isFinite(lng) ? distanceKm({ lat, lng }, dl) : null;
      return { driver: d, distanceKm: dist };
    })
    .sort((a, b) => (a.distanceKm ?? 1e9) - (b.distanceKm ?? 1e9))
    .slice(0, 12);
  res.json({ success: true, drivers: withDistance });
});

exports.getById = asyncHandler(async (req, res) => {
  const driver = await Driver.findById(req.params.id);
  if (!driver) return res.status(404).json({ success: false, message: 'Driver not found' });
  return res.json({ success: true, driver });
});
