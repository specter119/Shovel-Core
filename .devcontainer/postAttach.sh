#!/usr/bin/env bash

set -e

C_RED=$(tput setaf 1)
C_GREEN=$(tput setaf 2)
C_WARN=$(tput setaf 3)
C_NORMAL=$(tput sgr0)

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
ZSHENVFILE="${ZDOTDIR}/.zshenv"
SCOOP=/home/vscode/Shovel
SCOOP_HOME=${SCOOP}/apps/scoop/current
SCOOP_GLOBAL=/opt/Shovel
SHOVEL=${SCOOP}
SHOVEL_HOME=${SCOOP_HOME}
SHOVEL_GLOBAL=${SCOOP_GLOBAL}
PATH=${PATH}:${SHOVEL}/shims:${SHOVEL_GLOBAL}/shims

if [ -f "${SHOVEL}/shims/shovel.cmd" ]; then
    printf "${C_GREEN}Already done${C_NORMAL}\n"
    exit 0
fi

echo "$profileString" >> "${ZSHENVFILE}"

mkdir -p "${ZDOTDIR}/.config/scoop"
sudo mkdir -p "${ZDOTDIR}/Shovel/shims" "${SHOVEL_GLOBAL}/shims"
sudo chown -R "${USERNAME}:${USERNAME}" "${SHOVEL}"

wget --quiet --output-document="${ZDOTDIR}/.config/scoop/config.json" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/config.json'
wget --quiet --output-document="${SHOVEL}/shims/shovel" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/shovel'
wget --quiet --output-document="${SHOVEL}/shims/shovel.ps1" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/shovel.ps1'
wget --quiet --output-document="${SHOVEL}/shims/shovel.cmd" 'https://raw.githubusercontent.com/shovel-org/Dockers/main/support/shovel.cmd'

chmod +x "${SHOVEL}/shims/shovel"*
pwsh --version 2>/dev/null || sudo chmod +x /usr/local/bin/pwsh

printf "${C_GREEN}Shovel setup finished${C_NORMAL}\n"

arch=$(uname -m)
yqarch='amd64'
if [ "${arch}" = 'aarch64' ] || [ "${arch}" = 'arm64' ]; then
    yqarch='arm64'
fi

printf "${C_WARN}Downloading yq ${C_NORMAL}\n"

LYQ=/usr/local/bin/yq
sudo wget -qO $LYQ "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${yqarch}"
sudo chmod +x $LYQ

# Custom scripts
done=0
for fn in "$(find "${SHOVEL_HOME}/.devcontainer/" -iname '*.custom.*sh')"; do
    chmod +x "${fn}"
    printf "${C_WARN}Importing ${fn} custom script ${C_NORMAL}\n"

    . "$fn"
    done=$(( done + 1))
done

if [ "$done" -ne 0 ]; then
    printf "${C_GREEN}Included ${done} custom scripts ${C_NORMAL}\n"
else
    printf "${C_GREEN}All done ${C_NORMAL}\n"
fi
