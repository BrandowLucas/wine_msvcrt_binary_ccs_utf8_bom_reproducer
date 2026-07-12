#!/usr/bin/env bash

set -Eeuo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly COMPILER="${CC:-x86_64-w64-mingw32-gcc}"

if ! command -v "${COMPILER}" >/dev/null 2>&1; then
    printf '[ERROR] Compiler missing | compiler=%s\n' "${COMPILER}" >&2
    exit 1
fi

if command -v clang-format >/dev/null 2>&1; then
    clang-format -i "${ROOT_DIR}/src/ccs_utf8_bom_probe.c"
fi

mkdir -p "${ROOT_DIR}/bin"
"${COMPILER}" \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    -Wpedantic \
    "${ROOT_DIR}/src/ccs_utf8_bom_probe.c" \
    -o "${ROOT_DIR}/bin/ccs_utf8_bom_probe.exe"

printf '[INFO] Build completed | output=%s\n' "${ROOT_DIR}/bin/ccs_utf8_bom_probe.exe"
