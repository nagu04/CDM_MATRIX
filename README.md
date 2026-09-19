![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# CDM PYTHON GAME using Tiny Tapeout VGA

A hardware-rendered Snake game written in Verilog for Tiny Tapeout. It features real-time 640x480 @ 60Hz VGA output, a dynamic body growth engine, and support for both directional buttons and physical PS/2 keyboard arrow keys.

- [Read the detailed documentation](docs/info.md)

---

## How it Works

The project uses a beam-racing graphics pipeline to generate VGA video signals on-the-fly without an external SRAM framebuffer, fitting entirely within a single Tiny Tapeout 1x1 tile.

* **Video Output:** Drives a 6-bit R2R DAC VGA PMOD generating a 640x480 @ 60Hz video stream.
* **Snake Engine:** Manages head/body coordinates across a 20x15 cell grid, growing the snake's tail up to 16 segments when food is eaten.
* **Control Input:** Supports direct directional button inputs (`ui_in[3:0]`) as well as PS/2 keyboard arrow key decoding via serial communication (`ui_in[5:4]`).

---

## Pinout Mapping

| Pin | Type | Name | Function |
|---|---|---|---|
| `ui_in[0]` | Input | `UP` | Direction Button Up |
| `ui_in[1]` | Input | `DOWN` | Direction Button Down |
| `ui_in[2]` | Input | `LEFT` | Direction Button Left |
| `ui_in[3]` | Input | `RIGHT` | Direction Button Right |
| `ui_in[4]` | Input | `PS2_CLK` | PS/2 Keyboard Clock Signal |
| `ui_in[5]` | Input | `PS2_DAT` | PS/2 Keyboard Data Signal |
| `uo_out[0]`| Output| `R1` | Red Bit 1 (MSB) |
| `uo_out[1]`| Output| `G1` | Green Bit 1 (MSB) |
| `uo_out[2]`| Output| `B1` | Blue Bit 1 (MSB) |
| `uo_out[3]`| Output| `VSYNC`| Vertical Sync Signal |
| `uo_out[4]`| Output| `R0` | Red Bit 0 (LSB) |
| `uo_out[5]`| Output| `G0` | Green Bit 0 (LSB) |
| `uo_out[6]`| Output| `B0` | Blue Bit 0 (LSB) |
| `uo_out[7]`| Output| `HSYNC`| Horizontal Sync Signal |

---

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

---

## Project Setup

1. Verilog files located in `src/`:
   - `tt_um_vga_snake.v` (Top module & game engine)
   - `ps2_arrows.v` (PS/2 keyboard decoder)
2. Configured in [info.yaml](info.yaml) under `source_files` and `top_module`.
3. Project documentation located in [docs/info.md](docs/info.md).

The GitHub action will automatically build the ASIC files using [LibreLane](https://www.zerotoasiccourse.com/terminology/librelane/).

---

## Resources

- [Tiny Tapeout FAQ](https://tinytapeout.com/faq/)
- [Digital Design Lessons](https://tinytapeout.com/digital_design/)
- [Join the Community Discord](https://tinytapeout.com/discord)
- [Build Your Design Locally](https://www.tinytapeout.com/guides/local-hardening/)
