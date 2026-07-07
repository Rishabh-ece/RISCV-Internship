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
