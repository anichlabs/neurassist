#!/usr/bin/env bash
set -e

EVIDENCE_DIR="ip_evidence"
LOG_FILE="${EVIDENCE_DIR}/AUTHORSHIP_LOG.md"

echo "🔍 Verifying all OpenTimestamps proofs in ${EVIDENCE_DIR}..."

# Ensure the log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "# Authorship Verification Log" > "$LOG_FILE"
fi

# Loop over all .ots files
for ots_file in ${EVIDENCE_DIR}/*.ots; do
    [ -e "$ots_file" ] || { echo "No .ots files found."; exit 0; }

    base_name=$(basename "$ots_file" .ots)
    sha_file="${EVIDENCE_DIR}/${base_name}"
    date_label=$(echo "$base_name" | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "unknown")

    echo "→ Verifying ${ots_file} ..."
    VERIFY_OUTPUT=$(ots verify "$ots_file" 2>&1 || true)
    STATUS="Pending"

    if echo "$VERIFY_OUTPUT" | grep -q "Success"; then
        STATUS="Confirmed"
    fi

    SHA=$(cut -d' ' -f1 "${sha_file}" 2>/dev/null || echo "n/a")

    # Append result to log
    {
        echo ""
        echo "### ${date_label}"
        echo "- **Proof:** \`${ots_file}\`"
        echo "- **SHA256:** \`${SHA}\`"
        echo "- **Status:** ${STATUS}"
        echo "- **Verified on:** $(date '+%Y-%m-%d %H:%M:%S')"
    } >> "$LOG_FILE"

    echo "   ${STATUS}: logged."
done

echo "Verification complete. Log updated at ${LOG_FILE}"
