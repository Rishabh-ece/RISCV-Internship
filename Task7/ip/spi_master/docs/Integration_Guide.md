# SPI Master IP — Integration Guide

This guide explains how to integrate the SPI Master IP into the VSDSquadron FM BasicRISCV SoC. The reader is assumed to be familiar with the VSDSquadron FPGA platform and the BasicRISCV SoC structure but has not seen this IP before.

---

## Required Files

| File | Location | Purpose |
|------|----------|---------|
| `spi_master.v` | `RTL/` | SPI Master IP RTL module |
| `spi_test.c` | `Firmware/` | C validation program |
| `VSDSquadronFM.pcf` | `RTL/` | Pin constraint file (modify existing) |
| `riscv.v` | `RTL/` | SoC top file (modify existing) |

---

## Step 1 — Copy RTL File

Copy `spi_master.v` into your RTL directory:

```bash
cp spi_master.v ~/vsdfpga_labs/basicRISCV/RTL/
```

---

## Step 2 — Edit `riscv.v` (5 changes)

Open `riscv.v`:

```bash
gedit ~/vsdfpga_labs/basicRISCV/RTL/riscv.v
```

### Change 1 — Add include at top of file

Find the existing includes and add:

```verilog
`include "clockworks.v"
`include "emitter_uart.v"
`include "gpio_ip.v"
`include "spi_master.v"    // ← ADD THIS
```

### Change 2 — Add IO_SPI_bit localparam

Find the existing localparams block and add:

```verilog
localparam IO_LEDS_bit      = 0;
localparam IO_UART_DAT_bit  = 1;
localparam IO_UART_CNTL_bit = 2;
localparam IO_GPIO_bit      = 3;
localparam IO_SPI_bit       = 4;   // ← ADD THIS
```

### Change 3 — Declare SPI wires

After the GPIO signals block, add:

```verilog
//---------SPI Signals---------------
wire        spi_sel    = isIO & mem_wordaddr[IO_SPI_bit];
wire [1:0]  spi_offset = mem_addr[3:2];
wire [31:0] spi_rdata;
wire        spi_sclk;
wire        spi_mosi;
wire        spi_miso;
wire        spi_cs_n;
```

**Note:** `spi_rdata` is driven by the module's `rdata` output. No separate write-data wire is needed — the shared `mem_wdata` bus is used directly.

### Change 4 — Instantiate the module

After the GPIO instantiation, add:

```verilog
spi_master SPI (
    .clk    (clk),
    .resetn (resetn),
    .sel    (spi_sel),
    .offset (spi_offset),
    .wstrb  (mem_wstrb),
    .wdata  (mem_wdata),
    .rdata  (spi_rdata),
    .sclk   (spi_sclk),
    .mosi   (spi_mosi),
    .miso   (spi_miso),
    .cs_n   (spi_cs_n)
);
```

### Change 5 — Extend IO_rdata mux

Find the existing `IO_rdata` mux and add the SPI line:

```verilog
wire [31:0] IO_rdata =
    (isIO & mem_wordaddr[IO_UART_CNTL_bit]) ? {22'b0, !uart_ready, 9'b0} :
    (isIO & mem_wordaddr[IO_GPIO_bit])       ? gpio_rdata :
    (isIO & mem_wordaddr[IO_SPI_bit])        ? spi_rdata  :   // ← ADD THIS
                                               32'b0;
```

---

## Step 3 — Expose SPI Signals to Top Level

The SPI signals must be exposed as top-level ports of the `SOC` module so they can be routed to physical FPGA pins.

### Add ports to SOC module declaration:

```verilog
module SOC (
    input        CLK,
    input        RESET,
    output [4:0] LEDS,
    input        RXD,
    output       TXD,
    output       SPI_SCLK,   // ← ADD
    output       SPI_MOSI,   // ← ADD
    input        SPI_MISO,   // ← ADD
    output       SPI_CS_N    // ← ADD
);
```

