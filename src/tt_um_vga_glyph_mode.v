/*
 * Copyright (c) 2024-2025 James Ross
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_glyph_mode(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // VGA signals
    wire hsync, vsync, display_on;
    wire [10:0] hpos;
    wire [9:0] vpos;

    // TinyVGA PMOD
    assign uo_out = {hsync, RGB[0], RGB[2], RGB[4], vsync, RGB[1], RGB[3], RGB[5]};

    // Unused outputs assigned to 0.
    assign uio_out = 0;
    assign uio_oe  = 0;

    wire [7:0] xb = hpos[10:3];
    wire [6:0] x_mix = {xb[7] ^ xb[3], xb[1], xb[4], xb[1], xb[6], xb[0], xb[2]};
    wire [2:0] g_x = hpos[2:0];

    wire [5:0] yb;
    wire [3:0] _unused;
    assign {_unused, yb} = vpos / 10'd12;

    wire [5:0] g_unused;
    wire [3:0] g_y;
    assign {g_unused, g_y} = vpos - {yb, 3'b000} - {1'b0, yb, 2'b00};

    wire hl;

    // Suppress unused signals warning
    wire _unused_ok = &{ena, ui_in[5:2], uio_in};

    reg [9:0] frame;
    reg rst_drop;

    // VGA output
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .mode(ui_in[7:6]),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    // String sequence map for "COLEGIO DE MUNTINLUPA - MICROELECTRONICS - 2026 " (43 characters)
    reg [5:0] text_rom [0:42];
    initial begin
        // COLEGIO DE MUNTINLUPA
        text_rom[0]  = 6'd1;  // C
        text_rom[1]  = 6'd0;  // O
        text_rom[2]  = 6'd2;  // L
        text_rom[3]  = 6'd3;  // E
        text_rom[4]  = 6'd4;  // G
        text_rom[5]  = 6'd5;  // I
        text_rom[6]  = 6'd0;  // O
        text_rom[7]  = 6'd7;  // [SPACE]
        text_rom[8]  = 6'd6;  // D
        text_rom[9]  = 6'd3;  // E
        text_rom[10] = 6'd7;  // [SPACE]
        text_rom[11] = 6'd8;  // M
        text_rom[12] = 6'd9;  // U
        text_rom[13] = 6'd10; // N
        text_rom[14] = 6'd11; // T
        text_rom[15] = 6'd5;  // I
        text_rom[16] = 6'd2;  // L
        text_rom[17] = 6'd9;  // U
        text_rom[18] = 6'd12; // P
        text_rom[19] = 6'd13; // A
        text_rom[20] = 6'd7;  // [SPACE]

        // - 
        text_rom[21] = 6'd19; // -
        text_rom[22] = 6'd7;  // [SPACE]

        // MICROELECTRONICS
        text_rom[23] = 6'd8;  // M
        text_rom[24] = 6'd5;  // I
        text_rom[25] = 6'd1;  // C
        text_rom[26] = 6'd14; // R
        text_rom[27] = 6'd0;  // O
        text_rom[28] = 6'd3;  // E
        text_rom[29] = 6'd2;  // L
        text_rom[30] = 6'd3;  // E
        text_rom[31] = 6'd1;  // C
        text_rom[32] = 6'd11; // T
        text_rom[33] = 6'd14; // R
        text_rom[34] = 6'd0;  // O
        text_rom[35] = 6'd10; // N
        text_rom[36] = 6'd5;  // I
        text_rom[37] = 6'd1;  // C
        text_rom[38] = 6'd15; // S
        text_rom[39] = 6'd7;  // [SPACE]

        // - 2026
        text_rom[40] = 6'd19; // -
        text_rom[41] = 6'd7;  // [SPACE]
        text_rom[42] = 6'd16; // 2
        text_rom[43] = 6'd17; // 0
        text_rom[44] = 6'd16; // 2
        text_rom[45] = 6'd18; // 6
        text_rom[46] = 6'd7;  // [SPACE]
    end

    wire [5:0] char_pos = (yb + xb) % 6'd47;
    wire [5:0] glyph_index = text_rom[char_pos];

    // glyphs
    glyphs_rom glyphs(
        .c(glyph_index),
        .y(g_y),
        .x(g_x),
        .pixel(hl)
    );

    // palette
    wire [5:0] color;
    palette_rom palettes(
        .cid(y),
        .pid(ui_in[1:0]),
        .color(color)
    );

    wire [1:0] a = xb[1:0];
    wire [3:0] b = xb[5:2];
    wire [2:0] d = xb[3:2] + 2'd3;

    // column features
    wire s = ^xb[6:0]; // speed of rain
    wire n = xb[1] ^ xb[3] ^ xb[5]; // lit on or off
    wire [6:0] v = (s ? frame[8:2] : frame[9:3]) - yb - x_mix;
    wire [3:0] c = {1'b0, a} + d;
    wire [6:0] e = {3'b000, b} << c;
    wire [6:0] f = v & e;
    wire [6:0] x = v >> a;
    wire [2:0] y = ~x[2:0];

    wire [9:0] drop = {1'b0, yb, 3'd0} >> s;
    wire drop_bit = ({3'd0, x_mix} + drop > frame) & ~rst_drop;

    wire [5:0] glyph_color = {6{drop_bit}} ^ color;
    wire [5:0] z = (&(~v[2:0]) & &(y)) ? 6'd63 : glyph_color;

    wire [5:0] RGB = (display_on & hl & ~(|f | n | drop_bit)) ? z : 6'd0;

    always @(posedge vsync, negedge rst_n) begin
        if (~rst_n) begin
            rst_drop <= 0;
            frame <= 0;
        end else begin
            if (&frame) begin
                rst_drop <= 1;
            end
            frame <= frame + 1;
        end
    end

endmodule