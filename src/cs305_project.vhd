LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.util.all;

entity cs305_project is
	port (
		clk, bt2 : IN std_logic;
		mouse_data, mouse_clk : INOUT std_logic;
		btn_1, left_btn : OUT std_logic;
		horiz_sync_out, vert_sync_out : OUT std_logic;
		state_ind : OUT std_logic_vector(3 downto 0);
		red_out, green_out, blue_out : OUT std_logic_vector(3 downto 0);
		seg0, seg1, seg2, seg3 : OUT std_logic_vector(6 downto 0)
	);
end entity cs305_project;

architecture arch of cs305_project is

	constant NUM_LAYERS : integer := 6;
	constant N_SCORE : integer := 3;
	constant N_STREAK : integer := 2;

--Component description begins

	component clock_div is
		port(
			clock : IN std_logic;
			q : OUT std_logic
		);
	end component clock_div;

	component rand_gen is 
		port (
			clock :  IN  std_logic;
			reset :  IN  std_logic;
			rand_num :  OUT  std_logic_vector(9 downto 0)
		);
	end component rand_gen;

	component dec_7seg is
		port(
			bcd_in : IN std_logic_vector (3 downto 0);
			seven_seg : OUT std_logic_vector (6 downto 0)
		); 
	end component dec_7seg;

	component MOUSE IS
		port(
			clock_25Mhz, reset : IN std_logic;
			signal mouse_data : INOUT std_logic;
			signal mouse_clk : INOUT std_logic;
			signal left_button, right_button : OUT std_logic;
			signal mouse_cursor_row : OUT std_logic_vector(9 downto 0); 
			signal mouse_cursor_column : OUT std_logic_vector(9 downto 0)
		);
	end component MOUSE;

	component layer_control is
		generic (
			NUM_INPUTS : integer := 4
		);
		port (
			layers : IN pixel((NUM_INPUTS - 1) downto 0);
			RGB_out	: OUT std_logic_vector(11 downto 0)
		);
	end component layer_control;


	component VGA_SYNC is
		port (
			clock_25Mhz : IN std_logic;
			red, green, blue : IN std_logic_vector(3 downto 0);
			red_out, green_out, blue_out : OUT std_logic_vector(3 downto 0);
			horiz_sync_out, vert_sync_out, enable_move : OUT std_logic;
			pixel_row, pixel_column: OUT std_logic_vector(9 downto 0)
		);
	end component VGA_SYNC;

	component fsm is
		port (
			clock, btn_1, left_btn, right_btn, off_screen, collision, win : IN std_logic;
			bullet_shot, ai_reset, ai_hold, ai_respawn, increase_score, increase_streak : OUT std_logic;
			state_indicator : OUT std_logic_vector(3 downto 0)
		);
	end component fsm;

	component user_tank is
		port (
			clock, enable_move : IN std_logic;
			pixel_row, pixel_col, mouse_col : IN std_logic_vector(9 downto 0);
			current_pos : OUT std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(15 downto 0)
		);
	end component user_tank;

	component ai_tank is
		generic (
			SPEED : in natural := 3
		);
		port (
			clock, reset, respawn, hold, enable_move : IN std_logic;
			pixel_row, pixel_col, new_pos, bullet_x_pos, bullet_y_pos : IN std_logic_vector(9 downto 0);
			collision, win	: OUT std_logic;
			RGB_out	: OUT std_logic_vector(15 downto 0)
		);
	end component ai_tank;

	component bullet is
		port (
			clock, move, enable_move : IN std_logic;
			pixel_row, pixel_col, new_pos : IN std_logic_vector(9 downto 0);
			off_screen : OUT std_logic;
			current_x_pos, current_y_pos : OUT std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(15 downto 0)
		);
	end component bullet;
	
	component draw_score is
		generic (
			SCORE_N, STREAK_N : integer := 2
		);
		port(
			clk : in std_logic;
			score : in N_digit_num(SCORE_N-1 downto 0);
			streak : in N_digit_num(STREAK_N-1 downto 0);
			pixel_row, pixel_col : in std_logic_vector(9 downto 0);
			colour_out : out std_logic_vector(15 downto 0)
		);
	end component draw_score;

	component background is
		port (
			clock : IN std_logic;
			pixel_row, pixel_col : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(15 downto 0)
		);
	end component background;

	component counter is
		generic (
			N : integer := 2 
		);
		port (
			clock, count, reset : IN std_logic;
			Q : OUT N_digit_num(N-1 downto 0)
		);
	end component counter;

	component debounce is
		port (
			clock, button : IN std_logic;
			Q : OUT std_logic
		);
	end component debounce;
	
	component delay is
		port(
			clk, input : in std_logic;
			output : out std_logic
		);
	end component;

