# SPI Master IP — Register Map

## Base Address

`IO_SPI_bit = 4` → base offset = `(1 << 4) << 2 = 64`

**SPI Base Address: `0x400040`**

This follows the VSDSquadron FM BasicRISCV 1-hot IO addressing scheme:
```
mem_addr[22] = 1        → IO space selected
mem_wordaddr[4] = 1     → SPI Master IP selected
mem_addr[3:2]           → sub-register offset within SPI IP
```

---

## Register Summary

| Offset | Address | Name | R/W | Description |
|--------|---------|------|-----|-------------|
| `0x00` | `0x400040` | `CTRL` | R/W | Control: enable, start, clock divider |
| `0x04` | `0x400044` | `TXDATA` | W | Transmit data register |
| `0x08` | `0x400048` | `RXDATA` | R | Receive data register |
| `0x0C` | `0x40004C` | `STATUS` | R/W | Transfer status flags |

Reads from undefined offsets return `32'b0`. Writes to undefined offsets are ignored.

---

## Register Definitions

### CTRL — Control Register (`0x00`)

| Bits | Field | R/W | Reset | Description |
|------|-------|-----|-------|-------------|
| `[0]` | `EN` | R/W | `0` | SPI block enable. `1` = enabled, `0` = disabled |
| `[1]` | `START` | W | `0` | Write `1` to trigger a transfer. Auto-clears internally — not stored as a register bit. Ignored if BUSY=1 |
| `[7:2]` | Reserved | — | `0` | Reserved. Read as 0, writes ignored |
| `[15:8]` | `CLKDIV` | R/W | `0` | SCLK clock divider. SCLK toggles every `(CLKDIV+1)` system clock cycles |
| `[31:16]` | Reserved | — | `0` | Reserved. Read as 0, writes ignored |

**SCLK frequency formula:**
```
f_SCLK = f_system / (2 × (CLKDIV + 1))
```

**Example values at 12 MHz system clock:**

| CLKDIV | f_SCLK |
|--------|--------|
| 0 | 6.0 MHz |
| 1 | 3.0 MHz |
| 4 | 1.2 MHz |
| 11 | 500 kHz |
| 23 | 250 kHz |

**Important:** `START` is detected as a live pulse on the clock cycle the CPU writes CTRL with `START=1`. Storing it would cause re-triggering every cycle. Always write `EN=1` and `START=1` together in one write operation:
```c
IO_OUT(IO_SPI_CTRL, (CLKDIV << 8) | 3);   // EN=1, START=1
```

---

### TXDATA — Transmit Data Register (`0x04`)

| Bits | Field | R/W | Reset | Description |
|------|-------|-----|-------|-------------|
| `[7:0]` | `TXDATA` | W | `0` | Byte to transmit. Writing loads the TX shift register |
| `[31:8]` | Reserved | — | `0` | Ignored on write, reads return 0 |

**Behavior:**
- Write the byte to transmit here **before** writing START.
- This register is **write-only** — reading it returns `0`.
- The value is latched into `shift_tx` when START is detected by the FSM.
- MSB (`shift_tx[7]`) is driven on MOSI first.

---

### RXDATA — Receive Data Register (`0x08`)

| Bits | Field | R/W | Reset | Description |
|------|-------|-----|-------|-------------|
| `[7:0]` | `RXDATA` | R | `0` | Received byte from the last completed transfer |
| `[31:8]` | Reserved | — | `0` | Always reads as 0 |

**Behavior:**
- This register is **read-only** — writes are silently ignored.
- Valid only after `DONE=1` in the STATUS register.
- Holds the value from the last completed transfer until the next transfer overwrites it.
- Receives bits MSB-first: MISO is sampled on every rising edge of SCLK and shifted into `shift_rx`; at the end of transfer, `shift_rx` is copied to `rxdata`.

---

### STATUS — Status Register (`0x0C`)

| Bits | Field | R/W | Reset | Description |
|------|-------|-----|-------|-------------|
| `[0]` | `BUSY` | R | `0` | `1` while a transfer is in progress. Cleared automatically when transfer finishes |
| `[1]` | `DONE` | R/W1C | `0` | `1` when transfer has completed. Write `1` to clear (write-1-to-clear). Stays high until explicitly cleared |
| `[31:2]` | Reserved | — | `0` | Reserved. Read as 0 |

**Behavior:**
- `BUSY` and `DONE` are mutually exclusive during normal operation: BUSY=1 during transfer, DONE=1 after.
- `DONE` is **sticky** — it stays high until software clears it by writing `0x2` to STATUS. If not cleared between transfers, the next poll will immediately return true (false positive).
- Always clear DONE after reading RXDATA:
```c
IO_OUT(IO_SPI_STATUS, 0x2);   // clear DONE
```

---

## Software Address Definitions

```c
// IO_SPI_bit = 4 → base = (1<<4)<<2 = 64
#define IO_SPI_CTRL    64    // 0x400040
#define IO_SPI_TXDATA  68    // 0x400044
#define IO_SPI_RXDATA  72    // 0x400048
#define IO_SPI_STATUS  76    // 0x40004C
```

---

## Offset Decoding Table

`mem_addr[3:2]` selects the sub-register within the SPI IP:

| `mem_addr[3:2]` | Register | Access |
|-----------------|---------|--------|
| `2'b00` | CTRL | R/W |
| `2'b01` | TXDATA | W only |
| `2'b10` | RXDATA | R only |
| `2'b11` | STATUS | R/W1C |
