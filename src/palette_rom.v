/*  
 * Palette ROM configured for Red, Purple, and Blue
 * Format: 6-bit RRGGBB
 */
`default_nettype none

module palette_rom(
    input  wire [2:0] cid,   // color depth / intensity level (0-7)
    input  wire [1:0] pid,   // palette ID selected by input switches
    output wire [5:0] color  // color output (RRGGBB)
);

    reg [5:0] palette[3:0][7:0];
    assign color = palette[pid][cid];

    initial begin
        // Palette 0: Red Gradient
        palette[0][0] = 6'b000000; // Black
        palette[0][1] = 6'b010000; // Very Dim Red
        palette[0][2] = 6'b100000; // Dim Red
        palette[0][3] = 6'b110000; // Red
        palette[0][4] = 6'b110001; // Bright Red
        palette[0][5] = 6'b110101; // Red-Pink Accent
        palette[0][6] = 6'b110110; // Light Magenta-Red
        palette[0][7] = 6'b111010; // Intense Bright Red

        // Palette 1: Purple / Violet Gradient
        palette[1][0] = 6'b000000; // Black
        palette[1][1] = 6'b010001; // Dark Violet
        palette[1][2] = 6'b100010; // Medium Purple
        palette[1][3] = 6'b110011; // Pure Purple
        palette[1][4] = 6'b110111; // Bright Purple
        palette[1][5] = 6'b111011; // Light Orchid
        palette[1][6] = 6'b110110; // Magenta Tint
        palette[1][7] = 6'b111111; // White-Hot Highlight

        // Palette 2: Blue Gradient
        palette[2][0] = 6'b000000; // Black
        palette[2][1] = 6'b000001; // Dark Blue
        palette[2][2] = 6'b000010; // Medium Blue
        palette[2][3] = 6'b000011; // Royal Blue
        palette[2][4] = 6'b000111; // Bright Blue
        palette[2][5] = 6'b010111; // Cyan-Blue Accent
        palette[2][6] = 6'b011011; // Ice Blue
        palette[2][7] = 6'b101011; // Bright Sky Blue

        // Palette 3: Cycle Red / Purple / Blue Mix
        palette[3][0] = 6'b000000; // Black
        palette[3][1] = 6'b010000; // Red base
        palette[3][2] = 6'b100001; // Deep Purple
        palette[3][3] = 6'b110011; // Magenta/Purple
        palette[3][4] = 6'b010011; // Blue-Violet
        palette[3][5] = 6'b000011; // Deep Blue
        palette[3][6] = 6'b000111; // Bright Blue
        palette[3][7] = 6'b111111; // White Lead
    end

endmodule