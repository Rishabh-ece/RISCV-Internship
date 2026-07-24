## Overview

This repository contains a memory-mapped **SPI Master IP** for the VSDSquadron FM BasicRISCV SoC.

The IP enables the RISC-V processor to communicate with SPI peripherals such as Flash memory, sensors, ADCs, DACs, and displays using a simple software driver and memory-mapped registers.

---

## IP Overview

The SPI Master IP provides a memory-mapped Serial Peripheral Interface (SPI) controller for the VSDSquadron FM BasicRISCV SoC. It enables the RISC-V processor to initiate full-duplex 8-bit SPI transfers to a single slave device through a simple register interface. The IP manages SPI clock generation, chip-select control, and serial data shifting — freeing the CPU from bit-banging overhead.

**Typical use cases:**
- SPI Flash memory and EEPROM devices
- ADC / DAC peripherals
- Temperature, pressure, and motion sensors
- OLED and LCD displays
- SD card modules in SPI mode

---

## Repository Structure

```
ip/
└── spi_master/
    ├── rtl/
    │   └── spi_master.v
    |   |── riscv.v
    ├── software/
    │   └── spi_test.c
    ├── docs/
    │   ├── IP_User_Guide.md
    │   ├── Register_Map.md
    │   ├── Integration_Guide.md
    │   └── Example_Usage.md
    └── README.md
```

---

## How to Integrate

1. Copy `rtl/spi_master.v` into your SoC RTL directory.
2. Add `` `include "spi_master.v" `` at the top of `riscv.v`.
3. Add `localparam IO_SPI_bit = 4` to the SoC localparams.
4. Declare SPI wires and instantiate the module in `riscv.v`.
5. Extend the `IO_rdata` mux to include `spi_rdata`.
6. Add SPI pin constraints to `VSDSquadronFM.pcf`.
7. Copy `software/spi_test.c` to your Firmware directory.
8. Build firmware and generate the FPGA bitstream.

See [`docs/Integration_Guide.md`](docs/Integration_Guide.md) for the complete step-by-step integration procedure.

---

## Documentation

Detailed documentation is available in the `docs/` folder.

| Document | Description |
|----------|-------------|
| `IP_User_Guide.md` | IP overview, features, block diagram, limitations |
| `Register_Map.md` | Complete register and bit-field reference |
| `Integration_Guide.md` | Step-by-step SoC integration procedure |
| `Example_Usage.md` | Ready-to-run C example with expected output |

---

## How to Test

### Simulation (Loopback)

```bash
# Build firmware
cd ~/vsdfpga_labs/basicRISCV/Firmware
make spi_test.bram.hex

# Simulate
cd ~/vsdfpga_labs/basicRISCV/RTL
iverilog -g2012 -DBENCH -o spi_sim riscv.v bench.v
vvp spi_sim
```

Expected output:
```
Test1: TXDATA=0xA5 -> RXDATA=0x000000A5
Test2: TXDATA=0xFF -> RXDATA=0x000000FF
Test3: TXDATA=0x00 -> RXDATA=0x00000000
Test4: TXDATA=0xA5 -> RXDATA=0x000000A5
```

### FPGA Hardware

```bash
cd ~/vsdfpga_labs/basicRISCV/RTL
make build
sudo make flash
```

Expected: `VERIFY OK` and `cdone: high` confirming successful FPGA configuration.

---

## Features

- Memory-mapped SPI Master — no bit-banging required
- 8-bit full-duplex transfer (simultaneous TX and RX)
- Configurable SPI clock divider (8-bit CLKDIV)
- Hardware-managed chip-select (`cs_n`)
- Polling-based status (BUSY + DONE flags)
- Clean 3-state FSM: IDLE → TRANSFER → FINISH
- Ready for VSDSquadron FM BasicRISCV integration

---

## Known Limitations

- 8-bit (single-byte) transfers only — no burst or multi-byte mode
- SPI Mode 0 only (CPOL=0, CPHA=0) — not configurable
- Single chip-select line — one slave per instance
- No interrupt output — polling only
- `TXDATA` is write-only; reads return 0
- `RXDATA` is read-only; writes are silently ignored
