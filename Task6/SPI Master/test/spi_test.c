#include "io.h"

// SPI register offsets from IO_BASE
// IO_SPI_bit = 4 → (1<<4)<<2 = 64
#define IO_SPI_CTRL    64   // 0x400040 — EN, START, CLKDIV
#define IO_SPI_TXDATA  68   // 0x400044 — byte to send
#define IO_SPI_RXDATA  72   // 0x400048 — byte received
#define IO_SPI_STATUS  76   // 0x40004C — BUSY, DONE

int main() {

    // -----------------------------------------------
    // Test 1: Basic loopback — send 0xA5, expect 0xA5
    // -----------------------------------------------

    // Step 1: Set CLKDIV=4, EN=1 (no START yet)
    // CTRL = 0x0401 → bits[15:8]=4 (CLKDIV), bit[0]=1 (EN)
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 1);

    // Step 2: Load TX byte
    IO_OUT(IO_SPI_TXDATA, 0xA5);

    // Step 3: Start transfer — EN=1, START=1, CLKDIV=4
    // CTRL = 0x0403 → bit[1]=1 (START), bit[0]=1 (EN)
    IO_OUT(IO_SPI_CTRL, (4 << 8) | 3);

    // Step 4: Poll STATUS until DONE=1 (bit 1)
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));

    // Step 5: Read and print RXDATA
    printf("Test1: TXDATA=0xA5 -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));

    // Step 6: Clear DONE flag (write-1-to-clear bit 1)
    IO_OUT(IO_SPI_STATUS, 0x2);

    // -----------------------------------------------
    // Test 2: Send 0xFF, expect 0xFF
    // -----------------------------------------------
    IO_OUT(IO_SPI_TXDATA, 0xFF);
    IO_OUT(IO_SPI_CTRL,  (4 << 8) | 3);
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));
    printf("Test2: TXDATA=0xFF -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);

    // -----------------------------------------------
    // Test 3: Send 0x00, expect 0x00
    // -----------------------------------------------
    IO_OUT(IO_SPI_TXDATA, 0x00);
    IO_OUT(IO_SPI_CTRL,  (4 << 8) | 3);
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));
    printf("Test3: TXDATA=0x00 -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);

    // -----------------------------------------------
    // Test 4: Send 0xA5 again — verify DONE clears properly
    // -----------------------------------------------
    IO_OUT(IO_SPI_TXDATA, 0xA5);
    IO_OUT(IO_SPI_CTRL,  (4 << 8) | 3);
    while (!(IO_IN(IO_SPI_STATUS) & 0x2));
    printf("Test4: TXDATA=0xA5 -> RXDATA=0x%x\n", IO_IN(IO_SPI_RXDATA));
    IO_OUT(IO_SPI_STATUS, 0x2);

    return 0;
}
