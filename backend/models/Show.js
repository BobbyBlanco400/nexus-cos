const mongoose = require('mongoose');

const showSchema = new mongoose.Schema({
  title: String,
  description: String,
  date: Date,
  creator: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
});

module.exports = mongoose.model('Show', showSchema);
