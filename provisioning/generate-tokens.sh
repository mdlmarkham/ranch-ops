#!/bin/bash
# generate-tokens.sh — Generate secure OHM tokens for Ranch agents
#
# Usage: ./generate-tokens.sh
# Outputs JSON suitable for /etc/ohm/ranch-ohmd.json tokens section

python3 -c "
import secrets, string, json

agents = ['waylon', 'clint', 'roy', 'magnus', 'virgil', 'belle', 'slim']
tokens = {}
for a in agents:
    token = 'ranch-' + a + '-u0-' + ''.join(secrets.choice(string.ascii_letters + string.digits + '_-') for _ in range(20))
    tokens[a] = token

print(json.dumps(tokens, indent=2))
"