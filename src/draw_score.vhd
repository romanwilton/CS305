LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.util.all;

entity draw_score is
	generic (
		SCORE_N, STREAK_N, TIMER_N : integer := 2
	);
	port(
		clk : in std_logic;
		score : in N_digit_num(SCORE_N-1 downto 0);
		streak : in N_digit_num(STREAK_N-1 downto 0);
		timer : in N_digit_num(TIMER_N-1 downto 0);
		health : in integer range 0 to 3;
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		colour_out : out std_logic_vector(15 downto 0)
	);
end entity draw_score;

architecture arch of draw_score is

	constant N_LINES : natural := 5;
	
	signal character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
	signal row, col : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal rom_out : std_logic;
	signal healthStr : char_array(2 downto 0);
	signal countdownStr : char_array(0 downto 0);
	
	signal all_signals, next_pixel_signals : char_signals_array(N_LINES-1 downto 0);

begin

	CHARACTER_ROM: entity work.char_rom port map (character_address, row, col, clk, rom_out);
	
	LINE1 : entity work.draw_string 
	generic map (
		N => 9+score'length, x => 530, y => 10
	)
	port map (
		clk => clk,
		str => string2char_array(" SCORE = ") & num2char_array(score),
		pixel_row => pixel_row, pixel_col => pixel_col,
		signals => all_signals(0), next_signals => next_pixel_signals(0)
	);
	
	LINE2 : entity work.draw_string 
	generic map (
		N => 9+streak'length, x => 530, y => 20
	)
	port map (
		clk => clk,
		str => string2char_array("STREAK = ") & num2char_array(streak),
		pixel_row => pixel_row, pixel_col => pixel_col,
		signals => all_signals(1), next_signals => next_pixel_signals(1)
	);

	healthString : process( health )
	begin
		
		MakeHeartString : for i in 1 to 3 loop
			if (i <= health) then
				healthStr(3-i) <= O"73";
			else
				healthStr(3-i) <= string2char_array(" ")(0);
			end if;
		end loop ; -- MakeHeartString
	end process ; -- healthString

	LINE3 : entity work.draw_string 
	generic map (
		N => 9+3, x => 530, y => 30
	)
	port map (
		clk => clk,
		str => string2char_array("HEALTH = ") & healthStr,
		pixel_row => pixel_row, pixel_col => pixel_col,
		signals => all_signals(2), next_signals => next_pixel_signals(2)
	);
	
	LINE4 : entity work.draw_string 
	generic map (
		N => 18+timer'length, x => 640/2-(18+timer'length)*8/2, y => 10
	)
	port map (
		clk => clk,
		str => num2char_array(timer) & string2char_array(" SECONDS REMAINING"),
		pixel_row => pixel_row, pixel_col => pixel_col,
		signals => all_signals(3), next_signals => next_pixel_signals(3)
	);
	
	countdownStr(0) <= O"62";
	
	LINE5 : entity work.draw_string 
	generic map (
		N => 1, x => 320, y => 240, scale_factor => 2
	)
	port map (
		clk => clk,
		str => countdownStr,
		pixel_row => pixel_row, pixel_col => pixel_col,
		signals => all_signals(4), next_signals => next_pixel_signals(4)
	);
	
	next_pixel : process (next_pixel_signals) is
	begin	
		character_address <= "000000";
		row <= "000";
		for i in N_LINES-1 downto 0 loop
			if next_pixel_signals(i).enable = '1' then
				character_address <= next_pixel_signals(i).character_address;
				row <= next_pixel_signals(i).font_row;
			end if;
		end loop;
	end process next_pixel;
	
	column : process (all_signals) is
	begin
		col <= "000";
		for i in N_LINES-1 downto 0 loop
			if all_signals(i).enable = '1' then
				col <= all_signals(i).font_col;
			end if;
		end loop;
	end process column;
	
	colour_out <= "1000000000011111" when rom_out = '1' else X"0000";
	
end architecture arch;
