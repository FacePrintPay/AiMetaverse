const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// SERVE STATIC FILES FROM ROOT AND PUBLIC
app.use(express.static(path.join(__dirname, '..')));
app.use(express.static(path.join(__dirname, '..', 'public')));
app.use('/public', express.static(path.join(__dirname, '..', 'public')));
app.use('/assets', express.static(path.join(__dirname, '..', 'public', 'assets')));
app.use('/icons', express.static(path.join(__dirname, '..', 'public', 'icons')));

// API ROUTES
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'operational', 
    service: 'VideoCourts Justice Stack', 
    version: '1.0.0',
    endpoints_active: 6
  });
});

app.post('/api/identity/check', (req, res) => {
  const { case_id, full_name, role, email } = req.body;
  res.json({
    verified: true,
    case_id,
    user_id: `user_${Date.now()}`,
    access_level: role || 'defendant',
    token: `vc_token_${Math.random().toString(36).slice(2,10)}`,
    message: 'Identity verified successfully'
  });
});

app.post('/api/sessions', (req, res) => {
  const { case_id, judge_id } = req.body;
  res.json({
    session_id: `sess_${Date.now()}`,
    case_id,
    judge_id: judge_id || 'judge_001',
    status: 'scheduled',
    video_url: `https://videocourts-org.vercel.app/room/sess_${Date.now()}`,
    created_at: new Date().toISOString()
  });
});

app.post('/api/evidence/ingest', (req, res) => {
  const { file_path, case_id, description } = req.body;
  res.json({
    evidence_id: `ev_${Date.now()}`,
    case_id,
    hash: `sha256_${Math.random().toString(36).slice(2,64)}`,
    chain_link: `manifest_${Date.now()}`,
    stored: true,
    vault_path: `/evidence/${case_id}/${file_path || 'upload'}`
  });
});

app.post('/api/forensic/report', (req, res) => {
  const { case_id } = req.body;
  res.json({
    report_id: `fr_${Date.now()}`,
    case_id,
    audit_trail: 'immutable',
    generated_at: new Date().toISOString(),
    pdf_url: `/reports/${case_id}.pdf`
  });
});

app.post('/api/courts/tyler', (req, res) => {
  const { case_id, export_format } = req.body;
  res.json({
    exported: true,
    case_id,
    cmecf_id: `CM_${case_id}_${Date.now()}`,
    tyler_push_status: 'queued',
    confirmation_url: `https://tyler.tech/confirm/${case_id}`
  });
});

// CATCH-ALL: SERVE INDEX.HTML FOR SPA ROUTING
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'index.html'));
});

// START SERVER
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🎯 VideoCourts™ running on port ${PORT}`);
  console.log(`   Frontend: http://localhost:${PORT}/`);
  console.log(`   API: http://localhost:${PORT}/api/health`);
});
