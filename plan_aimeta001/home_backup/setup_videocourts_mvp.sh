#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║         VIDEOCOURTS™ JUSTICE STACK MVP       ║"
echo "║   Backend API • TotalRecall • ID Gateway     ║"
echo "║   Tyler/CMECF Integration Hooks • Web UI    ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

ROOT="$HOME/videocourts-justice-stack"

echo "📂 Creating project structure at $ROOT..."
mkdir -p "$ROOT"/{apps,services,integrations,infra}
mkdir -p "$ROOT/apps/videocourts-api/routes"
mkdir -p "$ROOT/apps/videocourts-web"
mkdir -p "$ROOT/services/totalrecall"
mkdir -p "$ROOT/services/identity-gateway"
mkdir -p "$ROOT/infra/logs"

# ================================
# .env example
# ================================
cat > "$ROOT/.env.example" << 'ENV'
# CORE
VC_ENV=dev
VC_SECRET_KEY=change-me
VC_LOG_DIR=./infra/logs

# API
VC_API_HOST=0.0.0.0
VC_API_PORT=8000

# TOTALRECALL
VC_EVIDENCE_VAULT=./TotalRecall/evidence_vault

# IDENTITY GATEWAY (FacePrintPay / other provider)
ID_PROVIDER_BASE_URL=https://your-biometric-provider.example.com
ID_PROVIDER_API_KEY=your-api-key-here

# TYLER-STYLE COURT INTEGRATION (placeholder config)
TYLER_BASE_URL=https://court-system.example.com
TYLER_API_KEY=your-tyler-api-key-here
ENV

# ================================
# apps/videocourts-api/config.py
# ================================
cat > "$ROOT/apps/videocourts-api/config.py" << 'PY'
import os
from pathlib import Path
from functools import lru_cache

from pydantic import BaseSettings


class Settings(BaseSettings):
    env: str = os.getenv("VC_ENV", "dev")
    secret_key: str = os.getenv("VC_SECRET_KEY", "dev-secret")
    log_dir: str = os.getenv("VC_LOG_DIR", "./infra/logs")

    api_host: str = os.getenv("VC_API_HOST", "0.0.0.0")
    api_port: int = int(os.getenv("VC_API_PORT", "8000"))

    evidence_vault: str = os.getenv("VC_EVIDENCE_VAULT", "./TotalRecall/evidence_vault")
    totalrecall_engine: str = os.getenv(
        "VC_TOTALRECALL_ENGINE",
        str(Path.home() / "TotalRecall" / "totalrecall_engine.sh"),
    )

    # Identity gateway
    id_provider_base_url: str = os.getenv("ID_PROVIDER_BASE_URL", "")
    id_provider_api_key: str = os.getenv("ID_PROVIDER_API_KEY", "")

    # Court integration (Tyler-style)
    tyler_base_url: str = os.getenv("TYLER_BASE_URL", "")
    tyler_api_key: str = os.getenv("TYLER_API_KEY", "")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    settings = Settings()
    Path(settings.log_dir).mkdir(parents=True, exist_ok=True)
    return settings
PY

# ================================
# apps/videocourts-api/models.py
# ================================
cat > "$ROOT/apps/videocourts-api/models.py" << 'PY'
from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel


class IdentityCheckRequest(BaseModel):
    user_id: str
    full_name: str
    case_id: str
    role: str  # judge, clerk, attorney, defendant, observer
    device_id: Optional[str] = None
    session_id: Optional[str] = None
    biometric_token: Optional[str] = None  # provided by FacePrintPay/etc.


class IdentityCheckResult(BaseModel):
    success: bool
    reason: Optional[str] = None
    risk_score: Optional[float] = None
    issued_access_token: Optional[str] = None


class SessionCreateRequest(BaseModel):
    case_id: str
    calendar_id: Optional[str] = None
    judge_id: str
    start_time: Optional[datetime] = None
    expected_duration_minutes: int = 30


class SessionInfo(BaseModel):
    session_id: str
    case_id: str
    judge_id: str
    status: str
    video_room_url: str
    created_at: datetime
    start_time: Optional[datetime] = None


class EvidenceIngestRequest(BaseModel):
    file_path: str
    case_id: str
    description: str = "Evidence file"
    uploaded_by: str


