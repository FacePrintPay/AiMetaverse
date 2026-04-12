import { useState, useEffect } from "react";
import agentsData from "./agents.json";

const CONFIG = {
  VERSION: "9.0.0-beta",
  // Use relative path → Vite proxy forwards to Ollama
  OLLAMA_BASE: "/api",
  DEFAULT_MODEL: "qwen2.5:7b",
  REPO_URL: "https://github.com/FacePrintPay/constellation25",
};

export default function App() {
  const [ollamaStatus, setOllamaStatus] = useState("checking");
  const [activeAgent, setActiveAgent] = useState(null);
  const [prompt, setPrompt] = useState("");
  const [output, setOutput] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);
  const [lastError, setLastError] = useState(null);

  useEffect(() => {
    const checkOllama = async () => {
      try {
        const res = await fetch(`${CONFIG.OLLAMA_BASE}/tags`);
        if (res.ok) {
          const data = await res.json();
          const hasModel = data.models?.some(m => m.name.includes(CONFIG.DEFAULT_MODEL.split(":")[0]));
          setOllamaStatus(hasModel ? "ready" : "model-missing");
        } else {
          setOllamaStatus("offline");
        }
      } catch (e) {
        setOllamaStatus("offline");
        setLastError("Cannot connect to Ollama. Ensure it's running: ollama serve");
      }
    };
    checkOllama();
  }, []);

  const handleAgentActivate = async (agent) => {
    setActiveAgent(agent);
    setIsProcessing(true);
    setLastError(null);
    setOutput(`🌟 Activating ${agent.name}-Agent...\nRole: ${agent.role}\n\nAwaiting your command...`);
    
    if (!prompt.trim()) {
      setIsProcessing(false);
      return;
    }

    try {
      const response = await fetch(`${CONFIG.OLLAMA_BASE}/generate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          model: CONFIG.DEFAULT_MODEL,
          prompt: `You are ${agent.name}-Agent (ID:${agent.id}). Role: ${agent.role}. Specialization: ${agent.desc}. 
          
Task: ${prompt}

Provide production-ready, secure, well-commented code or clear actionable instructions. Format responses with markdown-style code blocks where applicable.`,
          stream: false,
          options: { temperature: 0.2 }
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      
      if (data.error) {
        throw new Error(data.error);
      }
      
      setOutput(data.response || "⚠️ No response generated");
      
    } catch (err) {
      console.error("Agent execution error:", err);
      setLastError(`❌ ${err.message}`);
      setOutput(prev => prev + `\n\n🔧 Troubleshooting:\n• Is Ollama running? (ollama serve)\n• Is model pulled? (ollama pull ${CONFIG.DEFAULT_MODEL})\n• Check DevTools Console for details`);
    } finally {
      setIsProcessing(false);
    }
  };

  const statusConfig = {
    ready: { color: "#27c93f", label: "ONLINE", pulse: true },
    "model-missing": { color: "#f5c842", label: "MODEL MISSING", pulse: false },
    offline: { color: "#ff5f56", label: "OFFLINE", pulse: false },
    checking: { color: "#c8d0e0", label: "CHECKING...", pulse: true }
  };

  const currentStatus = statusConfig[ollamaStatus];

  return (
    <div style={{ 
      fontFamily: "system-ui, -apple-system, sans-serif", 
      maxWidth: "1400px", 
      margin: "0 auto", 
      padding: "16px", 
      background: "linear-gradient(135deg, #0a0a14 0%, #121220 100%)", 
      color: "#e8e8ff", 
      minHeight: "100vh",
      WebkitFontSmoothing: "antialiased"
    }}>
      {/* Header */}
      <header style={{ 
        textAlign: "center", 
        padding: "24px 16px", 
        borderBottom: "1px solid rgba(126, 211, 193, 0.25)",
        background: "radial-gradient(ellipse at top, rgba(126, 211, 193, 0.08) 0%, transparent 60%)"
      }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "12px", marginBottom: "8px" }}>
          <span style={{ fontSize: "1.8rem" }}>⭐</span>
          <h1 style={{ 
            margin: 0, 
            fontSize: "1.8rem", 
            background: "linear-gradient(135deg, #7ed3c1 0%, #4a90e2 100%)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            fontWeight: "700"
          }}>
            CONSTELLATION 25
          </h1>
        </div>
        <p style={{ margin: "4px 0 0", color: "#7ed3c1", fontSize: "1rem", fontWeight: "500" }}>
          Planetary Agent Orchestration System
        </p>
        <p style={{ margin: "8px 0 0", color: "#888", fontSize: "0.85rem" }}>
          v{CONFIG.VERSION} • Sovereign AI Swarm • by Cygel White (#MrGGTP)
        </p>
      </header>

      {/* Status Bar */}
      <div style={{ 
        display: "flex", 
        justifyContent: "space-between", 
        alignItems: "center", 
        padding: "12px 16px",
        background: "rgba(26, 26, 46, 0.9)",
        borderRadius: "10px",
        margin: "16px",
        border: "1px solid rgba(126, 211, 193, 0.2)",
        fontSize: "0.9rem"
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
          <span style={{ 
            width: "10px", 
            height: "10px", 
            borderRadius: "50%", 
            background: currentStatus.color,
            boxShadow: currentStatus.pulse ? `0 0 8px ${currentStatus.color}` : "none",
            animation: currentStatus.pulse ? "pulse 2s infinite" : "none"
          }}></span>
          <span>Ollama: <strong style={{ color: currentStatus.color }}>{currentStatus.label}</strong></span>
        </div>
        <div style={{ color: "#888" }}>{agentsData.agents.length} Agents</div>
        <a href={CONFIG.REPO_URL} target="_blank" rel="noopener noreferrer" 
           style={{ color: "#7ed3c1", textDecoration: "none", fontWeight: "500" }}>
          GitHub ↗
        </a>
      </div>

      {/* Error Banner */}
      {lastError && (
        <div style={{ 
          margin: "0 16px 16px", 
          padding: "12px 16px", 
          background: "rgba(255, 95, 86, 0.15)", 
          border: "1px solid #ff5f56", 
          borderRadius: "8px",
          color: "#ffb4b4",
          fontSize: "0.9rem"
        }}>
          {lastError}
        </div>
      )}

      {/* Agent Grid */}
      <section style={{ margin: "0 16px 24px" }}>
        <h2 style={{ fontSize: "1.2rem", marginBottom: "16px", color: "#7ed3c1", fontWeight: "600" }}>
          Active Agents
        </h2>
        <div style={{ 
          display: "grid", 
          gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", 
          gap: "12px" 
        }}>
          {agentsData.agents.map(agent => {
            const isActive = activeAgent?.id === agent.id;
            return (
              <button
                key={agent.id}
                onClick={() => handleAgentActivate(agent)}
                disabled={isProcessing || ollamaStatus !== "ready"}
                style={{
                  background: isActive ? "rgba(126, 211, 193, 0.12)" : "rgba(26, 26, 46, 0.9)",
                  border: `2px solid ${agent.color}`,
                  borderRadius: "10px",
                  padding: "14px",
                  textAlign: "left",
                  cursor: isProcessing || ollamaStatus !== "ready" ? "not-allowed" : "pointer",
                  opacity: isProcessing || ollamaStatus !== "ready" ? 0.5 : 1,
                  transition: "transform 0.15s, box-shadow 0.15s",
                  position: "relative",
                  overflow: "hidden"
                }}
                onMouseEnter={(e) => {
                  if (!isProcessing && ollamaStatus === "ready") {
                    e.currentTarget.style.transform = "translateY(-2px)";
                    e.currentTarget.style.boxShadow = `0 4px 12px ${agent.color}33`;
                  }
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.transform = "translateY(0)";
                  e.currentTarget.style.boxShadow = "none";
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "8px" }}>
                  <span style={{ 
                    width: "28px", height: "28px", borderRadius: "50%", 
                    background: `linear-gradient(135deg, ${agent.color}, ${agent.color}cc)`,
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontWeight: "700", fontSize: "0.85rem", color: "#0a0a14"
                  }}>
                    {agent.id}
                  </span>
                  <div>
                    <strong style={{ fontSize: "1rem", display: "block" }}>{agent.name}-Agent</strong>
                    <span style={{ fontSize: "0.8rem", color: agent.color }}>{agent.role}</span>
                  </div>
                </div>
                <p style={{ margin: 0, fontSize: "0.85rem", color: "#aaa", lineHeight: "1.4" }}>
                  {agent.desc}
                </p>
              </button>
            );
          })}
        </div>
      </section>

      {/* Command Panel */}
      <section style={{ 
        margin: "0 16px 24px",
        background: "rgba(26, 26, 46, 0.9)",
        borderRadius: "12px",
        padding: "20px",
        border: "1px solid rgba(126, 211, 193, 0.2)"
      }}>
        <label style={{ 
          display: "block", 
          marginBottom: "12px", 
          fontWeight: "600",
          color: "#7ed3c1",
          fontSize: "1.05rem"
        }}>
          {activeAgent ? (
            <>🎯 <span style={{color: activeAgent.color}}>{activeAgent.name}-Agent</span> Active</>
          ) : (
            "👆 Select an agent above to begin"
          )}
        </label>
        
        <textarea
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          placeholder={activeAgent 
            ? `Describe your task for ${activeAgent.name}-Agent...` 
            : "Select an agent first"}
          disabled={!activeAgent || ollamaStatus !== "ready"}
          style={{
            width: "100%", 
            minHeight: "100px", 
            padding: "14px", 
            borderRadius: "8px",
            background: "rgba(10, 10, 20, 0.95)", 
            border: "1px solid rgba(126, 211, 193, 0.3)", 
            color: "#e8e8ff",
            fontFamily: "ui-monospace, SFMono-Regular, monospace", 
            fontSize: "0.95rem", 
            resize: "vertical",
            outline: "none",
            lineHeight: "1.5"
          }}
        />
        
        <button
          onClick={() => activeAgent && handleAgentActivate(activeAgent)}
          disabled={!activeAgent || !prompt.trim() || isProcessing || ollamaStatus !== "ready"}
          style={{
            marginTop: "16px",
            background: ollamaStatus === "ready" && activeAgent && prompt.trim()
              ? `linear-gradient(135deg, ${activeAgent.color}, ${activeAgent.color}cc)`
              : "#2a2a42",
            color: ollamaStatus === "ready" && activeAgent && prompt.trim() ? "#0a0a14" : "#666",
            border: "none", 
            padding: "14px 28px", 
            borderRadius: "8px",
            fontWeight: "600", 
            fontSize: "1rem",
            cursor: isProcessing ? "wait" : "pointer",
            opacity: (!activeAgent || !prompt.trim() || isProcessing || ollamaStatus !== "ready") ? 0.5 : 1,
            transition: "all 0.2s",
            width: "100%",
            maxWidth: "320px",
            display: "block",
            marginLeft: "auto",
            marginRight: "auto"
          }}
        >
          {isProcessing ? "🔄 Processing..." : "🚀 Execute Command"}
        </button>

        {output && (
          <div style={{ 
            marginTop: "20px", 
            background: "rgba(10, 10, 20, 0.95)", 
            borderRadius: "8px", 
            padding: "16px", 
            border: `1px solid ${activeAgent?.color || "#7ed3c1"}44`
          }}>
            <h3 style={{ margin: "0 0 12px", fontSize: "1rem", color: activeAgent?.color || "#7ed3c1", display: "flex", alignItems: "center", gap: "8px" }}>
              <span>📤</span> {activeAgent?.name}-Agent Output
            </h3>
            <pre style={{ 
              margin: 0, 
              whiteSpace: "pre-wrap", 
              wordBreak: "break-word", 
              fontSize: "0.9rem", 
              color: "#d0d0ff", 
              maxHeight: "400px", 
              overflowY: "auto",
              lineHeight: "1.5",
              fontFamily: "ui-monospace, SFMono-Regular, monospace"
            }}>{output}</pre>
          </div>
        )}
      </section>

      {/* Footer */}
      <footer style={{ 
        padding: "24px 16px", 
        borderTop: "1px solid rgba(126, 211, 193, 0.2)", 
        textAlign: "center", 
        color: "#666", 
        fontSize: "0.85rem",
        margin: "0 16px"
      }}>
        <p style={{ marginBottom: "8px" }}>
          🔐 Biometric-Ready • 📦 Offline-First • 🌍 Sovereign by Design
        </p>
        <p>
          Built by <strong style={{color: "#7ed3c1"}}>Cygel White (TotalRecall)</strong> • Kre8tive Holdings
        </p>
        <p style={{ marginTop: "8px", fontSize: "0.8rem", color: "#555" }}>
          Prior Art: March 2023 • Constellation-25™
        </p>
      </footer>

      {/* CSS Animations */}
      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.5; }
        }
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: #1a1a2e; }
        ::-webkit-scrollbar-thumb { background: #333; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #555; }
      `}</style>
    </div>
  );
}
