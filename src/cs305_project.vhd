LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.util.all;

entity cs305_project is
	port (
		clk, bt0, bt1, bt2, sw0 : IN std_logic;
		mouse_data, mouse_clk : INOUT std_logic;
		led : OUT std_logic_vector(9 downto 0);
		horiz_sync_out, vert_sync_out : OUT std_logic;
		red_out, green_out, blue_out : OUT std_logic_vector(3 downto 0);
		seg0, seg1, seg2, seg3 : OUT std_logic_vector(6 downto 0);
		audio_out : OUT std_logic;
		
		-- FLASH
		flash_address : out std_logic_vector(21 downto 0);
		flash_data : in std_logic_vector(15 downto 0);
		flash_byte_word_mode, flash_chip_enable, flash_output_enable, flash_reset, flash_write_enable, flash_write_protect : out std_logic
	);
end entity cs305_project;

architecture arch of cs305_project is

	constant N_AI_TANK : integer := 3;
	constant NUM_LAYERS : integer := N_AI_TANK + 6;
	constant N_SCORE : integer := 3;
	constant N_STREAK : integer := 2;
	constant N_TIMER : integer := 2;
	type string_array is array (0 to 2) of string(1 to 21);
	constant AI_IMAGES : string_array := ("images/enemyTank1.mif", "images/enemyTank2.mif", "images/enemyTank3.mif");

	component rand_gen is 
		port (
			clock :  IN  std_logic;
			reset :  IN  std_logic;
			rand_num :  OUT  std_logic_vector(9 downto 0)
		);
	end component rand_gen;

	-------------------------------------------------------------------------------
	-----------------------------Signal Definitions--------------------------------
	-------------------------------------------------------------------------------

	--System signals
	signal divided_clk, one_sec_clk, paused_clk : std_logic;
	signal s_flash_address : std_logic_vector(21 downto 0);

	--Position signals
	signal bullet_y_pos, bullet_x_pos : std_logic_vector(9 downto 0);
	signal mouse_x_location, mouse_y_location, random_pos, user_location : std_logic_vector(9 downto 0);

	--Graphics signals
	signal layers : pixel(NUM_LAYERS-1 downto 0);
	signal RGB_out : std_logic_vector(11 downto 0);
	signal pixel_row, pixel_col, h_count : std_logic_vector(9 downto 0);
	signal enable_move, enable_move_signal, show_game_objects : std_logic;
	signal background : integer range 0 to 6;

	--User input signals
	signal left_button, right_button, middle_button, not_bt2, not_bt1 : std_logic;
	signal start_game, timerReset : std_logic;
	signal pause : std_logic;

	--gameFSM outputs
	signal bullet_shot, ai_tank_hit : std_logic;
	signal ai_reset, ai_respawn : std_logic;

	--AI tanks signals
	signal start_tank, collisions_out, wins_out : std_logic_vector(N_AI_TANK-1 downto 0) := (others => '0');
	signal bullet_collision, ai_win, ai_died, tank_move : std_logic := '0';

	--Bullet signals
	signal off_screen, shoot_signal : std_logic;
	
	--Counter values
	signal current_score : N_digit_num(N_SCORE-1 downto 0);
	signal streak_score : N_digit_num(N_STREAK-1 downto 0);
	signal timer : N_digit_num(N_TIMER-1 downto 0);
	signal health : integer range 0 to 3 := 3;
	signal countdown : integer range 0 to 3 := 3;
	
	--Menu/controller states
	signal playerWin, playerDie : std_logic;
	signal playClick, trainClick : std_logic;
	signal play_hover, train_hover : std_logic;
	signal showMenu, trainingMode : std_logic;
	signal level : std_logic_vector(1 downto 0);
	signal controllerState : states;

	-------------------------------------------------------------------------------
	---------------------------Signal Definitions End------------------------------
	-------------------------------------------------------------------------------

	