class ForensicActionResponse(BaseModel):
    success: bool
    message: str
    output: Optional[str] = None


class CMECFExportResponse(BaseModel):
    success: bool
    case_id: str
    export_path: Optional[str] = None
    message: str
PY

# ================================
# apps/videocourts-api/main.py
# ================================
cat > "$ROOT/apps/videocourts-api/main.py" << 'PY'
import logging
from logging.handlers import RotatingFileHandler

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .routes import health, sessions, evidence, forensic, identity, court_integrations

settings = get_settings()

# Logging setup (SOC 2–style audit logging foundation)
logger = logging.getLogger("videocourts")
logger.setLevel(logging.INFO)
handler = RotatingFileHandler(
    f"{settings.log_dir}/videocourts-api.log",
    maxBytes=5 * 1024 * 1024,
    backupCount=5,
)
formatter = logging.Formatter(
    "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
)
handler.setFormatter(formatter)
logger.addHandler(handler)

app = FastAPI(
    title="VideoCourts Justice Stack",
    description="Virtual courts + TotalRecall forensic engine + identity gateway",
    version="0.1.0",
)

# CORS for web UI / local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten this in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="/api/health", tags=["health"])
app.include_router(identity.router, prefix="/api/identity", tags=["identity"])
app.include_router(sessions.router, prefix="/api/sessions", tags=["sessions"])
app.include_router(evidence.router, prefix="/api/evidence", tags=["evidence"])
app.include_router(forensic.router, prefix="/api/forensic", tags=["forensic"])
app.include_router(
    court_integrations.router, prefix="/api/courts", tags=["court_integrations"]
)


@app.on_event("startup")
async def startup_event():
    logger.info("VideoCourts API starting up")


@app.on_event("shutdown")
async def shutdown_event():
    logger.info("VideoCourts API shutting down")
PY

# ================================
# apps/videocourts-api/routes/health.py
# ================================
cat > "$ROOT/apps/videocourts-api/routes/health.py" << 'PY'
from fastapi import APIRouter
from ..config import get_settings

router = APIRouter()


@router.get("/")
async def health_root():
    s = get_settings()
    return {
        "status": "ok",
        "env": s.env,
        "evidence_vault": s.evidence_vault,
    }
PY

# ================================
# apps/videocourts-api/routes/identity.py
# ================================
cat > "$ROOT/apps/videocourts-api/routes/identity.py" << 'PY'
from fastapi import APIRouter
from ..config import get_settings
from ..models import IdentityCheckRequest, IdentityCheckResult
from ...services.identity_gateway.client import perform_identity_check

router = APIRouter()
settings = get_settings()


@router.post("/check", response_model=IdentityCheckResult)
async def identity_check(payload: IdentityCheckRequest):
    """
    Biometric / ID gateway check.
    This hands off to the identity gateway service (FacePrintPay/etc.).
    """
    result = await perform_identity_check(payload, settings)
    return result
PY

# ================================
# apps/videocourts-api/routes/sessions.py
# ================================
cat > "$ROOT/apps/videocourts-api/routes/sessions.py" << 'PY'
import uuid
from datetime import datetime

from fastapi import APIRouter
from ..models import SessionCreateRequest, SessionInfo

router = APIRouter()

# In-memory MVP store (replace with DB later)
SESSIONS = {}


@router.post("/", response_model=SessionInfo)
async def create_session(payload: SessionCreateRequest):
    session_id = str(uuid.uuid4())
    now = datetime.utcnow()

    # In MVP we fake a "video room" URL; plug in Twilio/LiveKit/Janus/etc. later
    video_room_url = f"https://videocourts.local/room/{session_id}"

    info = SessionInfo(
        session_id=session_id,
        case_id=payload.case_id,
        judge_id=payload.judge_id,
        status="scheduled",
        created_at=now,
        start_time=payload.start_time,
        video_room_url=video_room_url,
    )
    SESSIONS[session_id] = info
    return info


@router.get("/{session_id}", response_model=SessionInfo)
async def get_session(session_id: str):
    return SESSIONS[session_id]
PY

