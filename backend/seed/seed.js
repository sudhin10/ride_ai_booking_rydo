/* Seeds the database with demo drivers and a demo rider account. */
const mongoose = require('mongoose');
const connectDB = require('../src/config/db');
const User = require('../src/models/User');
const Driver = require('../src/models/Driver');

const DEMO_CENTER = { lat: 37.7749, lng: -122.4194 }; // San Francisco

const driverSeed = [
  { name: 'Tim Mickelson', type: 'economy', model: 'Toyota Prius', color: 'White', plate: 'CAB-1024', rating: 4.9 },
  { name: 'Sara Lopez', type: 'comfort', model: 'Honda Accord', color: 'Black', plate: 'CAB-2048', rating: 4.8 },
  { name: 'David Kim', type: 'premium', model: 'Mercedes E-Class', color: 'Silver', plate: 'CAB-4096', rating: 5.0 },
  { name: 'Aisha Khan', type: 'van', model: 'Toyota Sienna', color: 'Grey', plate: 'CAB-8192', rating: 4.7 },
  { name: 'Marco Rossi', type: 'economy', model: 'Hyundai Elantra', color: 'Blue', plate: 'CAB-1337', rating: 4.6 },
  { name: 'Nina Patel', type: 'comfort', model: 'Mazda 6', color: 'Red', plate: 'CAB-7777', rating: 4.85 },
];

async function run() {
  await connectDB();
  await Driver.deleteMany({});
  const drivers = driverSeed.map((d, idx) => ({
    name: d.name,
    phone: `+1-555-01${idx}${idx}`,
    rating: d.rating,
    totalTrips: 100 + idx * 37,
    car: { model: d.model, color: d.color, plate: d.plate, type: d.type },
    isOnline: true,
    isAvailable: true,
    location: {
      type: 'Point',
      coordinates: [
        DEMO_CENTER.lng + (Math.random() - 0.5) * 0.04,
        DEMO_CENTER.lat + (Math.random() - 0.5) * 0.04,
      ],
    },
  }));
  await Driver.insertMany(drivers);

  const demoEmail = 'rider@rydo.app';
  await User.deleteOne({ email: demoEmail });
  await User.create({
    name: 'Demo Rider',
    email: demoEmail,
    password: 'password123',
    phone: '+1-555-0000',
    walletBalance: 50,
    homeAddress: '123 Market St, San Francisco',
    workAddress: '1 Hacker Way, Menlo Park',
  });

  // eslint-disable-next-line no-console
  console.log(`[seed] Inserted ${drivers.length} drivers.`);
  console.log(`[seed] Demo login -> email: ${demoEmail}  password: password123`);
  await mongoose.connection.close();
  process.exit(0);
}

run().catch((e) => {
  // eslint-disable-next-line no-console
  console.error('[seed] Failed:', e);
  process.exit(1);
});
