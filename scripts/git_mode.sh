#!/usr/bin/env bash
# Check which .gitignore mode is active (public or private)

if grep -q "PUBLIC MIRROR IGNORE" .gitignore 2>/dev/null; then
    echo "Current mode: PUBLIC (GitHub mirror safe)"
elif grep -q "PRIVATE IGNORE" .gitignore 2>/dev/null; then
    echo "Current mode: PRIVATE (Codeberg full archive)"
else
    echo "ode unknown — .gitignore does not match expected templates."
    echo "   Run ./scripts/switch_gitignore.sh [public|private] to set it manually."
fi
