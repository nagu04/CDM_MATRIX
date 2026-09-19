module tt_um_vga_snake (
    input  wire [7:0] ui_in,       // [0..3]=Direct buttons, [4]=PS/2 CLK, [5]=PS/2 DATA
    output wire [7:0] uo_out,      // VGA Output
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // =========================================================
    // UNUSED BIDIRECTIONAL PINS
    // =========================================================
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // =========================================================
    // PS/2 KEYBOARD DECODER INSTANTIATION
    // =========================================================
    wire ps2_up, ps2_down, ps2_left, ps2_right;

    ps2_arrows u_ps2 (
        .clk         (clk),
        .rst_n       (rst_n),
        .ps2_clk_in  (ui_in[4]),    // PS/2 Clock line
        .ps2_data_in (ui_in[5]),    // PS/2 Data line
        .key_up      (ps2_up),
        .key_down    (ps2_down),
        .key_left    (ps2_left),
        .key_right   (ps2_right)
    );

    // Combine direct UI button inputs with PS/2 Keyboard signals
    wire move_up    = ui_in[0] | ps2_up;
    wire move_down  = ui_in[1] | ps2_down;
    wire move_left  = ui_in[2] | ps2_left;
    wire move_right = ui_in[3] | ps2_right;

    // =========================================================
    // VGA OUTPUT
    // =========================================================
    reg [1:0] R;
    reg [1:0] G;
    reg [1:0] B;

    reg hsync;
    reg vsync;

    assign uo_out[0] = R[1];
    assign uo_out[1] = G[1];
    assign uo_out[2] = B[1];
    assign uo_out[3] = vsync;
    assign uo_out[4] = R[0];
    assign uo_out[5] = G[0];
    assign uo_out[6] = B[0];
    assign uo_out[7] = hsync;

    // =========================================================
    // VGA TIMING (640x480 @ 60Hz)
    // =========================================================
    reg [9:0] h_cnt;
    reg [9:0] v_cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
        end else begin
            if (h_cnt == 10'd799) begin
                h_cnt <= 10'd0;
                if (v_cnt == 10'd524)
                    v_cnt <= 10'd0;
                else
                    v_cnt <= v_cnt + 10'd1;
            end else begin
                h_cnt <= h_cnt + 10'd1;
            end
        end
    end

    wire video_on = (h_cnt < 10'd640) && (v_cnt < 10'd480);

    always @(*) begin
        if ((h_cnt >= 10'd656) && (h_cnt < 10'd752))
            hsync = 1'b0;
        else
            hsync = 1'b1;

        if ((v_cnt >= 10'd490) && (v_cnt < 10'd492))
            vsync = 1'b0;
        else
            vsync = 1'b1;
    end

    // =========================================================
    // SNAKE GRID (20 x 15 cells, 32x32 pixels each)
    // =========================================================
    wire [4:0] cell_x = h_cnt[9:5];
    wire [3:0] cell_y = v_cnt[8:5];

    // =========================================================
    // GAME REGISTERS & GROWING SNAKE ARRAY
    // =========================================================
    localparam MAX_LEN = 16;

    reg [4:0] head_x;
    reg [3:0] head_y;

    reg [4:0] body_x [0:MAX_LEN-1];
    reg [3:0] body_y [0:MAX_LEN-1];
    reg [3:0] snake_len; // Current number of body segments

    reg [4:0] food_x;
    reg [3:0] food_y;

    reg [1:0] dir;
    reg [2:0] move_clk;

    wire frame_tick = (h_cnt == 10'd0) && (v_cnt == 10'd480);

    // =========================================================
    // INSTANT CONTROLS SAMPLING (SUPPORTS BOTH PS/2 & UI_IN)
    // =========================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            dir <= 2'b11; // Default RIGHT
        end else begin
            if (move_up    && dir != 2'b01) dir <= 2'b00; // UP
            else if (move_down  && dir != 2'b00) dir <= 2'b01; // DOWN
            else if (move_left  && dir != 2'b11) dir <= 2'b10; // LEFT
            else if (move_right && dir != 2'b10) dir <= 2'b11; // RIGHT
        end
    end

    integer i;

    // =========================================================
    // SNAKE GAME MOVEMENT & GROWTH LOGIC
    // =========================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            head_x    <= 5'd10;
            head_y    <= 4'd7;
            food_x    <= 5'd15;
            food_y    <= 4'd7;
            move_clk  <= 3'd0;
            snake_len <= 4'd3;   // Starting body length

            body_x[0] <= 5'd9; body_y[0] <= 4'd7;
            body_x[1] <= 5'd8; body_y[1] <= 4'd7;
            body_x[2] <= 5'd7; body_y[2] <= 4'd7;

            for (i = 3; i < MAX_LEN; i = i + 1) begin
                body_x[i] <= 5'd0;
                body_y[i] <= 4'd0;
            end
        end else if (frame_tick) begin
            if (move_clk == 3'd7) begin
                move_clk <= 3'd0;

                // Shift body segments backward
                for (i = MAX_LEN - 1; i > 0; i = i - 1) begin
                    body_x[i] <= body_x[i-1];
                    body_y[i] <= body_y[i-1];
                end
                body_x[0] <= head_x;
                body_y[0] <= head_y;

                // Move head position
                case (dir)
                    2'b00: head_y <= (head_y == 4'd0)  ? 4'd14 : head_y - 4'd1;
                    2'b01: head_y <= (head_y == 4'd14) ? 4'd0  : head_y + 4'd1;
                    2'b10: head_x <= (head_x == 5'd0)  ? 5'd19 : head_x - 5'd1;
                    2'b11: head_x <= (head_x == 5'd19) ? 5'd0  : head_x + 5'd1;
                endcase

                // Food Collision & Growth
                if ((head_x == food_x) && (head_y == food_y)) begin
                    // Grow snake body up to MAX_LEN
                    if (snake_len < MAX_LEN) begin
                        snake_len <= snake_len + 4'd1;
                    end

                    // Relocate food
                    if (food_x >= 5'd13)
                        food_x <= 5'd2;
                    else
                        food_x <= food_x + 5'd7;

                    if (food_y >= 4'd10)
                        food_y <= 4'd2;
                    else
                        food_y <= food_y + 4'd5;
                end
            end else begin
                move_clk <= move_clk + 3'd1;
            end
        end
    end

    // =========================================================
    // PIXEL DETECTION
    // =========================================================
    wire is_head = (cell_x == head_x) && (cell_y == head_y);

    reg is_body;
    integer j;
    always @(*) begin
        is_body = 1'b0;
        for (j = 0; j < MAX_LEN; j = j + 1) begin
            if (j < snake_len) begin
                if ((cell_x == body_x[j]) && (cell_y == body_y[j]))
                    is_body = 1'b1;
            end
        end
    end

    wire is_food = (cell_x == food_x) && (cell_y == food_y);

    // =========================================================
    // DRAWING PIPELINE
    // =========================================================
    always @(*) begin
        if (!video_on) begin
            R = 2'b00; G = 2'b00; B = 2'b00;
        end else if (is_head || is_body) begin
            R = 2'b00; G = 2'b11; B = 2'b00; // Green Snake
        end else if (is_food) begin
            R = 2'b11; G = 2'b00; B = 2'b00; // Red Food
        end else begin
            R = 2'b00; G = 2'b00; B = 2'b01; // Blue Background
        end
    end

endmodule