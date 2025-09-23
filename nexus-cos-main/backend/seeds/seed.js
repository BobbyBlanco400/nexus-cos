const mongoose = require('mongoose');
const User = require('../models/User');
const Show = require('../models/Show');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/cloudcore';

async function seed() {
  await mongoose.connect(MONGO_URI);

  await User.deleteMany({});
  await Show.deleteMany({});

  const user = await User.create({
    username: 'demoUser',
    password: 'password123',
    email: 'demo@demo.com'
  });

  const show = await Show.create({
    title: 'Demo Show',
    description: 'A sample show seeded in database.',
    date: new Date(),
    creator: user._id
  });

  console.log('Seeded user and show:', user.username, show.title);

  await mongoose.disconnect();
}

seed();
