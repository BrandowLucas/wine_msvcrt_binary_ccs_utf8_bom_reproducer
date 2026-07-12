#!/usr/bin/env bash

set -Eeuo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly WINE="${WINE:-wine}"
readonly WINE_PREFIX="${WINEPREFIX:-${HOME}/.winetest}"
readonly OUTPUT_DIR="${OUT_DIR:-${ROOT_DIR}/out-wine}"
readonly OUTPUT_FILE="${OUTPUT_DIR}/ccs-utf8-output.bin"
readonly WINDOWS_OUTPUT_FILE="Z:${OUTPUT_FILE//\//\\}"

if [[ ! -x "${ROOT_DIR}/bin/ccs_utf8_bom_probe.exe" ]]; then
    printf '[ERROR] Probe missing | path=%s\n' "${ROOT_DIR}/bin/ccs_utf8_bom_probe.exe" >&2
    exit 1
fi
if ! command -v "${WINE}" >/dev/null 2>&1 && [[ ! -x "${WINE}" ]]; then
    printf '[ERROR] Wine missing | wine=%s\n' "${WINE}" >&2
    exit 1
fi

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

env WINEPREFIX="${WINE_PREFIX}" WINEDEBUG=-all WINEDBG=-none \
    "${WINE}" "${ROOT_DIR}/bin/ccs_utf8_bom_probe.exe" "${WINDOWS_OUTPUT_FILE}" \
    | tee "${OUTPUT_DIR}/run.log"

printf '[INFO] Run completed | output=%s\n' "${OUTPUT_FILE}"
