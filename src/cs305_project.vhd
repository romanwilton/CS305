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
		seg0, seg1, seg2, seg3 : OUT std_logic_vector(6 downto 0);
		audio_out : OUT std_logic;
		
		-- FLASH
		flash_address : out std_logic_vector(21 downto 0);
		flash_data : in std_logic_vector(7 downto 0);
		flash_data_15 : out std_logic;
		flash_byte_word_mode, flash_chip_enable, flash_output_enable, flash_reset, flash_write_enable, flash_write_protect : out std_logic
	);
end entity cs305_project;

architecture arch of cs305_project is

	constant N_AI_TANK : integer := 3;
	constant NUM_LAYERS : integer := 4 + N_AI_TANK;
	constant N_SCORE : integer := 3;
	constant N_STREAK : integer := 2;
	type string_array is array (0 to 2) of string(1 to 21);
	constant AI_IMAGES : string_array := ("images/enemyTank1.mif", "images/enemyTank2.mif", "images/enemyTank3.mif");

	component rand_gen is 
		port (
			clock :  IN  std_logic;
			reset :  IN  std_logic;
			rand_num :  OUT  std_logic_vector(9 downto 0)
		);
	end component rand_gen;

	signal divided_clk, left_button, shoot_signal, right_button : std_logic;
	signal off_screen, bullet_shot : std_logic;
	signal increase_score, increase_streak : std_logic;
	signal ai_reset, ai_respawn : std_logic;
	signal mouse_x_location, random_pos, user_location : std_logic_vector(9 downto 0);
	signal pixel_row, pixel_col : std_logic_vector(9 downto 0);
	signal bullet_y_pos, bullet_x_pos : std_logic_vector(9 downto 0);
	signal layers : pixel(NUM_LAYERS-1 downto 0);
	signal RGB_out : std_logic_vector(11 downto 0);
	signal not_bt2, enable_move : std_logic;
	signal current_score : N_digit_num(N_SCORE-1 downto 0);
	signal streak_score : N_digit_num(N_STREAK-1 downto 0);
	signal collision, win : std_logic := '0';
	signal delays_out, collisions_out, wins_out : std_logic_vector(N_AI_TANK-1 downto 0) := (others => '0');
	signal s_flash_address : std_logic_vector(21 downto 0);
	signal health : integer range 0 to 3 := 3;
	signal playClick, trainClick : std_logic;
	signal playerWin, playerDie : std_logic;
	signal showMenu, trainingMode : std_logic;
	signal level : std_logic_vector(1 downto 0);

	--TODO remove this when menu is actually implemented
	signal temp_red_out : std_logic_vector(3 downto 0);

