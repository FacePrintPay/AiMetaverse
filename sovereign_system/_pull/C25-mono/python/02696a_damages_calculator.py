#!/usr/bin/env python3
# ════════════════════════════════════════════════════════════════
# DAMAGES CALCULATOR – WHITE v. GOOGLE LLC
# Computes financial damages based on supplied values
# ════════════════════════════════════════════════════════════════

import json
from datetime import datetime

# Base damages
lost_revenue = 400_000_000     # Proven monetization opportunity lost
unjust_enrichment = 300_000_000  # Google profit derived from use
development_costs = 40_000       # Hard costs (hosting, storage, licenses)
forensic_costs = 60_000          # Evidence acquisition + expert fees
emotional_distress = 1_000_000   # Personal damages

combined_total = (
    lost_revenue
    + unjust_enrichment
    + development_costs
    + forensic_costs
    + emotional_distress
)

# Treble damages under NC UDTPA
treble_damages = combined_total * 3

# Settlement positioning values
opening_demand = 100_000_000
justified_maximum = treble_damages
realistic_range_low = 15_000_000
realistic_range_high = 35_000_000
minimum_acceptable = 10_000_000

data = {
    "case": "WHITE v. GOOGLE LLC",
    "generated": datetime.utcnow().isoformat(),
    "components": {
        "lost_revenue": lost_revenue,
        "unjust_enrichment": unjust_enrichment,
        "development_costs": development_costs,
        "forensic_costs": forensic_costs,
        "emotional_distress": emotional_distress,
    },
    "combined_total": combined_total,
    "treble_damages": treble_damages,
    "settlement_positioning": {
        "opening_demand": opening_demand,
        "justified_maximum": justified_maximum,
        "realistic_range": [realistic_range_low, realistic_range_high],
        "minimum_acceptable": minimum_acceptable,
    },
}

# Write JSON output
out = "/data/data/com.termux/files/home/TotalRecall/complaint_project/strategic_tools/damages/damages_report.json"
with open(out, "w") as f:
    json.dump(data, f, indent=4)

print("✅ Damages report generated:")
print(f"   File: {out}")
print(f"   Total: ${combined_total:,.0f}")
print(f"   Treble: ${treble_damages:,.0f}")
