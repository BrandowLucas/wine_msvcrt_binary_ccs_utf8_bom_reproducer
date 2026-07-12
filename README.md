# Wine binary `ccs=UTF-8` BOM reproducer

This is a data-free reproducer for a Wine CRT incompatibility. It writes four
bytes through:

```c
fopen(path, "wb, ccs=UTF-8")
```

Native Windows preserves the four bytes. Unpatched Wine prepends `EF BB BF`,
despite the explicit binary mode.

## Expected Results

Native Windows:

```text
write_complete | path=... mode=wb,ccs=UTF-8 payload_size=4
bytes | path=... count=4 hex=00002274
```

Unpatched Wine:

```text
write_complete | path=... mode=wb,ccs=UTF-8 payload_size=4
bytes | path=... count=7 hex=efbbbf00002274
```

Patched Wine:

```text
write_complete | path=... mode=wb,ccs=UTF-8 payload_size=4
bytes | path=... count=4 hex=00002274
```

The captured reference outputs are included in `logs/windows.log`,
`logs/wine-before.log`, and `logs/wine-after.log`.

## Build

Requires an x86_64 MinGW compiler:

```sh
./build.sh
```

## Run Under Wine

```sh
WINE=/path/to/wine WINEPREFIX=/path/to/prefix ./scripts/run_wine.sh
```

`out-wine/run.log` contains the result. Set `OUT_DIR` to use a different
output location.

## Run on Windows

From `cmd.exe` in the repository:

```cmd
scripts\run_windows.cmd
```

The result is printed and saved in `out-windows/run.log`.

## Cause and Proposed Fix

`dlls/msvcrt/file.c:_wsopen_dispatch()` writes `utf8_bom` whenever the open
flags include `_O_U8TEXT`. Mode `"wb, ccs=UTF-8"` includes both `_O_U8TEXT` and
`_O_BINARY`; Wine must not synthesize a BOM in that binary case.

The proposed patch writes the UTF-8 BOM only when `_O_U8TEXT` is set and
`_O_BINARY` is not set. It preserves existing text-mode `"w, ccs=UTF-8"`
behavior and adds a regression test in `dlls/msvcrt/tests/file.c`.

See `patches/wine-msvcrt-binary-ccs-utf8-bom.patch`.

## Origin

This was reduced from a fitgirl game installer post-processing pipeline. Its
`fgpack.exe` generated a binary intermediate file with `"wb, ccs=UTF-8"`.
Wine's extra BOM shifted the stream and caused the next VCDIFF decoder to
reject it. No installer files or game data are included here.