# ================================
# apps/videocourts-api/routes/evidence.py
# ================================
cat > "$ROOT/apps/videocourts-api/routes/evidence.py" << 'PY'
from fastapi import APIRouter
from ..models import EvidenceIngestRequest, ForensicActionResponse
from ..config import get_settings
from ...services.totalrecall.client import ingest_via_totalrecall

router = APIRouter()
settings = get_settings()


@router.post("/ingest", response_model=ForensicActionResponse)
async def ingest_evidence(payload: EvidenceIngestRequest):
    """
    Ingest evidence into TotalRecall vault.
    """
    success, msg, output = ingest_via_totalrecall(payload, settings)
    return ForensicActionResponse(success=success, message=msg, output=output)
PY

# ================================
# apps/videocourts-api/routes/forensic.py
# ================================
cat > "$ROOT/apps/videocourts-api/routes/forensic.py" << 'PY'
from fastapi import APIRouter
from ..models import ForensicActionResponse, CMECFExportResponse
from ..config import get_settings
from ...services.totalrecall.client import (
    generate_report_via_totalrecall,
    export_cmecf_via_totalrecall,
)

router = APIRouter()
settings = get_settings()


@router.get("/report/{case_id}", response_model=ForensicActionResponse)
async def generate_forensic_report(case_id: str):
    success, msg, output = generate_report_via_totalrecall(case_id, settings)
    return ForensicActionResponse(success=success, message=msg, output=output)


@router.post("/export/{case_id}", response_model=CMECFExportResponse)
async def export_cmecf(case_id: str):
    success, msg, export_path = export_cmecf_via_totalrecall(case_id, settings)
    return CMECFExportResponse(
        success=success,
        case_id=case_id,
        export_path=export_path,
        message=msg,
    )
PY

# ================================
# apps/videocourts-api/routes/court_integrations.py
# ================================
cat > "$ROOT/apps/videocourts-api/routes/court_integrations.py" << 'PY'
from fastapi import APIRouter
from ..config import get_settings
from ...integrations.tyler import push_case_metadata_to_tyler

router = APIRouter()
settings = get_settings()


@router.post("/tyler/push-case/{case_id}")
async def tyler_push_case(case_id: str):
    """
    Placeholder for Tyler Technologies / CMS integration.
    You will plug in real endpoints + auth here.
    """
    ok, msg = await push_case_metadata_to_tyler(case_id, settings)
    return {"success": ok, "message": msg}
PY

# ================================
# services/totalrecall/totalrecall_engine.sh
# (trimmed but real)
# ================================
mkdir -p "$HOME/TotalRecall/evidence_vault"
cat > "$ROOT/services/totalrecall/totalrecall_engine.sh" << 'BASH'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

EVIDENCE_VAULT="${EVIDENCE_VAULT:-$HOME/TotalRecall/evidence_vault}"
BLOCKCHAIN_MANIFEST="$EVIDENCE_VAULT/blockchain_manifest.txt"

mkdir -p "$EVIDENCE_VAULT"

if [ ! -f "$BLOCKCHAIN_MANIFEST" ]; then
  {
    echo "# TotalRecall™ Blockchain Manifest"
    echo "# Generated: $(date -Iseconds)"
    echo "# Genesis Block"
    echo
  } > "$BLOCKCHAIN_MANIFEST"
fi

ingest_evidence() {
  local file_path="$1"
  local case_id="${2:-unknown}"
  local description="${3:-Evidence file}"

  if [ ! -f "$file_path" ]; then
    echo "❌ File not found: $file_path" >&2
    return 1
  fi

  local timestamp filename hash size evidence_id vault_path chain_link last_line
  timestamp=$(date -Iseconds)
  filename=$(basename "$file_path")
  hash=$(sha256sum "$file_path" | cut -d' ' -f1)
  size=$(wc -c < "$file_path")
  evidence_id="EVD_${case_id}_$(date +%Y%m%d_%H%M%S)_${hash:0:8}"

  vault_path="$EVIDENCE_VAULT/$case_id"
  mkdir -p "$vault_path"
  cp "$file_path" "$vault_path/$filename"

  last_line=$(tail -n 1 "$BLOCKCHAIN_MANIFEST" || echo "GENESIS")
  chain_link=$(echo "$hash$last_line" | sha256sum | cut -d' ' -f1)

  cat >> "$BLOCKCHAIN_MANIFEST" << EVID
[EVIDENCE BLOCK]
Evidence_ID: $evidence_id
Case_ID: $case_id
Timestamp: $timestamp
Filename: $filename
SHA256_Hash: $hash
File_Size: $size bytes
Description: $description
Chain_Link: $chain_link
Vault_Path: $vault_path/$filename
---

EVID

  echo "✅ Evidence ingested: $evidence_id"
  echo "Location: $vault_path/$filename"
}

