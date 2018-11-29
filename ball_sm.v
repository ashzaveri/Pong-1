//////////////////////////////////////////////////////
// File Name:   Ball State Machine
// Author   :   Mikey Takla, Ash Zaveri, Jay Gutierrez
//////////////////////////////////////////////////////

module ball_sm(clk, reset, sys_clk, p1_position, p2_position, vga_h_sync, vga_v_sync, inDisplayArea, CounterX, CounterY, b_display, p1_score, p2_score);
input clk;
input reset;
input sys_clk;
input [9:0] p1_position;
input [9:0] p2_position;
output vga_h_sync, vga_v_sync;
output inDisplayArea;
output [9:0] CounterX;
output [9:0] CounterY;
output b_display;
output [3:0] p1_score;
output [3:0] p2_score;

//CounterX and CounterY are used in this file AND top file
//other outputs from hvsync_gen ony used in top file
wire [9:0] X, Y;
hvsync_generator hvsync_gen(.clk(clk), .reset(reset), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(X), .CounterY(Y));
assign CounterX = X;
assign CounterY = Y;

//local signals
reg [9:0] ball_x;
reg [9:0] ball_y;
reg [4:0] state;
reg TOP1, BOP1, TOP2, BOP2;
wire [9:0] p1_max, p1_min, p2_max, p2_min;
reg [3:0] score1, score2;

assign p1_max = p1_position + 45;
assign p1_min = p1_position - 45;
assign p2_max = p2_position + 45;
assign p2_min = p2_position - 45 ;

localparam
	Q_I  = 6'b000001,
	Q_UR = 6'b000010,
	Q_DL = 6'b000100,
	Q_UL = 6'b001000,
	Q_DR = 6'b010000,
	Q_DONE = 6'b100000,
	P2 = 605,
	P1 = 35,
	Y_MAX = 476,
	Y_HALF = 245,
	Y_MIN = 5;
	
//state machine
always @ (posedge sys_clk)
	begin
		if (reset)
			begin
			state <= Q_I;
			ball_x <= 300;
			ball_y <= 245;
			TOP1 <= 0;
			BOP1 <= 0;
			TOP2 <= 0;
			BOP2 <= 0;
			end
		else
			begin
			TOP1 <= (ball_y >= p1_min && ball_y < p1_position);
			BOP1 <= (ball_y >= p1_position && ball_y <= p1_max);
			TOP2 <= (ball_y >= p2_min && ball_y < p2_position);
			BOP2 <= (ball_y >= p2_position && ball_y <= p2_max);
			case(state)
				Q_I:
					begin
					//state transitions
					state <= Q_DL;
					//RTL
					ball_x <= 300;
					ball_y <= 245;
					end
				Q_UR:
					begin
					//state transitions (and scorekeeping)
					if (ball_x < P2)
						begin
						if (ball_y <= Y_MIN)
							state <= Q_DR;
						end
					else
						begin
						if ((ball_y > Y_HALF && TOP2) || (ball_y <= Y_HALF && BOP2))
							state <= Q_UL;
						else if ((ball_y > Y_HALF && BOP2) || (ball_y <= Y_HALF && TOP2))
							state <= Q_DL;
						else
							begin
							score1 <= score1 + 1;
							if (score1 < 9)
								state <= Q_I;
							else
								state <= Q_DONE;
							end
						end
					//RTL
					ball_x <= ball_x + 5;
					ball_y <= ball_y - 5;
					end
				Q_DL:
					begin
					//state transitions
					if (ball_x > P1)
						begin
						if (ball_y >= Y_MAX)
							state <= Q_UL;
						end
					else
						begin
						if ((ball_y > Y_HALF && TOP1) || (ball_y <= Y_HALF && BOP1))
							state <= Q_DR;
						else if ((ball_y > Y_HALF && BOP1) || (ball_y <= Y_HALF && TOP1))
							state <= Q_UR;
						else
							begin
							score2 <= score2 + 1;
							if (score2 < 9)
								state <= Q_I;
							else
								state <= Q_DONE;
							end
						end
					//RTL
					ball_x <= ball_x - 6;
					ball_y <= ball_y + 6;
					end
				Q_UL:
					begin
					//state transitions
					if (ball_x > P1)
						begin
						if (ball_y <= Y_MIN)
							state <= Q_DL;
						end
					else
						begin
						if ((ball_y > Y_HALF && TOP1) || (ball_y <= Y_HALF && BOP1))
							state <= Q_UR;
						else if ((ball_y > Y_HALF && BOP1) || (ball_y <= Y_HALF && TOP1))
							state <= Q_DR;
						else
							begin
							score2 <= score2 + 1;
							if (score2 < 9)
								state <= Q_I;
							else
								state <= Q_DONE;
							end
						end
					//RTL
					ball_x <= ball_x - 7;
					ball_y <= ball_y - 5;
					end
				Q_DR:
					begin
					//state transitions
					if (ball_x < P2)
						begin
						if (ball_y >= Y_MAX)
							state <= Q_UR;
						end
					else
						begin
						if ((ball_y > Y_HALF && TOP2) || (ball_y <= Y_HALF && BOP2))
							state <= Q_DL;
						else if ((ball_y > Y_HALF && BOP2) || (ball_y <= Y_HALF && TOP2))
							state <= Q_UL;
						else
							begin
							score1 <= score1 + 1;
							if (score1 < 9)
								state <= Q_I;
							else
								state <= Q_DONE;
							end
						end
					//RTL
					ball_x <= ball_x + 5;
					ball_y <= ball_y + 7;
					end
				Q_DONE:
					begin
					ball_x <= 300;
					ball_y <= 250;
					end
				default:
					begin
					state <= 5'bXXXXX;
					end
			endcase
		end
	end
	
assign b_display = ball_x <= (X+5) && ball_x >= (X-5) && ball_y <= (Y+5) && ball_y >= (Y-5);
assign p1_score = score1;
assign p2_score = score2;

endmodule
