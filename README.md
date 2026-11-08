# derp-rules
GitHub-hosted rule set pinning **Tailscale DERP data-plane** traffic to DIRECT, shared by Surge and mihomo/FlClash clients.

Why: proxy chains (Surge FINAL / FlClash TUN) capture Tailscale's IP-based DERP/STUN connections, polluting endpoints and forcing relays through far-away proxy nodes. Pinning DERP IPs DIRECT restores honest endpoint discovery.

## Surge usage
In `[Rule]`, before any FINAL/fallback rules:
```
RULE-SET,https://raw.githubusercontent.com/wustyu/derp-rules/main/derp.list,DIRECT
```

## mihomo / FlClash usage
```yaml
rule-providers:
  derp:
    type: http
    behavior: classical
    format: text
    url: "https://raw.githubusercontent.com/wustyu/derp-rules/main/derp.list"
    path: ./rules/derp.list
    interval: 604800
rules:
  - RULE-SET,derp,DIRECT
  # ... rest of rules
```

## Updates
Regenerated from `controlplane.tailscale.com/derpmap/default` by `generate.sh` (cron: first day of each month, runs on the home gateway Mac mini).
