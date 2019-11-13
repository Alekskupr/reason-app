const mongoose = require('mongoose');

const reasonSchema = new mongoose.Schema({
  date: String,
  localName: String,
  name: String,
  countryCode: String,
});

module.exports = mongoose.model('Reason', reasonSchema);
