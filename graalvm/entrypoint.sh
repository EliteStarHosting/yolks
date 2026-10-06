#!/bin/bash

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

# LagCore monitoring, switched on per server in the panel (egg variable LAGCORE_HUB_ENABLED).
# On: the current agent is fetched from the LagCore hub at every start, and only downloaded when
# it changed (curl -z). Off: the agent this manages (plugins/LagCore.jar) is removed. A LagCore the
# customer installed themselves (plugins/LagCore-<version>.jar) is never touched. The startup line
# here runs without a shell (exec env), which is why this lives in the image and not in the egg.
LC_JAR=plugins/LagCore.jar
case "${LAGCORE_HUB_ENABLED:-0}" in
  1|true|yes|on)
    if ls plugins/LagCore-*.jar >/dev/null 2>&1; then
      echo "LagCore: a LagCore you installed yourself is in plugins/; leaving it as it is."
    elif [ -z "${LAGCORE_HUB_TOKEN}" ]; then
      echo "LagCore: switched on, but the egg has no LAGCORE_HUB_TOKEN; not installing."
    else
      mkdir -p plugins
      LC_ARGS=(-fsSL --max-time 30 --oauth2-bearer "${LAGCORE_HUB_TOKEN}" -o plugins/.LagCore.jar.part)
      [ -f "$LC_JAR" ] && LC_ARGS+=(-z "$LC_JAR")
      curl "${LC_ARGS[@]}" "${LAGCORE_HUB_URL:-https://lc.elitestarhosting.com}/dl/lagcore.jar"
      LC_RC=$?
      if [ "$LC_RC" = "0" ]; then
        if [ -s plugins/.LagCore.jar.part ]; then
          mv -f plugins/.LagCore.jar.part "$LC_JAR"
          echo "LagCore: agent installed or updated."
        fi
      elif [ "$LC_RC" = "22" ]; then
        echo "LagCore: the hub refused the download (check LAGCORE_HUB_TOKEN); starting with what is in plugins/."
      else
        echo "LagCore: the hub could not be reached; starting with what is in plugins/."
      fi
      rm -f plugins/.LagCore.jar.part
    fi
    ;;
  *)
    if [ -f "$LC_JAR" ]; then
      rm -f "$LC_JAR"
      echo "LagCore: switched off in the panel; agent removed."
    fi
    ;;
esac

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
