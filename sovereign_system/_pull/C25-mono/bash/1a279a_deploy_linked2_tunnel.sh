#!/bin/bash

echo "🚀 Starting Linked2VisualUI Deployment via Vercel Tunnel..."

# Ensure Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
  echo "🛠️ Installing Vercel CLI..."
  npm install -g vercel
fi

# Clone the AiKre8tive-Stargate repo if not already cloned
if [ ! -d "AiKre8tive-Stargate" ]; then
  git clone https://github.com/TheKre8tive/AiKre8tive-Stargate.git
fi

cd AiKre8tive-Stargate

# Create or overwrite the Linked2VisualUI.jsx component
mkdir -p src/components
cat > src/components/Linked2VisualUI.jsx <<EOF
import React, { useState } from 'react';
import { motion } from 'framer-motion';

const systems = [
  {
    id: 'nlp2code',
    title: 'NLP2CODE Engine',
    description: 'Natural language → full code stacks → push to repo.',
    links: ['pushToRepo()', 'GitHub Integration', 'ChatGPT Hooks'],
  },
  {
    id: 'scaf',
    title: 'SCAF Container',
    description: 'Secure Cloud Authenticated Framework with DNA sync.',
    links: ['VerseDNA Sync', 'Keyed Auth', 'Biometric Sync'],
  },
  {
    id: 'burst',
    title: 'BurstDNA',
    description: 'Rapid-deploy module for Verse interpretation + commands.',
    links: ['AI Summary', 'SCAF Merge', 'Command Relay'],
  },
  {
    id: 'deck',
    title: 'CommandDeck UI',
    description: 'Visual AI controller linked to ChatGPT and Vercel.',
    links: ['Deploy Button', 'Agent Triggers', 'Realtime Log View'],
  },
  {
    id: 'linked2',
    title: 'Linked2 Root UI',
    description: 'This node links all modules into a deployable chain.',
    links: ['Map View', 'Vercel Sync', 'Launch Pipeline'],
  },
];

export default function Linked2VisualUI() {
  const [active, setActive] = useState(null);

  return (
    <div className="min-h-screen bg-black text-white p-6 grid grid-cols-1 md:grid-cols-3 gap-6">
      {systems.map((sys) => (
        <motion.div
          key={sys.id}
          className={\`rounded-xl border border-gray-600 bg-gray-900/70 p-5 backdrop-blur hover:bg-gray-800 cursor-pointer transition duration-300 \${active === sys.id ? 'ring-2 ring-purple-400' : ''}\`}
          onClick={() => setActive(active === sys.id ? null : sys.id)}
          whileHover={{ scale: 1.03 }}
        >
          <h2 className="text-xl font-bold mb-2">{sys.title}</h2>
          <p className="text-sm text-gray-300">{sys.description}</p>
          {active === sys.id && (
            <div className="mt-4">
              <ul className="text-sm list-disc list-inside text-purple-300">
                {sys.links.map((link) => (
                  <li key={link}>{link}</li>
                ))}
              </ul>
              <div className="mt-4">
                <a
                  href={\`https://linked2.xyz/\${sys.id}\`}
                  className="inline-block px-4 py-2 rounded bg-purple-600 hover:bg-purple-700 text-white"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Open {sys.title}
                </a>
              </div>
            </div>
          )}
        </motion.div>
      ))}
    </div>
  );
}
EOF

echo "📦 Component injected. Running Vercel deployment..."

# Deploy using Vercel CLI
vercel --prod

