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
