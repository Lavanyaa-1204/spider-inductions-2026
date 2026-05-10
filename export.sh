#!/bin/bash
CONTAINER_NAME="spider-audit-env"
OUTPUT_DIR="./my-submission"
echo "[*] Exporting your work..."
mkdir -p $OUTPUT_DIR
docker cp $CONTAINER_NAME:/home/spider/vault_sweep.sh     $OUTPUT_DIR/ 2>/dev/null && echo "  ✓ vault_sweep.sh" || echo "  ✗ vault_sweep.sh not found yet"
docker cp $CONTAINER_NAME:/home/spider/watchdog.sh        $OUTPUT_DIR/ 2>/dev/null && echo "  ✓ watchdog.sh" || echo "  - watchdog.sh (optional)"
docker cp $CONTAINER_NAME:/home/spider/REPORT.md          $OUTPUT_DIR/ 2>/dev/null && echo "  ✓ REPORT.md" || echo "  ✗ REPORT.md not found yet"
docker cp $CONTAINER_NAME:/home/spider/vault_sweep.log           $OUTPUT_DIR/ 2>/dev/null && echo "  ✓ vault_sweep.log" || echo "  ✗ vault_sweep.log not found — run your script first"
docker cp $CONTAINER_NAME:/var/www/spider-app/config/.env.sanitized $OUTPUT_DIR/ 2>/dev/null && echo "  ✓ .env.sanitized" || echo "  ✗ .env.sanitized not found — run your script first"
echo ""
echo "[*] Files saved to: $OUTPUT_DIR/"
echo "[*] Add these to your GitHub submission repo."
echo ""