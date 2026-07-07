# SPI Master IP — Example Usage

This document provides a ready-to-run C example demonstrating the SPI Master IP on the VSDSquadron FM BasicRISCV SoC. The example uses a software loopback (MISO tied to MOSI in simulation, or a jumper wire on hardware) to verify that transmitted bytes are correctly received.

---

## Address Definitions

```c
#include "io.h"

// IO_SPI_bit = 4 → base = (1<<4)<<2 = 64
#define IO_SPI_CTRL    64    // 0x400040 — EN, START, CLKDIV
#define IO_SPI_TXDATA  68    // 0x400044 — byte to send
#define IO_SPI_RXDATA  72    // 0x400048 — byte received
#define IO_SPI_STATUS  76    // 0x40004C — BUSY, DONE
```

---

## Driver Helper Functions

```c
// Initialize SPI with given clock divider, enable the block
void spi_init(uint8_t clkdiv) {
    IO_OUT(IO_SPI_CTRL, ((uint32_t)clkdiv << 8) | 1);  // EN=1
}

// Transmit one byte and return received byte (blocking)
uint8_t spi_transfer(uint8_t tx) {
    IO_OUT(IO_SPI_TXDATA, tx);                          // load TX byte
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 3);                 // START=1, EN=1
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));              // poll DONE
    uint8_t rx = IO_IN(IO_SPI_RXDATA) & 0xFF;           // read RX byte
    IO_OUT(IO_SPI_STATUS, 0x2);                         // clear DONE
    return rx;
}
```

---

## Example 1 — Basic Loopback Test

This is the primary validation example. It sends four different byte values and verifies the received byte matches the transmitted byte (requires MISO tied to MOSI).

```c
int main() {

    // Initialize SPI: CLKDIV=4, EN=1
    // f_SCLK = 12MHz / (2*(4+1)) = 1.2 MHz
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 1);

    // --- Test 1: Send 0xA5 ---
    IO_OUT(IO_SPI_TXDATA, 0xA5);
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 3);          // START
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));       // wait DONE
    printf("Test1: TXDATA=0xA5 -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);                  // clear DONE

    // --- Test 2: Send 0xFF (all bits high) ---
    IO_OUT(IO_SPI_TXDATA, 0xFF);
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 3);
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));
    printf("Test2: TXDATA=0xFF -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);

    // --- Test 3: Send 0x00 (all bits low) ---
    IO_OUT(IO_SPI_TXDATA, 0x00);
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 3);
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));
    printf("Test3: TXDATA=0x00 -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);

    // --- Test 4: Send 0xA5 again (verify DONE clears correctly) ---
    IO_OUT(IO_SPI_TXDATA, 0xA5);
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 3);
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));
    printf("Test4: TXDATA=0xA5 -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);

    return 0;
}
```

---

## Expected Output

### Simulation Output

```
Test1: TXDATA=0xA5 -> RXDATA=0x000000A5
Test2: TXDATA=0xFF -> RXDATA=0x000000FF
Test3: TXDATA=0x00 -> RXDATA=0x00000000
Test4: TXDATA=0xA5 -> RXDATA=0x000000A5
$finish called at 91470220000 (1ps)
```

Every RXDATA matches TXDATA — the loopback transfer is correct. ✅

### Hardware Output

After flashing to the VSDSquadron FPGA Mini with a jumper wire connecting MOSI (pin 47) to MISO (pin 48):

```
Test1: TXDATA=0xA5 -> RXDATA=0x000000A5
Test2: TXDATA=0xFF -> RXDATA=0x000000FF
Test3: TXDATA=0x00 -> RXDATA=0x00000000
Test4: TXDATA=0xA5 -> RXDATA=0x000000A5
```

---

## How to Build and Run

### Simulation

```bash
# Step 1: Build firmware
cd ~/vsdfpga_labs/basicRISCV/Firmware
make spi_test.bram.hex

# Step 2: Add loopback to bench.v
# assign uut.spi_miso = uut.spi_mosi;

# Step 3: Compile and simulate
cd ~/vsdfpga_labs/basicRISCV/RTL
iverilog -g2012 -DBENCH -o spi_sim riscv.v bench.v
vvp spi_sim

# Step 4: View waveforms (optional)
gtkwave spi_sim.vcd
```

### Hardware (VSDSquadron FPGA Mini)

```bash
# Step 1: Build firmware
cd ~/vsdfpga_labs/basicRISCV/Firmware
make spi_test.bram.hex

# Step 2: Synthesize and generate bitstream
cd ~/vsdfpga_labs/basicRISCV/RTL
make build

# Step 3: Flash to board
sudo rmmod ftdi_sio
sudo make flash

# Step 4: Open UART terminal
sudo modprobe ftdi_sio
sudo make terminal

# Step 5: Press RESET on the board
```

---

## Waveform Analysis

Opening `spi_sim.vcd` in GTKWave and adding signals from the SPI module shows the bit-by-bit transfer of `0xA5 = 1010 0101`:

```
SCLK:     _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
MOSI:     -< 1 >< 0 >< 1 >< 0 >< 0 >< 1 >< 0 >< 1 >-
MISO:     -< 1 >< 0 >< 1 >< 0 >< 0 >< 1 >< 0 >< 1 >-  (loopback)
CS_N:     ‾‾|___________________________________|‾‾
```

`shift_rx` builds up step by step:
```
00000001 → 00000010 → 00000101 → 00001010 →
00010100 → 00101001 → 01010010 → 10100101  (= 0xA5 ✅)
```

---

## Common Failures and Fixes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| RXDATA always 0 | MISO not connected | Connect MISO to MOSI (loopback) or check wiring |
| RXDATA = 0x4B instead of 0xA5 | Bit timing off by 1 | Verify rising edge samples MISO, falling edge shifts MOSI |
| Program hangs on `while DONE` | START never triggered | Ensure EN=1 and START=1 written together in one write |
| RXDATA = previous transfer value | DONE not cleared | Write `0x2` to STATUS after every read |
| Wrong value received | CLKDIV too high/low for slave | Try CLKDIV=4 (1.2 MHz) as a safe starting point |
