#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO="${REPO_ROOT:-$HOME/Kre8tiveKonceptz_RepoDepo}"
OUT="${HOME}/outputs/web/agi-kre8tive"
APP_DIR="${REPO}/apps/agi-kre8tive"
ENV_SH="$HOME/SovereignVault/env.sh"
AGENTS_SH="$HOME/agents/agent_definitions.sh"

say(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
mkdir -p "$OUT" "$APP_DIR"

# 1) Write landing page to RepoDepo + Outputs
PAGE="$APP_DIR/index.html"
cat > "$PAGE" <<'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>AGI KRE8TIVE — Autonomous Agents for Builders</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>.glass{backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);}</style>
  </head>
  <body class="min-h-screen bg-slate-950 text-slate-100">
    <div class="pointer-events-none fixed inset-0">
      <div class="absolute -top-32 left-1/2 h-72 w-[42rem] -translate-x-1/2 rounded-full bg-indigo-600/20 blur-3xl"></div>
      <div class="absolute top-40 right-[-10rem] h-72 w-72 rounded-full bg-fuchsia-500/15 blur-3xl"></div>
      <div class="absolute bottom-[-10rem] left-[-10rem] h-80 w-80 rounded-full bg-cyan-500/10 blur-3xl"></div>
    </div>

    <header class="sticky top-0 z-50 border-b border-white/10 bg-slate-950/70 glass">
      <div class="mx-auto flex max-w-7xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
        <div class="flex items-center gap-3">
          <div class="grid h-9 w-9 place-items-center rounded-xl bg-white/10 ring-1 ring-white/15">
            <span class="text-sm font-black tracking-tight">AK</span>
          </div>
          <div>
            <div class="text-sm font-semibold tracking-wide text-slate-200">AGI KRE8TIVE</div>
            <div class="text-xs text-slate-400">Autonomous agents + multi-agent execution</div>
          </div>
        </div>

        <nav class="hidden items-center gap-6 md:flex">
          <a class="text-sm text-slate-300 hover:text-white" href="#product">Product</a>
          <a class="text-sm text-slate-300 hover:text-white" href="#agent">Agent</a>
          <a class="text-sm text-slate-300 hover:text-white" href="#api">Agent API</a>
          <a class="text-sm text-slate-300 hover:text-white" href="#compare">Why us</a>
          <a class="text-sm text-slate-300 hover:text-white" href="#faq">FAQ</a>
        </nav>

        <div class="flex items-center gap-3">
          <a href="#get-started" class="hidden rounded-xl bg-white px-4 py-2 text-sm font-semibold text-slate-950 hover:bg-slate-100 md:inline-flex">
            Get Started Now
          </a>
          <button id="menuBtn"
            class="inline-flex items-center justify-center rounded-xl bg-white/10 px-3 py-2 text-sm font-semibold text-white ring-1 ring-white/15 hover:bg-white/15 md:hidden"
            aria-expanded="false" aria-controls="mobileMenu">
            AGI KRE8TIVE: Menu
          </button>
        </div>
      </div>

      <div id="mobileMenu" class="hidden border-t border-white/10 bg-slate-950/80 glass md:hidden">
        <div class="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
          <div class="grid gap-3">
            <a class="rounded-lg bg-white/5 px-3 py-2 text-sm text-slate-200 hover:bg-white/10" href="#product">Product</a>
            <a class="rounded-lg bg-white/5 px-3 py-2 text-sm text-slate-200 hover:bg-white/10" href="#agent">Agent</a>
            <a class="rounded-lg bg-white/5 px-3 py-2 text-sm text-slate-200 hover:bg-white/10" href="#api">Agent API</a>
            <a class="rounded-lg bg-white/5 px-3 py-2 text-sm text-slate-200 hover:bg-white/10" href="#compare">Why us</a>
            <a class="rounded-lg bg-white/5 px-3 py-2 text-sm text-slate-200 hover:bg-white/10" href="#faq">FAQ</a>
            <a href="#get-started" class="rounded-xl bg-white px-4 py-2 text-center text-sm font-semibold text-slate-950 hover:bg-slate-100">
              Get Started Now
            </a>
          </div>
        </div>
      </div>
    </header>

    <main class="relative">
      <section id="get-started" class="mx-auto max-w-7xl px-4 pt-12 sm:px-6 lg:px-8 lg:pt-20">
        <div class="grid gap-10 lg:grid-cols-2 lg:items-center">
          <div>
            <div class="inline-flex items-center gap-2 rounded-full bg-white/5 px-3 py-1 text-xs text-slate-300 ring-1 ring-white/10">
              <span class="h-1.5 w-1.5 rounded-full bg-emerald-400"></span>
              Autonomous Agents for Builders
            </div>

            <h1 class="mt-5 text-4xl font-extrabold tracking-tight sm:text-5xl">
              The best autonomous AI agent to execute your tasks
              <span class="text-indigo-300">locally or remotely</span>.
            </h1>

            <p class="mt-4 text-base leading-relaxed text-slate-300">
              Join <span class="font-semibold text-slate-200">+30M builders</span> using AGI KRE8TIVE to plan, implement,
              test, and ship — with controllable autonomy and multi-agent execution.
            </p>

            <div class="mt-6 flex flex-col gap-3 sm:flex-row sm:items-center">
              <a href="#product" class="inline-flex items-center justify-center rounded-xl bg-white px-5 py-3 text-sm font-semibold text-slate-950 hover:bg-slate-100">
                Get Started Now
              </a>
              <a href="#agent" class="inline-flex items-center justify-center rounded-xl bg-white/5 px-5 py-3 text-sm font-semibold text-white ring-1 ring-white/15 hover:bg-white/10">
                See how Agents run →
              </a>
            </div>

            <p class="mt-6 text-xs text-slate-400">
              Teams at Fortune 500 companies that depend on <span class="text-slate-200">AGI KRE8TIVE.AI</span>
            </p>
          </div>

          <div class="rounded-2xl bg-white/5 p-4 ring-1 ring-white/10">
            <div class="flex items-center justify-between gap-3 border-b border-white/10 pb-3">
              <div class="text-sm font-semibold text-slate-200">AGI KRE8TIVE.AI</div>
              <div class="text-xs text-slate-400">signal-limits-service</div>
            </div>

            <div class="mt-4 grid gap-4">
              <div class="rounded-xl bg-slate-950/40 p-4 ring-1 ring-white/10">
                <div class="flex items-center justify-between">
                  <div class="text-xs font-semibold text-slate-200">Codebase context</div>
                  <div class="text-[11px] text-slate-400">Large code base context</div>
                </div>

                <div class="mt-3 grid gap-3 sm:grid-cols-2">
                  <div class="rounded-lg bg-white/5 p-3 ring-1 ring-white/10">
                    <div class="text-xs font-semibold text-slate-200">service</div>
                    <ul class="mt-2 space-y-1 text-[11px] text-slate-300">
                      <li>RateLimiter.java</li><li>RateLimitConfig.java</li><li>RateLimitMetrics.java</li>
                    </ul>
                  </div>
                  <div class="rounded-lg bg-white/5 p-3 ring-1 ring-white/10">
                    <div class="text-xs font-semibold text-slate-200">delivery</div>
                    <ul class="mt-2 space-y-1 text-[11px] text-slate-300">
                      <li>MessageDeliveryLoop.java</li><li>NoopDeliveryLoop.java</li><li>RedisMessageDelivery.java</li>
                    </ul>
                  </div>
                  <div class="rounded-lg bg-white/5 p-3 ring-1 ring-white/10">
                    <div class="text-xs font-semibold text-slate-200">challenges</div>
                    <ul class="mt-2 space-y-1 text-[11px] text-slate-300">
                      <li>ChallengeManager.java</li><li>ChallengeOption.java</li><li>RateLimitMetrics.java</li>
                    </ul>
                  </div>
                  <div class="rounded-lg bg-white/5 p-3 ring-1 ring-white/10">
                    <div class="text-xs font-semibold text-slate-200">Task</div>
                    <p class="mt-2 text-[11px] text-slate-300">
                      Improve the rate limiting implementation. Begin with Enhanced Metrics and Observability.
                    </p>
                  </div>
                </div>
              </div>

              <div class="rounded-xl bg-slate-950/60 ring-1 ring-white/10">
                <div class="flex items-center justify-between border-b border-white/10 px-4 py-3">
                  <div class="text-xs font-semibold text-slate-200">RateLimitMetrics.java</div>
                  <div class="text-[11px] text-slate-400">Code Snippet</div>
                </div>
                <pre class="overflow-auto p-4 text-[11px] leading-relaxed text-slate-200"><code>public double requestsPerSecond() {
    long now = System.currentTimeMillis();
    long count = samples.stream().filter(t -&gt; now - t &lt;= 60_000).count();
    return count / 60.0;
}</code></pre>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="product" class="mx-auto mt-16 max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="grid gap-6 lg:grid-cols-3">
          <div class="rounded-2xl bg-white/5 p-6 ring-1 ring-white/10">
            <h3 class="text-lg font-bold">State of the art performance</h3>
            <p class="mt-2 text-sm text-slate-300">Multiple layers of protection built for strict compliance.</p>
          </div>
          <div class="rounded-2xl bg-white/5 p-6 ring-1 ring-white/10">
            <h3 class="text-lg font-bold">Agents on +35 IDEs</h3>
            <p class="mt-2 text-sm text-slate-300">Run tasks on VSCode, JetBrains & more — local or remote sandboxes.</p>
          </div>
          <div class="rounded-2xl bg-white/5 p-6 ring-1 ring-white/10">
            <h3 class="text-lg font-bold">Controllable Autonomy</h3>
            <p class="mt-2 text-sm text-slate-300">Set autonomy levels with human approvals.</p>
          </div>
        </div>
      </section>

      <section id="faq" class="mx-auto mt-16 max-w-7xl px-4 pb-20 sm:px-6 lg:px-8">
        <div class="rounded-2xl bg-white/5 p-8 ring-1 ring-white/10">
          <h2 class="text-2xl font-extrabold tracking-tight">Frequently Asked Questions</h2>
          <div class="mt-6 grid gap-4 md:grid-cols-2">
            <div class="rounded-xl bg-slate-950/40 p-5 ring-1 ring-white/10">
              <div class="text-sm font-semibold">Can I try Enterprise before committing?</div>
              <div class="mt-2 text-sm text-slate-300">Yes — generous credits for enterprise teams to test end-to-end.</div>
            </div>
            <div class="rounded-xl bg-slate-950/40 p-5 ring-1 ring-white/10">
              <div class="text-sm font-semibold">How do you ensure code privacy?</div>
              <div class="mt-2 text-sm text-slate-300">Strict security controls designed for confidentiality.</div>
            </div>
          </div>
        </div>
      </section>
    </main>

    <footer class="border-t border-white/10 bg-slate-950/60 glass">
      <div class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
        <div class="text-xs text-slate-400">© <span id="year"></span> AGI KRE8TIVE. All rights reserved.</div>
      </div>
    </footer>

    <script>
      const btn=document.getElementById("menuBtn");
      const menu=document.getElementById("mobileMenu");
      btn?.addEventListener("click",()=>{const open=!menu.classList.contains("hidden");menu.classList.toggle("hidden",open);btn.setAttribute("aria-expanded",String(!open));});
      document.getElementById("year").textContent=String(new Date().getFullYear());
    </script>
  </body>
</html>
HTML

cp -f "$PAGE" "$OUT/index.html"
chmod 600 "$PAGE" "$OUT/index.html" || true
say "✅ Landing page written:"
say " - RepoDepo: $PAGE"
say " - Swarm output: $OUT/index.html"

# 2) Add ENV vars (optional) so agents know where to drop web builds
if [ -f "$ENV_SH" ] && ! grep -q 'AGI_WEB_OUTPUT_DIR' "$ENV_SH"; then
  printf '\n# Web output (AGI KRE8TIVE landing)\nexport AGI_WEB_OUTPUT_DIR="%s"\n' "$HOME/outputs/web" >> "$ENV_SH"
  say "✅ Added AGI_WEB_OUTPUT_DIR to $ENV_SH"
fi

# 3) Add a tiny web agent handler (optional) into agent_definitions.sh if it exists
if [ -f "$AGENTS_SH" ] && ! grep -q 'agent_web_build' "$AGENTS_SH"; then
  cat >> "$AGENTS_SH" <<'SH'

# --- AGI KRE8TIVE: Web build agent (simple) ---
agent_web_build(){
  # Expects: TASK_PAYLOAD contains optional "name"
  local name="${1:-agi-kre8tive}"
  local out="${AGI_WEB_OUTPUT_DIR:-$HOME/outputs/web}/${name}"
  mkdir -p "$out"
  if [ -f "$HOME/Kre8tiveKonceptz_RepoDepo/apps/${name}/index.html" ]; then
    cp -f "$HOME/Kre8tiveKonceptz_RepoDepo/apps/${name}/index.html" "$out/index.html"
    echo "OK: wrote $out/index.html"
  else
    echo "ERR: missing source html at RepoDepo/apps/${name}/index.html"
    return 1
  fi
}
SH
  say "✅ Added agent_web_build() to $AGENTS_SH"
fi

# 4) Print next commands
say ""
say "Next:"
say " - Open page: termux-open '$OUT/index.html'"
say " - If swarm is live: send a task to build it (agent_web_build) once your send_task.sh supports it."
