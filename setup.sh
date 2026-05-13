#!/bin/bash
set -e

IMAGE_NAME="spider-rd/devops-induction-26"
CONTAINER_NAME="spider-audit-env"
SSH_PORT=2222

print_instructions() {
    echo ""
    echo "════════════════════════════════════════════════"
    echo ""
    echo "  The environment is ready."
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
}
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

echo "[*] Building environment..."
docker build -t $IMAGE_NAME . -q

echo "[*] Starting container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $SSH_PORT:22 \
    --cap-add SYS_ADMIN \
    $IMAGE_NAME > /dev/null

echo "[*] Waiting for SSH..."
sleep 4

print_instructions