`default_nettype none
module glyphs_rom(
    input  wire [5:0] c,
    input  wire [3:0] y,
    input  wire [2:0] x,
    output reg pixel
);
    reg [7:0] rb;

    always @(*) begin
        case (c)
            6'd0:  case(y) 2:rb=8'h3C; 3,9:rb=8'h66; 4,5,6,7,8:rb=8'hC3; 10:rb=8'h3C; default:rb=0; endcase // O
            6'd1:  case(y) 2,10:rb=8'h7E; 3,9:rb=8'hC3; 4,5,6,7,8:rb=8'hC0; default:rb=0; endcase // C
            6'd2:  case(y) 2,3,4,5,6,7,8,9:rb=8'hC0; 10:rb=8'hFE; default:rb=0; endcase // L
            6'd3:  case(y) 2,6,10:rb=8'hFE; 3,4,5,7,8,9:rb=8'hC0; default:rb=0; endcase // E
            6'd4:  case(y) 2,10:rb=8'h7E; 3,4,5:rb=8'hC0; 6:rb=8'hCE; 7,8,9:rb=8'hC6; default:rb=0; endcase // G
            6'd5:  case(y) 2,10:rb=8'h7E; 3,4,5,6,7,8,9:rb=8'h18; default:rb=0; endcase // I
            6'd6:  case(y) 2,10:rb=8'hF8; 3,4,5,6,7,8,9:rb=8'hC6; default:rb=0; endcase // D
            6'd7:  rb = 8'h00; // SPACE
            6'd8:  case(y) 2:rb=8'hC3; 3:rb=8'hE7; 4:rb=8'hFF; 5:rb=8'hDB; 6,7,8,9,10:rb=8'hC3; default:rb=0; endcase // M
            6'd9:  case(y) 2,3,4,5,6,7,8,9:rb=8'hC6; 10:rb=8'h7E; default:rb=0; endcase // U
            6'd10: case(y) 2,3:rb=8'hC6; 4:rb=8'hE6; 5:rb=8'hF6; 6:rb=8'hD6; 7:rb=8'hC6; 8:rb=8'hCE; 9,10:rb=8'hC6; default:rb=0; endcase // N
            6'd11: case(y) 2:rb=8'hFF; 3,4,5,6,7,8,9,10:rb=8'h18; default:rb=0; endcase // T
            6'd12: case(y) 2,6:rb=8'hFC; 3,4,5:rb=8'hC6; 7,8,9,10:rb=8'hC0; default:rb=0; endcase // P
            6'd13: case(y) 2:rb=8'h3C; 3,4,5:rb=8'h66; 6,7:rb=8'hFF; 8,9,10:rb=8'hC3; default:rb=0; endcase // A
            6'd14: case(y) 2,6:rb=8'hFC; 3,4,5:rb=8'hC6; 7,8,9:rb=8'hD8; 10:rb=8'hC6; default:rb=0; endcase // R
            6'd15: case(y) 2:rb=8'h3E; 3:rb=8'h63; 4:rb=8'h60; 5:rb=8'h7C; 6,7:rb=8'h06; 8:rb=8'h63; 9:rb=8'h3E; default:rb=0; endcase // S
            6'd16: case(y) 2:rb=8'h3E; 3:rb=8'h63; 4:rb=8'h03; 5:rb=8'h06; 6:rb=8'h1C; 7:rb=8'h30; 8,9:rb=8'h60; 10:rb=8'hFF; default:rb=0; endcase // 2
            6'd17: case(y) 2,10:rb=8'h3C; 3,4,5,6,7,8,9:rb=8'h66; default:rb=0; endcase // 0
            6'd18: case(y) 2:rb=8'h3E; 3,4:rb=8'h60; 5:rb=8'h7C; 6,7,8,9:rb=8'h66; 10:rb=8'h3C; default:rb=0; endcase // 6
            6'd19: case(y) 6:rb=8'h7E; default:rb=0; endcase // HYPHEN (-)
            default: rb = 8'h00;
        endcase
        pixel = rb[7-x];
    end
endmodule