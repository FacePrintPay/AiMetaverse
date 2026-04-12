const express = require('express');
const app = express();
app.get('/api/proxy', (req, res) => res.json({status:"active",pathos:"online",agents:25}));
app.get('/health', (req, res) => res.json({status:"healthy"}));
app.listen(3000, () => console.log('🌐 PATHOS online :3000'));