### Add assign statements before `endmodule`:

```verilog
assign SPI_SCLK = spi_sclk;
assign SPI_MOSI = spi_mosi;
assign spi_miso = SPI_MISO;
assign SPI_CS_N = spi_cs_n;
```

---

## Step 4 — Update PCF Constraint File

Add SPI pin assignments to `VSDSquadronFM.pcf`:

```bash
gedit ~/vsdfpga_labs/basicRISCV/RTL/VSDSquadronFM.pcf
```

Add at the end:

```
set_io SPI_SCLK  2
set_io SPI_MOSI  47
set_io SPI_MISO  48
set_io SPI_CS_N  46
```

These pins are free GPIO pins on the VSDSquadron FPGA Mini (iCE40UP5k, sg48 package). The existing pin assignments are:

| Signal | Pin |
|--------|-----|
| LEDS[0] | 39 |
| LEDS[1] | 41 |
| LEDS[2] | 40 |
| LEDS[3] | 25 |
| LEDS[4] | 26 |
| RESET | 23 |
| CLK | 28 |
| TXD | 4 |
| RXD | 3 |

---

## Step 5 — Build and Flash

### Build firmware:

```bash
cd ~/vsdfpga_labs/basicRISCV/Firmware
make spi_test.bram.hex
```

### Synthesize and generate bitstream:

```bash
cd ~/vsdfpga_labs/basicRISCV/RTL
make build
```

### Flash to board:

```bash
sudo rmmod ftdi_sio    # release UART driver before flashing
sudo make flash
```

Expected output:
```
VERIFY OK
cdone: high
Bye.
```

---

## Step 6 — Simulation Verification (Optional but Recommended)

Before flashing to hardware, verify the integration with simulation. Add a loopback line to `bench.v`:

```verilog
SOC uut(
    .RESET(RESET), .LEDS(LEDS), .RXD(RXD), .TXD(TXD),
    .SPI_SCLK(), .SPI_MOSI(), .SPI_CS_N()
);

assign uut.spi_miso = uut.spi_mosi;   // loopback
```

Then simulate:

```bash
iverilog -g2012 -DBENCH -o spi_sim riscv.v bench.v
vvp spi_sim
```

---

## Address Decoding Summary

```
CPU write to 0x400040:
  mem_addr[22] = 1          → isIO = 1
  mem_wordaddr[4] = 1       → spi_sel = 1 (SPI IP selected)
  mem_addr[3:2] = 2'b00     → CTRL register

CPU write to 0x400044:
  mem_wordaddr[4] = 1       → spi_sel = 1
  mem_addr[3:2] = 2'b01     → TXDATA register

CPU read from 0x400048:
  mem_wordaddr[4] = 1       → spi_sel = 1
  mem_addr[3:2] = 2'b10     → RXDATA register

CPU read from 0x40004C:
  mem_wordaddr[4] = 1       → spi_sel = 1
  mem_addr[3:2] = 2'b11     → STATUS register
```

The `IO_rdata` mux in `riscv.v` checks only which IP is selected. All sub-register selection happens inside `spi_master.v` via the `offset` port — the SoC integration stays clean.

---

## Common Integration Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Forgot `` `include "spi_master.v" `` | iverilog: module not found | Add include at top of riscv.v |
| Listed `spi_master.v` separately in iverilog command | Duplicate module error | Remove it — riscv.v includes it |
| Wrong `IO_SPI_bit` value | Wrong base address, reads return 0 | Must be 4 (next free bit after GPIO=3) |
| Forgot to extend `IO_rdata` mux | All reads from SPI return 0 | Add `spi_rdata` line to mux |
| Forgot SPI ports in SOC module | Synthesis error: undriven outputs | Add SPI_SCLK/MOSI/MISO/CS_N to SOC |
| Forgot PCF entries | nextpnr error: unresolved ports | Add set_io lines to PCF |