begin
	--Helper blocks
	ClockDivider : entity work.clock_div port map(clk, divided_clk);
	MouseController : entity work.MOUSE port map(divided_clk, '0', mouse_data, mouse_clk, left_button, right_button, open, mouse_x_location);
	MouseDebouncer : entity work.debounce port map(divided_clk, left_button, shoot_signal);
	RandomNumberGen : rand_gen port map(divided_clk, '1', random_pos);
	
	--FSMs
	ControllerFSM : entity work.controller_fsm port map(divided_clk, playClick, trainClick, playerWin, playerDie, left_button, showMenu, trainingMode, level);
	GameFSM : entity work.fsm port map(divided_clk, not_bt2, shoot_signal, right_button, off_screen, collision, win, showMenu, bullet_shot, ai_reset, ai_respawn, increase_score, increase_streak, state_ind);
	
	--Game objects
	UserTank : entity work.user_tank port map(divided_clk, enable_move, pixel_row, pixel_col, mouse_x_location, user_location, layers(N_AI_TANK+1));
	UserBullet : entity work.bullet port map(divided_clk, bullet_shot, enable_move, pixel_row, pixel_col, user_location, off_screen, bullet_x_pos, bullet_y_pos, layers(N_AI_TANK+0));
	BackgorundImage : entity work.background port map (divided_clk, pixel_row, pixel_col, layers(N_AI_TANK+3));

	--Counters
	ScoreCounter : entity work.counter generic map (N_SCORE) port map(divided_clk, increase_score, '0', current_score);
	StreakCounter : entity work.counter generic map (N_STREAK) port map(divided_clk, increase_streak, off_screen OR ai_respawn, streak_score);

	--User outputs
	LayerControl : entity work.layer_control generic map (NUM_LAYERS) port map(layers, RGB_out);
	DisplayControl : entity work.VGA_SYNC port map(divided_clk, RGB_out(11 downto 8), RGB_out(7 downto 4), RGB_out(3 downto 0), temp_red_out, green_out, blue_out, horiz_sync_out, vert_sync_out, enable_move, pixel_row, pixel_col);
	DrawScore : entity work.draw_score generic map (N_SCORE, N_STREAK) port map (divided_clk, current_score, streak_score, health, pixel_row, pixel_col, layers(N_AI_TANK+2));
	SevenSegDecoder1 : entity work.dec_7seg port map(current_score(0), seg0);
	SevenSegDecoder2 : entity work.dec_7seg port map(current_score(1), seg1);
	SevenSegDecoder3 : entity work.dec_7seg port map(current_score(2), seg2);
	SevenSegDecoder4 : entity work.dec_7seg port map("0000", seg3);
	AudioPWM : entity work.audio generic map (1239040) port map (divided_clk, flash_data, audio_out, s_flash_address);
	
	--AI generation
	TANK_GEN: for i in 0 to N_AI_TANK-1 generate
		AiTank : entity work.ai_tank generic map (AI_IMAGES(i), (i+1)*2) port map (divided_clk, delays_out(i) or ai_reset, increase_streak, enable_move, pixel_row, pixel_col, random_pos, bullet_x_pos, bullet_y_pos, collisions_out(i), wins_out(i), layers(i));
	end generate TANK_GEN;

	red_out <= "1111" when showMenu = '1' else temp_red_out;
	playClick <= not_bt2;
	trainClick <= '0';
	playerDie <= '1' when health = 0 else '0';

	identifier : process( divided_clk )
		variable oldLevel : std_logic_vector(1 downto 0);
	begin
		if(rising_edge(divided_clk)) then
			if not (level = oldLevel) then
				if level = "11" then
					delays_out(0) <= '0';
					delays_out(1) <= '0';
					delays_out(2) <= '1';
				elsif level = "10" then
					delays_out(0) <= '0';
					delays_out(1) <= '1';
					delays_out(2) <= '0';
				elsif level = "01" then
					delays_out(0) <= '1';
					delays_out(1) <= '0';
					delays_out(2) <= '0';
				end if;
				oldLevel := level;
			else
				delays_out(0) <= '0';
				delays_out(1) <= '0';
				delays_out(2) <= '0';
			end if;
		end if;
	end process ; -- identifier

	TEMP_FUCK_OFF : process( divided_clk )
		variable oldvalue : std_logic;
	begin
		if(rising_edge(divided_clk)) then
			if (oldvalue /= right_button) and right_button = '1' then
				playerWin <= '1';
				oldvalue := right_button;
			else
				playerWin <= '0';
			end if;
		end if;
	end process ; -- TEMP_FUCK_OFF

	


	collision <= or_gate(collisions_out);
	win <= or_gate(wins_out);
	
	not_bt2 <= NOT bt2;
	btn_1 <= NOT bt2;
	left_btn <= shoot_signal;

	health <= health - 1 when ai_respawn = '1' and rising_edge(divided_clk);

	
	-- FLASH
	flash_address <= "0" & s_flash_address(21 downto 1);
	flash_data_15 <= s_flash_address(0);
	flash_chip_enable <= '0';
	flash_output_enable <= '0';
	flash_write_enable <= '1';
	flash_reset <= '1';
	flash_write_protect <= '0';
	flash_byte_word_mode <= '0'; -- byte mode
	
end architecture arch;
