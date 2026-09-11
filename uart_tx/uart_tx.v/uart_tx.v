/ UART Transmitter - 8 data bits, no parity, 1 stop bit
// Sends one byte LSB-first when tx_start is pulsed.
module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,   // system clock (Hz)
    parameter BAUD_RATE = 115200        // baud rate
)(
    input  wire       clk,
    input  wire       rst_n,        // active-low reset
    input  wire       tx_start,     // pulse HIGH for 1 clock to send
    input  wire [7:0] tx_data,      // byte to transmit
    output reg        tx,           // serial output line
    output reg        tx_busy,      // HIGH while transmitting
    output reg        tx_done       // 1-clock pulse when finished
);

    // Number of clock cycles per bit
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    // State encoding
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [15:0] baud_cnt;     // counts clocks within one bit
    reg [2:0]  bit_idx;      // 0..7 which data bit we are sending
    reg [7:0]  data_reg;     // latched copy of tx_data

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            tx       <= 1'b1;       // idle line = HIGH
            tx_busy  <= 1'b0;
            tx_done  <= 1'b0;
            baud_cnt <= 0;
            bit_idx  <= 0;
            data_reg <= 0;
        end
        else begin
            tx_done <= 1'b0;        // default: no done pulse

            case (state)

            //----------------------------------------------
            IDLE: begin
                tx      <= 1'b1;    // keep line HIGH
                tx_busy <= 1'b0;
                baud_cnt <= 0;
                bit_idx  <= 0;

                if (tx_start) begin
                    data_reg <= tx_data;   // latch input data
                    tx_busy  <= 1'b1;
                    state    <= START;
                end
            end

            //----------------------------------------------
            START: begin
                tx <= 1'b0;                // pull line LOW
                if (baud_cnt == BAUD_DIV-1) begin
                    baud_cnt <= 0;
                    state    <= DATA;
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            //----------------------------------------------
            DATA: begin
                tx <= data_reg[bit_idx];   // LSB first
                if (baud_cnt == BAUD_DIV-1) begin
                    baud_cnt <= 0;
                    if (bit_idx == 7) begin
                        bit_idx <= 0;
                        state   <= STOP;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            //----------------------------------------------
            STOP: begin
                tx <= 1'b1;                // stop bit = HIGH
                if (baud_cnt == BAUD_DIV-1) begin
                    baud_cnt <= 0;
                    tx_done  <= 1'b1;
                    tx_busy  <= 1'b0;
                    state    <= IDLE;
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            default: state <= IDLE;
            endcase
        end
    end
endmodule  
