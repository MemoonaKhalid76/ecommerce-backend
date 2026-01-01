const mongoose = require('mongoose');
require('dotenv').config();
const Product = require('./models/Product');

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);

        const product = await Product.findOne({});
        if (product) {
            console.log(JSON.stringify(product, null, 2));
        } else {
            console.log('No products found');
        }

        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

connectDB();
