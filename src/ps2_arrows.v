`default_nettype none

// =============================================================
// PS/2 KEYBOARD RECEIVER + ARROW KEY DECODER
// =============================================================
module ps2_arrows (
    input  wire clk,          // system clock (25.175 MHz)
    input  wire rst_n,
    input  wire ps2_clk_in,   // from keyboard
    input  wire ps2_data_in,  // from keyboard
    output reg  key_up,
    output reg  key_down,
    output reg  key_left,
    output reg  key_right
);

    // Synchronize + edge detect PS/2 clock
    reg [2:0] clk_sync;
    reg [1:0] dat_sync;
    always @(posedge clk) begin
        clk_sync <= {clk_sync[1:0], ps2_clk_in};
        dat_sync <= {dat_sync[0],   ps2_data_in};
    end
    wire ps2_falling = (clk_sync[2:1] == 2'b10);

    // 11-bit frame reception
    reg [10:0] shiftreg;
    reg [3:0]  bitcnt;
    reg [7:0]  byte_data;
    reg        byte_ready;
    wire [10:0] next_shift = {dat_sync[1], shiftreg[10:1]};

    reg [15:0] idle_cnt;
    always @(posedge clk) begin
        if (!rst_n) begin
            shiftreg   <= 11'd0;
            bitcnt     <= 4'd0;
            byte_data  <= 8'd0;
            byte_ready <= 1'b0;
            idle_cnt   <= 16'd0;
        end else begin
            byte_ready <= 1'b0;
            if (ps2_falling) begin
                idle_cnt <= 16'd0;
                shiftreg <= next_shift;
                if (bitcnt == 4'd10) begin
                    bitcnt     <= 4'd0;
                    byte_data  <= next_shift[8:1];
                    byte_ready <= 1'b1;
                end else begin
                    bitcnt <= bitcnt + 4'd1;
                end
            end else if (bitcnt != 4'd0) begin
                idle_cnt <= idle_cnt + 16'd1;
                if (idle_cnt == 16'hFFFF)
                    bitcnt <= 4'd0;
            end
        end
    end

    // Scan code state machine
    reg extended;
    reg break_code;
    always @(posedge clk) begin
        if (!rst_n) begin
            extended   <= 1'b0;
            break_code <= 1'b0;
            key_up     <= 1'b0;
            key_down   <= 1'b0;
            key_left   <= 1'b0;
            key_right  <= 1'b0;
        end else if (byte_ready) begin
            if (byte_data == 8'hE0) begin
                extended <= 1'b1;
            end else if (byte_data == 8'hF0) begin
                break_code <= 1'b1;
            end else begin
                if (extended) begin
                    case (byte_data)
                        8'h75: key_up    <= ~break_code;  // Up
                        8'h72: key_down  <= ~break_code;  // Down
                        8'h6B: key_left  <= ~break_code;  // Left
                        8'h74: key_right <= ~break_code;  // Right
                        default: ;
                    endcase
                end else begin
                    case (byte_data)
                        8'h1D: key_up    <= ~break_code;  // W
                        8'h1B: key_down  <= ~break_code;  // S
                        8'h1C: key_left  <= ~break_code;  // A
                        8'h23: key_right <= ~break_code;  // D
                        default: ;
                    endcase
                end
                extended   <= 1'b0;
                break_code <= 1'b0;
            end
        end
    end
endmodule
