# Cyclops

Experimental multi-core 2D rasterizer array implementation in SystemVerilog.

## Dependencies

- Verilator
- NVBoard (included in repo)
- SDL2 lib
- rust stable (for buffergen)

## Build & Run

```bash
NVBoard=./nvboard make run
```

## buffergen

A simple rust program for generating ram initialization file compatible with this project from images of any aspect ratio/resolution.

```bash
cd buffergen
cargo run -- -i <path-to-input-image> -o <path-to-output-image>
```
