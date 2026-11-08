#!/bin/bash
# Regenerate derp.list from official DERPMap and push to GitHub
cd "$(dirname "$0")"
curl -4 -s -m20 https://controlplane.tailscale.com/derpmap/default -o derpmap.json || exit 1
python3 - <<'PY'
import json
d=json.load(open('derpmap.json'))
lines=["# Tailscale DERP data-plane rules (auto-generated from controlplane.tailscale.com/derpmap/default)"]
lines.append("# surge:  RULE-SET,https://raw.githubusercontent.com/wustyu/derp-rules/main/derp.list,DIRECT")
lines.append("# mihomo: rule-providers.derp.url -> this file; rules entry: - RULE-SET,derp,DIRECT")
v4=set(); v6=set()
for rid,r in sorted(d['Regions'].items(), key=lambda x:int(x[0])):
    for n in r['Nodes']:
        if n.get('IPv4'): v4.add(n['IPv4'])
        if n.get('IPv6'): v6.add(n['IPv6'].split('%')[0])
lines.append("")
lines.append("# official DERP servers (STUN udp 3478 / DERP tcp / wireguard udp 41641)")
for ip in sorted(v4): lines.append(f"IP-CIDR,{ip}/32,no-resolve")
for ip in sorted(v6): lines.append(f"IP-CIDR6,{ip}/128,no-resolve")
lines.append("")
lines.append("# self-hosted home DERP (derp.jeeyang.top)")
lines.append("IP-CIDR,144.0.19.187/32,no-resolve")
lines.append("DOMAIN-SUFFIX,derp.jeeyang.top,no-resolve")
open('derp.list','w').write("\n".join(lines)+"\n")
PY
git add derp.list derpmap.json && git commit -m "auto: refresh DERP map $(date +%F)" && git push origin main
