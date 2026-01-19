const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const connectDB = require('./config/db');

const productRoutes = require('./routes/productRoutes');
const adminRoutes = require('./routes/adminRoutes');
const orderRoutes = require('./routes/orderRoutes');
const authRoutes = require('./routes/authRoutes');
const addressRoutes = require('./routes/addressRoutes');




const app = express();

app.use(cors());
app.use(express.json());

connectDB();

app.get('/', (req, res) => {
  res.send('Backend API is running');
});


console.log('addressRoutes:', addressRoutes);

app.use('/api', productRoutes);
app.use('/api', adminRoutes);
app.use('/api', orderRoutes);
app.use('/api/auth', authRoutes);
app.use('/api', addressRoutes);

// Admin panel
app.use(
  '/admin',
  express.static(path.join(__dirname, 'admin_panel'))
);

// Serve Uploaded Images
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () =>
  console.log(`Server running on port ${PORT}`)
);
