const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'VideoCourts API', version: '1.0.0' });
});

app.post('/api/appearance/book', (req, res) => {
  // TODO: biometric verify → book appearance → notify court
  res.json({ status: 'booked', message: 'Appearance scheduled' });
});

app.post('/api/auth/biometric', (req, res) => {
  // TODO: wire FacePrintPay biometric endpoint
  res.json({ status: 'verified', token: 'jwt_here' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`VideoCourts API running on port ${PORT}`));