generate_forensic_report() {
  local case_id="$1"
  local output_file="${2:-forensic_report_${case_id}.txt}"

  {
    echo "════════ VIDEOCOURTS / TOTALRECALL FORENSIC REPORT ════════"
    echo "Case ID: $case_id"
    echo "Generated: $(date -Iseconds)"
    echo
    echo "EVIDENCE BLOCKS:"
    echo
    grep -A 10 "Case_ID: $case_id" "$BLOCKCHAIN_MANIFEST" || echo "No evidence yet."
  } > "$output_file"

  echo "✅ Forensic report generated: $output_file"
}

export_for_cmecf() {
  local case_id="$1"
  local export_dir="$EVIDENCE_VAULT/cmecf_export_${case_id}"

  mkdir -p "$export_dir"
  cp -r "$EVIDENCE_VAULT/$case_id"/* "$export_dir/" 2>/dev/null || true
  generate_forensic_report "$case_id" "$export_dir/Forensic_Report.txt"

  echo "✅ CM/ECF export directory: $export_dir"
}

case "${1:-help}" in
  ingest)
    ingest_evidence "$2" "${3:-default}" "${4:-Evidence file}"
    ;;
  report)
    generate_forensic_report "$2" "${3:-}"
    ;;
  export)
    export_for_cmecf "$2"
    ;;
  *)
    echo "TotalRecall Engine"
    echo "Usage:"
    echo "  $0 ingest <file> [case_id] [description]"
    echo "  $0 report <case_id> [out]"
    echo "  $0 export <case_id>"
    ;;
esac
BASH
chmod +x "$ROOT/services/totalrecall/totalrecall_engine.sh"

# ================================
# services/totalrecall/client.py
# ================================
mkdir -p "$ROOT/services/totalrecall"
cat > "$ROOT/services/totalrecall/client.py" << 'PY'
import subprocess
from pathlib import Path
from typing import Tuple

from ..apps.videocourts-api.config import Settings
from ..apps.videocourts-api.models import EvidenceIngestRequest


def _run_cmd(cmd: list[str]) -> Tuple[bool, str, str]:
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=60
        )
        ok = result.returncode == 0
        return ok, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return False, "", str(e)


def ingest_via_totalrecall(payload: EvidenceIngestRequest, settings: Settings):
    engine = Path(settings.totalrecall_engine)
    cmd = ["bash", str(engine), "ingest", payload.file_path, payload.case_id, payload.description]
    return _run_cmd(cmd)


def generate_report_via_totalrecall(case_id: str, settings: Settings):
    engine = Path(settings.totalrecall_engine)
    cmd = ["bash", str(engine), "report", case_id]
    return _run_cmd(cmd)


def export_cmecf_via_totalrecall(case_id: str, settings: Settings):
    engine = Path(settings.totalrecall_engine)
    cmd = ["bash", str(engine), "export", case_id]
    ok, out, err = _run_cmd(cmd)
    export_path = ""
    for line in out.splitlines():
        if "cmecf_export_" in line:
            export_path = line.split(":")[-1].strip()
    return ok, out or err, export_path
PY

# ================================
# services/identity-gateway/gateway.py + client.py
# ================================
mkdir -p "$ROOT/services/identity-gateway"
cat > "$ROOT/services/identity-gateway/gateway.py" << 'PY'
#!/usr/bin/env python3
"""
Minimal identity gateway stub.

In real deployment, this would:
- talk to FacePrintPay / ID.me / etc.
- verify biometric tokens
- apply risk scoring
- emit signed access tokens
"""
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Identity Gateway Stub")


class IdentityCheckIn(BaseModel):
    user_id: str
    full_name: str
    case_id: str
    role: str
    device_id: str | None = None
    biometric_token: str | None = None


@app.post("/check")
async def check_identity(payload: IdentityCheckIn):
    # MVP: always approve with dummy risk and token
    return {
        "success": True,
        "reason": "MVP-APPROVED",
        "risk_score": 0.02,
        "issued_access_token": f"TOK-{payload.user_id}-{payload.case_id}",
    }
PY

cat > "$ROOT/services/identity-gateway/client.py" << 'PY'
import httpx

from ...apps.videocourts-api.models import IdentityCheckRequest, IdentityCheckResult
from ...apps.videocourts-api.config import Settings


async def perform_identity_check(payload: IdentityCheckRequest, settings: Settings) -> IdentityCheckResult:
    """
    Calls the identity gateway (FacePrintPay / ID provider).
    For now this talks to our local stub at http://127.0.0.1:8100/check
    """
    base_url = settings.id_provider_base_url or "http://127.0.0.1:8100"
    url = f"{base_url}/check"

    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.post(
            url,
            json={
                "user_id": payload.user_id,
                "full_name": payload.full_name,
                "case_id": payload.case_id,
                "role": payload.role,
                "device_id": payload.device_id,
                "biometric_token": payload.biometric_token,
            },
        )
        data = resp.json()

    return IdentityCheckResult(
        success=data.get("success", False),
        reason=data.get("reason"),
        risk_score=data.get("risk_score"),
        issued_access_token=data.get("issued_access_token"),
    )
PY

# ================================
# integrations/tyler.py (stub)
# ================================
cat > "$ROOT/integrations/tyler.py" << 'PY'
"""
Tyler Technologies / court CMS integration STUB.

This file is intentionally a placeholder.

You will:
- plug in real base URLs
- use requests/httpx with auth
- map your Case_ID, session data, and evidence metadata
to whatever the court's CMS / Tyler endpoints expect.
"""
import asyncio
from ..apps.videocourts-api.config import Settings


async def push_case_metadata_to_tyler(case_id: str, settings: Settings):
    # For now, just simulate success.
    await asyncio.sleep(0.1)
    msg = (
        f"[MVP STUB] Would push case metadata for {case_id} to "
        f"{settings.tyler_base_url or 'TYLER_NOT_CONFIGURED'}"
    )
    return True, msg
PY

# ================================
# infra helpers
# ================================
cat > "$ROOT/infra/run_api.sh" << 'BASH'
#!/data/data/com.termux/files/usr/bin/bash
cd "$(dirname "$0")/.."

export PYTHONPATH="$PWD"
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

uvicorn apps.videocourts-api.main:app --host 0.0.0.0 --port 8000
BASH
chmod +x "$ROOT/infra/run_api.sh"

cat > "$ROOT/infra/run_identity_gateway.sh" << 'BASH'
#!/data/data/com.termux/files/usr/bin/bash
cd "$(dirname "$0")/.."
uvicorn services.identity-gateway.gateway:app --host 0.0.0.0 --port 8100
BASH
chmod +x "$ROOT/infra/run_identity_gateway.sh"

echo ""
echo "✅ VideoCourts MVP stack scaffolded at $ROOT"
echo ""
echo "Next steps:"
echo "  cd $ROOT"
echo "  cp .env.example .env   # and edit secrets"
echo "  pip install fastapi uvicorn httpx pydantic"
echo ""
echo "Run identity gateway stub:"
echo "  ./infra/run_identity_gateway.sh"
echo ""
echo "Run VideoCourts API:"
echo "  ./infra/run_api.sh"
echo ""
echo "Your web UI:"
echo "  Put your big VideoCourts HTML page as:"
echo "    $ROOT/apps/videocourts-web/index.html"
echo "  (serve it with 'python -m http.server' or any static host)"
echo ""
echo "API endpoints (once running):"
echo "  GET  /api/health/"
echo "  POST /api/identity/check"
echo "  POST /api/sessions/"
echo "  POST /api/evidence/ingest"
echo "  GET  /api/forensic/report/{case_id}"
echo "  POST /api/forensic/export/{case_id}"
echo "  POST /api/courts/tyler/push-case/{case_id}"
echo ""
