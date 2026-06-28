const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true, index: true },
    phone: { type: String, trim: true, default: '' },
    password: { type: String, required: true, minlength: 6, select: false },
    avatarUrl: { type: String, default: '' },
    role: { type: String, enum: ['rider', 'driver', 'admin'], default: 'rider' },
    walletBalance: { type: Number, default: 0 },
    homeAddress: { type: String, default: '' },
    workAddress: { type: String, default: '' },
    emergencyContact: { type: String, default: '' },
    // Accessibility preferences
    voiceNavigationEnabled: { type: Boolean, default: false },
    voiceNavigationPrompted: { type: Boolean, default: false },
    ttsSpeechRate: { type: Number, default: 0.5 },
    refreshTokens: { type: [String], default: [], select: false },
  },
  { timestamps: true }
);

userSchema.pre('save', async function hashPassword(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  return next();
});

userSchema.methods.comparePassword = function comparePassword(candidate) {
  return bcrypt.compare(candidate, this.password);
};

userSchema.methods.toSafeJSON = function toSafeJSON() {
  const obj = this.toObject();
  delete obj.password;
  delete obj.refreshTokens;
  delete obj.__v;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