--Component description ends

	signal divided_clk, left_button, shoot_signal, right_button : std_logic;
	signal off_screen, collision1, collision2, bullet_shot : std_logic;
	signal increase_score, increase_streak : std_logic;
	signal ai_reset, ai_hold, ai_respawn : std_logic;
	signal mouse_x_location, random_pos, user_location : std_logic_vector(9 downto 0);
	signal pixel_row, pixel_col : std_logic_vector(9 downto 0);
	signal bullet_y_pos, bullet_x_pos : std_logic_vector(9 downto 0);
	signal layers : pixel(NUM_LAYERS-1 downto 0);
	signal RGB_out : std_logic_vector(11 downto 0);
	signal not_bt2, enable_move : std_logic;
	signal delay_in, delay_out : std_logic;
	signal win1, win2 : std_logic;
	signal current_score : N_digit_num(N_SCORE-1 downto 0);
	signal streak_score : N_digit_num(N_STREAK-1 downto 0);

begin
	ClockDivider : clock_div port map(clk, divided_clk);
	MouseController : MOUSE port map(divided_clk, '0', mouse_data, mouse_clk, left_button, right_button, open, mouse_x_location);
	MouseDebouncer : debounce port map(divided_clk, left_button, shoot_signal);
	StateMachine : fsm port map(divided_clk, not_bt2, shoot_signal, right_button, off_screen, collision1 or collision2, win1 or win2, bullet_shot, ai_reset, ai_hold, ai_respawn, increase_score, increase_streak, state_ind);
	SevenSegDecoder1 : dec_7seg port map(current_score(0), seg0);
	SevenSegDecoder2 : dec_7seg port map(current_score(1), seg1);
	SevenSegDecoder3 : dec_7seg port map(current_score(2), seg2);
	SevenSegDecoder4 : dec_7seg port map("0000", seg3);
	RandomNumberGen : rand_gen port map(divided_clk, '1', random_pos);
	UserTank : user_tank port map(divided_clk, enable_move, pixel_row, pixel_col, mouse_x_location, user_location, layers(3));
	UserBullet : bullet port map(divided_clk, bullet_shot, enable_move, pixel_row, pixel_col, user_location, off_screen, bullet_x_pos, bullet_y_pos, layers(2));
	AiTank : ai_tank generic map (3) port map(divided_clk, ai_reset, increase_streak, ai_hold, enable_move, pixel_row, pixel_col, random_pos, bullet_x_pos, bullet_y_pos, collision1, win1, layers(0));
	AiTank2 : ai_tank generic map (5) port map(divided_clk, delay_out, increase_streak, ai_hold, enable_move, pixel_row, pixel_col, random_pos, bullet_x_pos, bullet_y_pos, collision2, win2, layers(1));
	LayerControl : layer_control generic map (NUM_LAYERS) port map(layers, RGB_out);
	DisplayControl : VGA_SYNC port map(divided_clk, RGB_out(11 downto 8), RGB_out(7 downto 4), RGB_out(3 downto 0), red_out, green_out, blue_out, horiz_sync_out, vert_sync_out, enable_move, pixel_row, pixel_col);
	DelayControl : delay port map (divided_clk, delay_in, delay_out);
	DrawScore : draw_score generic map (N_SCORE, N_STREAK) port map (divided_clk, current_score, streak_score, pixel_row, pixel_col, layers(4));
	BackgorundImage : background port map (divided_clk, pixel_row, pixel_col, layers(5));
	ScoreCounter : counter generic map (N_SCORE) port map(divided_clk, increase_score, '0', current_score);
	StreakCounter : counter generic map (N_STREAK) port map(divided_clk, increase_streak, off_screen OR ai_respawn, streak_score);
	
	not_bt2 <= NOT bt2;
	btn_1 <= NOT bt2;
	left_btn <= shoot_signal;
	delay_in <= ai_reset;
	
end architecture arch;
