#!/usr/bin/env bash
# Synced from plugins/zvec-grep.version in the source repository.
ZG_PACKAGE="@zvec/zvec-grep@0.3.1"
ZG_ALLOW_SCRIPTS="--allow-scripts=@zvec/zvec-grep"

# npm 11.16 added --allow-scripts. Older npm runs install scripts by default and warns
# "Unknown cli config" about the flag, so pass it only to an npm that knows it.
# Sets ZG_NPM_ALLOW to the flag or to an empty string; an unknown npm keeps the flag.
zg_detect_allow_scripts() {
  [[ -n "${ZG_NPM_ALLOW+set}" ]] && return 0
  local version major minor
  version=$(npm --version 2>/dev/null) || version=""
  IFS=. read -r major minor _ <<<"$version"
  ZG_NPM_ALLOW="$ZG_ALLOW_SCRIPTS"
  if [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ ]] && (( major < 11 || (major == 11 && minor < 16) )); then
    ZG_NPM_ALLOW=""
  fi
}

zg_has_pinned_version() {
  local version
  version=$(zg --version 2>/dev/null) && [[ "$version" == "${ZG_PACKAGE##*@}" ]]
}

zg_run() {
  if zg_has_pinned_version; then
    zg "$@"
  elif command -v npx >/dev/null 2>&1; then
    zg_detect_allow_scripts
    npx --yes ${ZG_NPM_ALLOW:+"$ZG_NPM_ALLOW"} "$ZG_PACKAGE" "$@"
  else
    printf 'Install Node.js with npx or put zg %s on PATH.\n' "${ZG_PACKAGE##*@}" >&2
    return 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  zg_run "$@"
fi
