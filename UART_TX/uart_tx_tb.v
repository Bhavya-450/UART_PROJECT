
`timescale 1ns/1ps

module uart_tx_tb;

    reg        clk;
    reg        rst_n;
    reg [7:0]  data_in;
    reg        tx_start;

    wire       tx;
    wire       busy;

    // Instantiate UART transmitter
    uart_tx_fsm #(
      .CLK_FREQ      (1_000_000),
      .BAUD_RATE     (9_600),
        .PARITY_ENABLE (1'b1),
        .ODD_PARITY    (1'b0)       // Even parity
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (data_in),
        .tx_start (tx_start),
        .tx       (tx),
        .busy     (busy)
    );

    // 50 MHz clock: period = 20 ns
  initial clk = 0;
    always #500 clk = ~clk;

    // Task to send one UART byte
    task send_byte;
        input [7:0] byte_data;
        begin
            // Wait until transmitter is free
            wait (busy == 1'b0);

            // Apply input on a safe clock edge
            @(negedge clk);
            data_in  = byte_data;
            tx_start = 1'b1;

            // tx_start must be a one-clock pulse
            @(negedge clk);
            tx_start = 1'b0;

            // Wait for transmission to begin and finish
            wait (busy == 1'b1);
            wait (busy == 1'b0);

            // Small gap before next byte
            repeat (10) @(posedge clk);
        end
    endtask

    initial begin
        // Initial values
        clk      = 1'b0;
        rst_n    = 1'b0;
        data_in  = 8'h00;
        tx_start = 1'b0;

        // Keep reset active briefly
        #100;
        rst_n = 1'b1;

        // Send test bytes
        send_byte(8'h55);  // Binary: 01010101
        send_byte(8'hA3);  // Binary: 10100011
       

        #1000;
        $finish;
    end

    // Optional waveform dump for Icarus Verilog / GTKWave
    initial begin
        $dumpfile("uart_tx_fsm_tb.vcd");
        $dumpvars(0, uart_tx_fsm_tb);
    end
 
endmodule
