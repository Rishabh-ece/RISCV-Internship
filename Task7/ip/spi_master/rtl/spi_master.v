
module spi_master (
    input  wire        clk,
    input  wire        resetn,

    // Bus interface
    input  wire        sel,
    input  wire [1:0]  offset,     // mem_addr[3:2]
    input  wire        wstrb,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,

    // SPI signals
    output reg         sclk,
    output wire        mosi,
    input  wire        miso,
    output reg         cs_n
);

    // -------------------------------------------------------
    // Internal registers (no magic values — all parameterized)
    // -------------------------------------------------------
    reg        en;           // CTRL[0]
    reg [7:0]  clkdiv;       // CTRL[15:8]
    reg [7:0]  txdata;       // TXDATA[7:0]
    reg [7:0]  rxdata;       // RXDATA[7:0]
    reg        busy;         // STATUS[0]
    reg        done;         // STATUS[1]

    // -------------------------------------------------------
    // Internal working signals
    // -------------------------------------------------------
    reg [7:0]  shift_tx;     // TX shift register (MSB out first)
    reg [7:0]  shift_rx;     // RX shift register (shift in MISO)
    reg [2:0]  bit_cnt;      // counts bits 7 down to 0
    reg [7:0]  clk_cnt;      // clock divider counter
    reg        sclk_en;      // SCLK is toggling (transfer active)

    // State machine states
    localparam IDLE     = 2'b00;
    localparam TRANSFER = 2'b01;
    localparam FINISH   = 2'b10;

    reg [1:0] state;

    // MOSI drives MSB of TX shift register
    assign mosi = shift_tx[7];

    // -------------------------------------------------------
    // Register write logic — synchronous
    // -------------------------------------------------------
    always @(posedge clk) begin
        if (!resetn) begin
            en      <= 1'b0;
            clkdiv  <= 8'b0;
            txdata  <= 8'b0;
            done    <= 1'b0;
        end
        else if (sel & wstrb) begin
            case (offset)
                2'b00: begin                          // CTRL
                    en     <= wdata[0];
                    clkdiv <= wdata[15:8];
                    // START is handled separately below — not stored
                end
                2'b01: begin                          // TXDATA
                    txdata <= wdata[7:0];
                end
                2'b10: begin                          // RXDATA — write ignored
                end
                2'b11: begin                          // STATUS
                    if (wdata[1]) done <= 1'b0;       // write-1-to-clear DONE
                end
            endcase
        end
    end

    // -------------------------------------------------------
    // State machine + transfer logic — synchronous
    // -------------------------------------------------------
    always @(posedge clk) begin
        if (!resetn) begin
            state    <= IDLE;
            busy     <= 1'b0;
            sclk     <= 1'b0;
            cs_n     <= 1'b1;
            shift_tx <= 8'b0;
            shift_rx <= 8'b0;
            bit_cnt  <= 3'd7;
            clk_cnt  <= 8'b0;
            rxdata   <= 8'b0;
            sclk_en  <= 1'b0;
        end
        else begin
            case (state)

                // -------------------------------------------------
                IDLE: begin
                    sclk    <= 1'b0;    // clock idle low (Mode 0)
                    cs_n    <= 1'b1;    // deselect slave
                    sclk_en <= 1'b0;

                    // Detect START pulse: EN=1, START=1, not busy
                    if (sel & wstrb & (offset == 2'b00) &
                        wdata[1] & wdata[0] & !busy) begin
                        // Load shift register from txdata
                        shift_tx <= txdata;
                        shift_rx <= 8'b0;
                        bit_cnt  <= 3'd7;
                        clk_cnt  <= 8'b0;
                        busy     <= 1'b1;
                        done     <= 1'b0;
                        cs_n     <= 1'b0;   // assert CS_N
                        state    <= TRANSFER;
                    end
                end

                // -------------------------------------------------
                TRANSFER: begin
                    if (clk_cnt == clkdiv) begin
                        clk_cnt <= 8'b0;
                        sclk    <= ~sclk;   // toggle SCLK

                        if (!sclk) begin
                            // Rising edge of SCLK — sample MISO (Mode 0)
                            shift_rx <= {shift_rx[6:0], miso};
                            if (bit_cnt == 3'd0) begin
                            	state <= FINISH;
                            end
                        end
                        else begin
                            // Falling edge of SCLK — shift out next MOSI bit
                            if (bit_cnt != 3'd0) begin
                                // All 8 bits done
                                shift_tx <= {shift_tx[6:0], 1'b0}; // shift left
                                bit_cnt  <= bit_cnt - 1;
                            end
                        end
                    end
                    else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                // -------------------------------------------------
                FINISH: begin
                    rxdata <= shift_rx; //capture full received byte
                    cs_n  <= 1'b1;   // deassert CS_N
                    busy  <= 1'b0;
                    done  <= 1'b1;   // set DONE flag
                    state <= IDLE;
                end

            endcase
        end
    end

    // -------------------------------------------------------
    // Register read logic — combinational
    // -------------------------------------------------------
    always @(*) begin
        if (sel) begin
            case (offset)
                2'b00: rdata = {16'b0, clkdiv, 6'b0, 1'b0, en};  // CTRL (START reads as 0)
                2'b01: rdata = {24'b0, txdata};                    // TXDATA
                2'b10: rdata = {24'b0, rxdata};                    // RXDATA
                2'b11: rdata = {30'b0, done, busy};                // STATUS
                default: rdata = 32'b0;
            endcase
        end
        else begin
            rdata = 32'b0;
        end
    end

endmodule
