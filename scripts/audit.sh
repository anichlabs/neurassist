#!/usr/bin/env bash
set -e

mkdir -p ip_evidence

DATE=$(date +%Y-%m-%d)
OUT="ip_evidence/commit_log_${DATE}.txt"
LOG="ip_evidence/AUTHORSHIP_LOG.md"

echo "Creating authorship proof for $(pwd) at ${DATE}"

# 1. Export commit history snapshot
git log --format="%H %ad %s" > "$OUT"
echo "Repo: $(git config --get remote.origin.url)" >> "$OUT"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)" >> "$OUT"

# 2. Generate SHA256 fingerprint
sha256sum "$OUT" > "${OUT}.sha256"

# 3. Submit to OpenTimestamps
ots stamp "${OUT}.sha256"

# 4. Try verification (some timestamps need hours to confirm)
VERIFY_OUTPUT=$(ots verify "${OUT}.sha256.ots" 2>&1 || true)
VERIFY_STATUS="Pending"
if echo "$VERIFY_OUTPUT" | grep -q "Success"; then
    VERIFY_STATUS="Confirmed"
fi

# 5. Append Markdown log entry
{
    echo ""
    echo "### ${DATE}"
    echo "- **Repo:** $(basename $(pwd))"
    echo "- **Branch:** $(git rev-parse --abbrev-ref HEAD)"
    echo "- **Commit Count:** $(git rev-list --count HEAD)"
    echo "- **SHA256:** \`$(cut -d' ' -f1 ${OUT}.sha256)\`"
    echo "- **Proof File:** \`${OUT}.sha256.ots\`"
    echo "- **Verification:** ${VERIFY_STATUS}"
} >> "$LOG"

echo "Timestamp created and logged -> ${OUT}.sha256.ots"
echo "Log updated: ${LOG}"