begin

	-------------------------------------------------------------------------------
	----------------------------Entity Instantiations------------------------------
	-------------------------------------------------------------------------------

	--Helper blocks
	ClockDivider : entity work.clock_div port map(clk, divided_clk);
	MouseController : entity work.MOUSE port map(divided_clk, '0', mouse_data, mouse_clk, left_button, right_button, middle_button, mouse_y_location, mouse_x_location);
	MouseDebouncer : entity work.debounce port map(divided_clk, left_button, shoot_signal);
	RandomNumberGen : rand_gen port map(divided_clk, '1', random_pos);
	PauseController : entity work.pause_toggle port map(divided_clk, middle_button, showMenu, pause);
	
	--FSMs
	ControllerFSM : entity work.controller_fsm port map(divided_clk, playClick, trainClick, playerWin, playerDie, left_button, not_bt2, showMenu, trainingMode, level, controllerState);
	GameFSM : entity work.fsm port map(divided_clk, showMenu, start_game, shoot_signal and not pause, off_screen, bullet_collision, ai_died, bullet_shot, ai_reset, ai_respawn, ai_tank_hit);
	
	--Game objects
	UserTank : entity work.user_tank port map(divided_clk, enable_move, pixel_row, pixel_col, mouse_x_location, user_location, layers(N_AI_TANK+3));
	UserBullet : entity work.bullet port map(divided_clk, bullet_shot, enable_move, pixel_row, pixel_col, user_location, off_screen, bullet_x_pos, bullet_y_pos, layers(N_AI_TANK+2));
	menuMouse : entity work.menu_mouse port map(divided_clk, left_button, enable_move, controllerState, mouse_x_location, mouse_y_location, pixel_row, pixel_col, play_hover, playClick, train_hover, trainClick, layers(N_AI_TANK+1));

	--Counters
	ScoreCounter : entity work.counter generic map (N_SCORE, false, (X"0", X"0", X"0")) port map(divided_clk, ai_tank_hit, playClick OR trainClick, current_score);
	StreakCounter : entity work.counter generic map (N_STREAK, false, (X"0", X"0")) port map(divided_clk, ai_tank_hit, off_screen OR ai_respawn OR playClick OR trainClick, streak_score);
	TimerCounter : entity work.counter generic map (N_STREAK, true, (X"3", X"0")) port map(divided_clk, paused_clk, timerReset, timer);

	--User outputs
	LayerControl : entity work.layer_control generic map (NUM_LAYERS) port map(show_game_objects, layers, RGB_out);
	SevenSegDecoder1 : entity work.dec_7seg port map(current_score(0), seg0);
	SevenSegDecoder2 : entity work.dec_7seg port map(current_score(1), seg1);
	SevenSegDecoder3 : entity work.dec_7seg port map(current_score(2), seg2);
	SevenSegDecoder4 : entity work.dec_7seg port map("0000", seg3);
	DisplayControl : entity work.VGA_SYNC port map(divided_clk, RGB_out(11 downto 8), RGB_out(7 downto 4), RGB_out(3 downto 0), red_out, green_out, blue_out, horiz_sync_out, vert_sync_out, enable_move_signal, pixel_row, pixel_col, h_count);
	DrawScore : entity work.draw_score generic map (N_SCORE, N_STREAK, N_TIMER) port map (divided_clk, current_score, streak_score, timer, health, countdown, pixel_row, pixel_col, layers(N_AI_TANK+4));
	ShowPause : entity work.draw_pause port map (divided_clk, pause, pixel_row, pixel_col, layers(0));
	BackgroundAndAudio : entity work.background_audio port map (divided_clk, bullet_collision, background, play_hover, train_hover, s_flash_address, flash_data, pixel_row, pixel_col, h_count, layers(N_AI_TANK+5), audio_out);
	
	--AI generation
	TANK_GEN: for i in 0 to N_AI_TANK-1 generate
		AiTank : entity work.ai_tank generic map (AI_IMAGES(i), (i+1)*4) port map (divided_clk, start_tank(i), ai_reset, ai_respawn, ai_tank_hit, tank_move, pixel_row, pixel_col, random_pos, bullet_x_pos, bullet_y_pos, collisions_out(i), wins_out(i), layers(i+1));
	end generate TANK_GEN;

	-------------------------------------------------------------------------------
	--------------------------Entity Instantiations End----------------------------
	-------------------------------------------------------------------------------


	playerDie <= '1' when health = 0 or timer = (X"F", X"9") else '0';
	start_game <= '1' when playerWin = '1' or countdown = 0 else '0';
	show_game_objects <= '0' when controllerState = menu or controllerState = fail or controllerState = success else '1';
	tank_move <= '1' when enable_move = '1' and countdown = 0 else '0';
	timerReset <= '1' when (playerWin = '1' and controllerState /= training) or countdown > 0 else '0';
	enable_move <= '1' when enable_move_signal = '1' and pause = '0' else '0';
	paused_clk <= one_sec_clk and not pause;

	awfulHardcodedRubbish : process( divided_clk )
		variable oldLevel : std_logic_vector(1 downto 0);
	begin
		if(rising_edge(divided_clk)) then
			if not (level = oldLevel) then
				if level = "11" then
					start_tank(0) <= '0';
					start_tank(1) <= '0';
					start_tank(2) <= '1';
				elsif level = "10" then
					start_tank(0) <= '0';
					start_tank(1) <= '1';
					start_tank(2) <= '0';
				elsif level = "01" then
					start_tank(0) <= '1';
					start_tank(1) <= '0';
					start_tank(2) <= '0';
				end if;
				oldLevel := level;
			else
				start_tank(0) <= '0';
				start_tank(1) <= '0';
				start_tank(2) <= '0';
			end if;
		end if;
	end process ; -- awfulHardcodedRubbish

	count_down : process (divided_clk) is
		variable count : integer range 0 to 25000000;
	begin
		if rising_edge(divided_clk) then
			if (playClick = '1' or trainClick = '1') then
				countdown <= 3;
				count := 0;
			elsif (countdown > 0 and pause = '0') then
				count := count + 1;
				if (count = 25000000) then
					countdown <= countdown - 1;
					count := 0;
				end if;
			end if;
		end if;
	end process count_down;

	rightClickRisingEdge : process( divided_clk )
		variable oldvalue : N_digit_num(2 downto 0);
	begin
		if(rising_edge(divided_clk)) then
			playerWin <= '0';
			if (oldvalue /= current_score) then
				if(current_score = (X"0", X"1", X"0")) then
					playerWin <= '1';
				elsif(current_score = (X"0", X"2", X"0")) then
					playerWin <= '1';
				elsif(current_score = (X"0", X"3", X"0")) then
					playerWin <= '1';
				end if;
			end if;
			oldvalue := current_score;
		end if;
	end process ; -- rightClickRisingEdge

	aiwinrisingedge : process( divided_clk )
		variable oldvalue : std_logic;
	begin
		if(rising_edge(divided_clk)) then
			if (oldvalue /= ai_win) and ai_win = '1' then
				ai_died <= '1';
			else
				ai_died <= '0';
			end if;
			oldvalue := ai_win;
		end if;
	end process ; -- aiwinrisingedge


	bullet_collision <= or_gate(collisions_out);
	ai_win <= or_gate(wins_out);
	
	not_bt2 <= NOT bt2;
	not_bt1 <= NOT bt1;
	led(9) <= NOT bt2;
	led(0) <= shoot_signal;
	led(1) <= left_button;
	led(2) <= playClick;
	led(3) <= showMenu;
	led(4) <= ai_reset;
	led(5) <= playerWin;

	with controllerState select background <=
		0 when menu,
		1 when success,
		2 when fail,
		3 when level1,
		6 when training,
		4 when level2,
		5 when level3;

	healthModifier : process( divided_clk )
		variable prev_streak : std_logic_vector(3 downto 0) := X"0";
	begin
		if (rising_edge(divided_clk)) then
			if (showMenu = '1') then
				health <= 3;
			elsif (ai_respawn = '1') then
				health <= health - 1;
			elsif (streak_score(0) /= prev_streak and streak_score = (X"0", X"5") and health < 3) then
				health <= health + 1;
				prev_streak := streak_score(0);
			end if;
		end if;
	end process ; -- healthModifier

	one_sec: process (divided_clk) is
		variable count : integer range 0 to 25000000 := 0;
	begin
		if rising_edge(divided_clk) then
			if (count = 25000000) then
				one_sec_clk <= '1';
				count := 0;
			else
				one_sec_clk <= '0';
				count := count + 1;
			end if;
		end if;
	end process one_sec;
	
	-- FLASH (word mode)
	flash_address <= s_flash_address;
	flash_chip_enable <= '0';
	flash_output_enable <= '0';
	flash_write_enable <= '1';
	flash_reset <= '1';
	flash_write_protect <= '0';
	flash_byte_word_mode <= '1';
	
end architecture arch;
