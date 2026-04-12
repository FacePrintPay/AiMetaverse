import { useState } from 'react';

export default function Obx7Prompt() {
  const [status, setStatus] = useState<string | null>(null);

  const send = async (action: string) => {
    const r = await fetch('/api/obx7', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action,
        token: localStorage.getItem('voice_token')
      })
    });
    const j = await r.json();
    setStatus(j.message);
  };

  return (
    <div className="rounded-xl border p-4 bg-black/70 text-teal-300 max-w-md">
      <p className="mb-4">🧠 OBX-7 suggests running the WhisperGraphAgent.<br/>Proceed?</p>
      <div className="flex gap-3">
        <button onClick={() => send('run_whisper_graph_agent')}
                className="px-4 py-2 rounded bg-emerald-500 hover:bg-emerald-400">
          ✅ Yes
        </button>
        <button onClick={() => send('cancel')}
                className="px-4 py-2 rounded bg-rose-600 hover:bg-rose-500">
          ❌ No
        </button>
      </div>
      {status && <p className="mt-3 text-sm">{status}</p>}
    </div>
  );
}
