#!/usr/bin/env bash

profileString=$(cat <<'EOF'
export SCOOP=/home/vscode/Shovel
export SCOOP_HOME=${SCOOP}/apps/scoop/current
export SCOOP_GLOBAL=/opt/Shovel
export SHOVEL=${SCOOP}
export SHOVEL_HOME=${SCOOP_HOME}
export SHOVEL_GLOBAL=${SCOOP_GLOBAL}
export PATH=${PATH}:${SHOVEL}/shims:${SHOVEL_GLOBAL}/shims
EOF
)

USERNAME=${USERNAME:-"vscode"}
ZDOTDIR=${ZDOTDIR:-$HOME}
SCOOP=/home/vscode/Shovel
SCOOP_HOME=${SCOOP}/apps/scoop/current
SCOOP_GLOBAL=/opt/Shovel
SHOVEL=${SCOOP}
SHOVEL_HOME=${SCOOP_HOME}
SHOVEL_GLOBAL=${SCOOP_GLOBAL}
PATH=${PATH}:${SHOVEL}/shims:${SHOVEL_GLOBAL}/shims

if [ -f "${SHOVEL}/shims/shovel.cmd" ]; then
    echo 'Already done. Exiting'
    exit 0
fi

echo "$profileString" >> "$ZDOTDIR/.zshenv"

mkdir -p "${ZDOTDIR}/.config/scoop"
sudo mkdir -p "${ZDOTDIR}/Shovel/shims" "${SHOVEL_GLOBAL}/shims"
sudo chown -R "${USERNAME}:${USERNAME}" "${SHOVEL}"

wget --quiet --output-document="${ZDOTDIR}/.config/scoop/config.json" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/config.json'
wget --quiet --output-document="${SHOVEL}/shims/shovel" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/shovel'
wget --quiet --output-document="${SHOVEL}/shims/shovel.ps1" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/shovel.ps1'
wget --quiet --output-document="${SHOVEL}/shims/shovel.cmd" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/shovel.cmd'

chmod +x "${SHOVEL}/shims/shovel"*
pwsh --version || sudo chmod +x /usr/local/bin/pwsh
