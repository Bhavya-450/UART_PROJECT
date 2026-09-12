
`timescale 1ns/1ps

module uart_tx #(
    parameter integer CLK_FREQ      = 1_000_000,
    parameter integer BAUD_RATE     = 9_600,
    parameter         PARITY_ENABLE = 1'b1,
    parameter         ODD_PARITY    = 1'b0   // 0 = even, 1 = odd
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    input  wire       tx_start,

    output reg        tx,
    output reg        busy
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam [2:0]
        IDLE   = 3'd0,
        START  = 3'd1,
        DATA   = 3'd2,
        PARITY = 3'd3,
        STOP   = 3'd4;

    reg [2:0]  state;
    reg [7:0]  data_reg;
    reg        parity_bit;
  reg [2:0]  bit_index;
    reg [31:0] clk_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx        <= 1'b1;   // UART idle level
            busy      <= 1'b0;
            data_reg  <= 8'd0;
            parity_bit <= 1'b0;
            bit_index <= 3'd0;
            clk_count <= 32'd0;
        end
        else begin
            case (state)

                IDLE: begin
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 0;

                    if (tx_start) begin
                        data_reg <= data_in;

                        // Even parity: XOR of all 9 bits is 0
                        // Odd parity:  XOR of all 9 bits is 1
                        if (ODD_PARITY)
                            parity_bit <= ~(^data_in);
                        else
                            parity_bit <=  ^data_in;

                        tx        <= 1'b0;  // Start bit
                        busy      <= 1'b1;
                        state     <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        bit_index <= 0;
                        tx        <= data_reg[0]; // Send LSB first
                        state     <= DATA;
                    end
                    else
                        clk_count <= clk_count + 1;
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;

                      if (bit_index == 3'd7) begin
                            if (PARITY_ENABLE) begin
                                tx    <= parity_bit;
                                state <= PARITY;
                            end
                            else begin
                                tx    <= 1'b1; // Stop bit
                                state <= STOP;
                            end
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                          tx        <= data_reg[bit_index + 3'b1];
                        end
                    end
                    else
                        clk_count <= clk_count + 1;
                end

                PARITY: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        tx        <= 1'b1; // Stop bit
                        state     <= STOP;
                    end
                    else
                        clk_count <= clk_count + 1;
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        tx        <= 1'b1;
                        busy      <= 1'b0;
                        state     <= IDLE;
                    end
                    else
                        clk_count <= clk_count + 1;
                end

                default: begin
                    state <= IDLE;
                    tx    <= 1'b1;
                    busy  <= 1'b0;
                end
            endcase
        end
    end

endmodule
