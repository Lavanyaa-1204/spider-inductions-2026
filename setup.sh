#!/bin/bash
set -e

IMAGE_NAME="spider-rd/devops-induction-26"
CONTAINER_NAME="spider-audit-env"
SSH_PORT=2222

echo ""
echo "  ███████╗██████╗ ██╗██████╗ ███████╗██████╗ "
echo "  ██╔════╝██╔══██╗██║██╔══██╗██╔════╝██╔══██╗"
echo "  ███████╗██████╔╝██║██║  ██║█████╗  ██████╔╝"
echo "  ╚════██║██╔═══╝ ██║██║  ██║██╔══╝  ██╔══██╗"
echo "  ███████║██║     ██║██████╔╝███████╗██║  ██║"
echo "  ╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝"
echo ""
echo "  R&D Club — DevOps Induction 2026"
echo "  Basic Task: vault_sweep"
echo ""

if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed."
    echo "        Install it from https://docs.docker.com/get-docker/"
    exit 1
fi
echo "[*] Clearing any stale SSH host key for localhost:$SSH_PORT..."
ssh-keygen -R "[localhost]:${SSH_PORT}" > /dev/null 2>&1 || true
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[*] Existing environment found."
    read -p "    Reset it? This clears all your work inside the container (y/n): " RESET
    if [[ "$RESET" == "y" ]]; then
        docker rm -f $CONTAINER_NAME > /dev/null
        echo "[*] Removed old container."
    else
        echo "[*] Resuming existing environment..."
        docker start $CONTAINER_NAME > /dev/null 2>&1 || true
        sleep 2
        print_instructions
        exit 0
    fi
fi
echo "[*] Building environment... (this takes ~2 minutes the first time)"
docker build -t $IMAGE_NAME . -q
echo "[*] Starting container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $SSH_PORT:22 \
    --cap-add SYS_ADMIN \
    $IMAGE_NAME > /dev/null

echo "[*] Waiting for SSH..."
sleep 4
echo ""
echo "════════════════════════════════════════════════"
echo ""
echo "  the env is ready."
echo ""
echo "  SSH in with:"
echo "    ssh spider@localhost -p $SSH_PORT"
echo "    Password: webslinger2026"
echo ""
echo "  You'll land in: /var/www/spider-app"
echo ""
echo "  When done, copy your work out:"
echo "    bash export.sh"
echo ""
echo "  To stop the environment:"
echo "    docker stop $CONTAINER_NAME"
echo ""
echo "════════════════════════════════════════════════"
echo ""