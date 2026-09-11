
`timescale 1ns/1ps

module uart_tx_tb;

    // ---- Use SMALL numbers so simulation is fast ----
    localparam CLK_FREQ  = 1_000_000;   // 1 MHz
    localparam BAUD_RATE = 100_000;     // 100 kHz  → BAUD_DIV = 10
    localparam CLK_PERIOD  = 1000;      // ns  (1 MHz)
    localparam BAUD_PERIOD = 10000;     // ns  (100 kHz)

    reg        clk, rst_n, tx_start;
    reg  [7:0] tx_data;
    wire       tx, tx_busy, tx_done;

    // ---- Instantiate DUT ----
    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .tx_busy(tx_busy), .tx_done(tx_done)
    );

    // ---- Clock ----
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---- Task: send one byte ----
    task send_byte(input [7:0] b);
        begin
            @(posedge clk);
            tx_data  = b;
            tx_start = 1'b1;
            @(posedge clk);
            tx_start = 1'b0;
            wait (tx_done);          // wait until TX finishes
            @(posedge clk);
        end
    endtask

    // ---- Stimulus ----
    initial begin
        // Initialise
        clk = 0; rst_n = 0; tx_start = 0; tx_data = 0;

        // Apply reset
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (5) @(posedge clk);

        // Send test bytes
        send_byte(8'hA5);   // 1010_0101
        send_byte(8'h00);
        send_byte(8'hFF);
        send_byte(8'h55);

        repeat (20) @(posedge clk);
        $display("[%0t] TX test finished", $time);
        $finish;
    end

    // ---- Monitor: print when a bit period changes ----
    initial begin
        $monitor("[%0t] tx=%b  busy=%b  done=%b  data=%h",
                 $time, tx, tx_busy, tx_done, tx_data);
    end

    // ---- Safety timeout ----
    initial begin
        #(BAUD_PERIOD * 100);
        $display("TIMEOUT!");
        $finish;
    end
endmodule
