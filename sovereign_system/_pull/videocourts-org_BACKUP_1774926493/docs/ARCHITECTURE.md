# VideoCourts Architecture

## System Overview

```
User Device
  ├── FacePrintPay BioAuth (fingerprint / face scan)
  ├── VideoCourts UI (HTML5 / mobile)
  └── AlfAi Assistant (legal doc prep)
        ↓
  VideoCourts API (Express / Node.js)
        ↓
  ├── MongoDB (appearance records)
  ├── PaTHos-Sovereign (C25 agent orchestration)
  └── Court Integration Layer
```

## Agent Wiring (C25 Planetary)

- **Orion** (port 5012) — UI/UX frontend generation
- **Andromeda** (port 5013) — API/webhooks
- **Mars** (port 5004) — Security/biometric auth
- **CoronaBor** (port 5017) — Compliance/audit
- **Polaris** (port 5022) — System coordination

## Biometric Flow

1. User opens appearance link
2. FacePrintPay prompts face scan + fingerprint
3. SHA256 hash generated (device-only, never transmitted raw)
4. JWT issued → appearance session opened
5. Court clerk receives verified attendance confirmation
