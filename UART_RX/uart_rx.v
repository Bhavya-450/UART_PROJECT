//==========================================================
// UART Receiver - 8 data bits, no parity, 1 stop bit
// Detects start bit, samples each bit at its middle.
//==========================================================
module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,           // serial input line
    output reg  [7:0] rx_data,      // received byte
    output reg        rx_valid,     // 1-clock pulse when byte ready
    output reg        rx_busy       // HIGH while receiving
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam HALF_DIV = BAUD_DIV / 2;      // to reach middle of bit

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [15:0] baud_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;

    // 2 flip-flops to synchronise the async rx input
    reg rx_sync1, rx_sync2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            rx_data  <= 0;
            rx_valid <= 1'b0;
            rx_busy  <= 1'b0;
            baud_cnt <= 0;
            bit_idx  <= 0;
            data_reg <= 0;
        end
        else begin
            rx_valid <= 1'b0;    // default: no valid pulse

            case (state)

            //----------------------------------------------
            IDLE: begin
                rx_busy  <= 1'b0;
                baud_cnt <= 0;
                bit_idx  <= 0;

                // Falling edge on line = start bit begins
                if (rx_sync2 == 1'b0) begin
                    rx_busy <= 1'b1;
                    state   <= START;
                end
            end

            //----------------------------------------------
            // Wait half a bit period so we can sample
            // at the MIDDLE of the start bit.
            START: begin
                if (baud_cnt == HALF_DIV-1) begin
                    baud_cnt <= 0;
                    // Confirm start bit is still LOW
                    if (rx_sync2 == 1'b0)
                        state <= DATA;
                    else
                        state <= IDLE;   // glitch, ignore
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            //----------------------------------------------
            DATA: begin
                if (baud_cnt == BAUD_DIV-1) begin
                    baud_cnt          <= 0;
                    data_reg[bit_idx] <= rx_sync2;  // sample here
                    if (bit_idx == 7)
                        state <= STOP;
                    else
                        bit_idx <= bit_idx + 1;
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            //----------------------------------------------
            STOP: begin
                if (baud_cnt == BAUD_DIV-1) begin
                    baud_cnt <= 0;
                    rx_data  <= data_reg;
                    rx_valid <= 1'b1;    // tell rest of design
                    rx_busy  <= 1'b0;
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
