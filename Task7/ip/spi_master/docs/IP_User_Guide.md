# SPI Master IP — User Guide

## 1. IP Overview

The **SPI Master IP** is a single-slave, single-byte SPI controller integrated into the VSDSquadron FM BasicRISCV SoC. It performs one full-duplex 8-bit SPI transaction per software-triggered start, with hardware-managed chip-select and clock generation.

**Purpose:** Provide a memory-mapped SPI Master peripheral that allows the RISC-V processor to exchange 8-bit data with external SPI slave devices without software bit-banging. The IP handles clock generation, chip-select toggling, and serial data shifting autonomously once triggered by a register write.

**Typical use cases:**
- Reading sensor data from SPI-based temperature, pressure, or IMU sensors
- Communicating with SPI Flash or EEPROM devices
- Driving SPI DACs or reading SPI ADCs
- Interfacing with OLED/LCD displays over SPI
- Any single-slave SPI peripheral on the VSDSquadron FPGA board

**When to use it:** whenever firmware needs a hardware-timed SPI transaction to a single external device without hand-rolling GPIO bit-banging. The CPU loads a byte, writes START, and polls for DONE — the hardware handles everything in between.

---

## 2. Feature Summary

| Feature | Detail |
|---------|--------|
| Transfer size | 8 bits (1 byte) per transaction |
| Full-duplex | Yes — simultaneous TX and RX |
| Bit order | MSB-first |
| SPI mode | Mode 0 only (CPOL=0, CPHA=0) |
| Clock divider | 8-bit, software-programmable via CTRL[15:8] |
| Chip-select | Automatic, hardware-driven, active-low (`cs_n`) |
| Status flags | BUSY (transfer in progress) + DONE (transfer complete) |
| Interrupt output | **No** — polling only |
| Multi-byte / burst | **No** — one byte per START trigger |
| Multiple slaves | **No** — single `cs_n` output per instance |
| Bus interface | 32-bit memory-mapped, word-aligned |
| Reset behavior | Active-low synchronous reset (`resetn`) |

**Limitations — stated upfront:**
- Only 8-bit transfers. For multi-byte protocols, firmware must issue one START per byte and manage any inter-byte timing itself. `cs_n` is deasserted between every single-byte transfer automatically.
- Only SPI Mode 0 — CPOL and CPHA are not configurable.
- Only one chip-select line. Supporting more than one SPI slave requires external muxing of `cs_n`, or a separate IP instance.
- No interrupt — firmware must poll the `STATUS` register until `DONE=1`.
- `TXDATA` (offset `0x04`) is write-only — reads return 0.
- `RXDATA` (offset `0x08`) is read-only — writes are silently ignored.

---

## 3. Block Diagram

```
        SOC Bus (mem_addr / mem_wdata / mem_wstrb)
                          |
                          v
         isIO & mem_wordaddr[IO_SPI_bit]
         (one-hot peripheral select in riscv.v)
                          |
                          v
            +---------------------------+
            |      Register Decode      |
            |   offset = mem_addr[3:2]  |
            |  CTRL / TXDATA / RXDATA / |
            |         STATUS            |
            +---------------------------+
                          |
              +-----------+-----------+
              |                       |
              v                       v
   +--------------------+   +--------------------+
   |   Clock Divider    |   |   Write Registers  |
   |   clk_cnt/clkdiv   |   |   en, txdata, done |
   +--------------------+   +--------------------+
              |
              v
   +-----------------------------+
   |    3-State FSM              |
   |  IDLE → TRANSFER → FINISH   |
   +-----------------------------+
        |          |          |
        v          v          v
     cs_n       sclk       mosi
   (auto)    (divided)   (shift_tx[7])
                             ^
                             |
                           miso
                        (sampled on
                        rising edge
                        → shift_rx)
                             |
                             v
                    rxdata (captured
                    in FINISH state)
```

**Signal flow summary:**
- CPU writes TXDATA → loads `shift_tx`
- CPU writes START → FSM asserts `cs_n`, begins toggling `sclk`
- Each rising edge of `sclk` → samples `miso` into `shift_rx`
- Each falling edge of `sclk` → shifts `shift_tx` left, drives new bit on `mosi`
- After 8 bits → FSM copies `shift_rx` to `rxdata`, deasserts `cs_n`, sets DONE
- CPU reads RXDATA → gets received byte

---

## 4. Timing Overview

**SPI Mode 0:**
```
CS_N:   ‾‾‾|_________________________________|‾‾‾
SCLK:       __|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__
MOSI:   ----< B7 >< B6 >< B5 >< B4 >...< B0 >
MISO:   ----< B7 >< B6 >< B5 >< B4 >...< B0 >
              ↑    ↓    ↑    ↓
           sample shift sample shift
```

- SCLK idles low
- MOSI changes on falling edge of SCLK
- MISO is sampled on rising edge of SCLK
- CS_N is asserted (low) for exactly 8 SCLK cycles per transfer

**SCLK frequency:**
```
f_SCLK = f_system / (2 × (CLKDIV + 1))
```
At system clock 12 MHz with CLKDIV=4: `f_SCLK = 12 MHz / 10 = 1.2 MHz`

---

## 5. Software Programming Model

### Initialization Sequence

```c
// Step 1: Configure clock divider and enable SPI
IO_OUT(IO_SPI_CTRL, (CLKDIV << 8) | 1);   // EN=1, CLKDIV=value

// Step 2: Load transmit byte
IO_OUT(IO_SPI_TXDATA, tx_byte);

// Step 3: Start transfer (EN=1, START=1)
IO_OUT(IO_SPI_CTRL, (CLKDIV << 8) | 3);   // START=1, EN=1

// Step 4: Poll until DONE
while (!(IO_IN(IO_SPI_STATUS) & 0x2));

// Step 5: Read received byte
uint32_t rx = IO_IN(IO_SPI_RXDATA) & 0xFF;

// Step 6: Clear DONE flag
IO_OUT(IO_SPI_STATUS, 0x2);
```

### Key Behavioral Notes

- `START` is a **one-shot pulse** — the state machine detects it on the same clock cycle it is written. It is not stored internally and auto-clears.
- Writing `START=1` while `BUSY=1` is silently ignored — the transfer in progress is not interrupted.
- `DONE` stays high until explicitly cleared by writing `0x2` to `STATUS`. If not cleared, a subsequent poll will immediately return true.
- `cs_n` is automatically asserted at the start of each transfer and deasserted in the FINISH state. Software has no direct control over `cs_n`.

---

## 6. Related Documents

| Document | Contents |
|----------|---------|
| `Register_Map.md` | Complete register and bit-field reference with reset values |
| `Integration_Guide.md` | Step-by-step SoC integration: files, wiring, PCF, mux |
| `Example_Usage.md` | Ready-to-run C loopback example with expected output |
