const Address = require('../models/Address');

// ======================
// GET USER ADDRESSES
// ======================
exports.getAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user._id })
      .sort({ createdAt: -1 });

    res.json(addresses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ======================
// ADD NEW ADDRESS
// ======================
exports.addAddress = async (req, res) => {
  try {
    const address = await Address.create({
      user: req.user._id,
      fullName: req.body.fullName,
      phone: req.body.phone,
      addressLine: req.body.addressLine,
      city: req.body.city,
      isDefault: req.body.isDefault || false,
    });

    res.status(201).json(address);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// ======================
// DELETE ADDRESS
// ======================
exports.deleteAddress = async (req, res) => {
  try {
    await Address.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    res.json({ message: 'Address deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
