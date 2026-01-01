const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: String,
  price: Number,
  discount: Number,
  category: String,
  subCategory: String,
  image: [String],
 stock: {
      type: Number,
      default: 0,
    },
  description: String,
  fulldescription: String,
},

  { timestamps: true }
);

module.exports = mongoose.model('Product', productSchema);
