LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.util.all;

entity draw_score is
	port(
		clk : in std_logic;
		score, streak : in two_digit_num;
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		colour_out : out std_logic_vector(15 downto 0)
	);
end entity draw_score;

architecture arch of draw_score is
	
	component char_rom is
		port (
			character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			clock				: 	IN STD_LOGIC ;
			rom_mux_output		:	OUT STD_LOGIC
		);
	end component char_rom;
	
	component draw_string is
		generic (
			N, x, y : in natural
		);
		port (
			clk : in std_logic;
			str : in char_array(N-1 downto 0);
			pixel_row, pixel_col : in std_logic_vector(9 downto 0);
			enable : out std_logic;
			character_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			font_row, font_col : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
		);
	end component draw_string;
	
	signal character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
	signal row, col : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal rom_out : std_logic;
	
	signal all_signals, next_pixel_signals : signals_array(1 downto 0);
	signal pixel_row_next, pixel_col_next : std_logic_vector(9 downto 0);

begin

	next_pixel_calc : process (pixel_row, pixel_col) is
	begin
		if (pixel_row = "0111100000") then --480
			pixel_col_next <= "0000000000";
			pixel_row_next <= "0000000000";
		elsif (pixel_col = "1001111111") then --639
			pixel_col_next <= "0000000000";
			pixel_row_next <= pixel_row + 1;
		else
			pixel_col_next <= pixel_col + 1;
			pixel_row_next <= pixel_row;
		end if;
	end process next_pixel_calc;

	CHARACTER_ROM: char_rom port map (character_address, row, col, clk, rom_out);
	
	LINE1 : draw_string 
	generic map (
		N => 11, x => 530, y => 10
	)
	port map (
		clk => clk,
		str => string2char_array(" SCORE = ") & char_array'(O"60" + score(1), O"60" + score(0)),
		pixel_row => pixel_row, pixel_col => pixel_col,
		enable => all_signals(0).enable,
		character_address => all_signals(0).character_address,
		font_row => all_signals(0).font_row,
		font_col => all_signals(0).font_col
	);
	
	LINE2 : draw_string 
	generic map (
		N => 11, x => 530, y => 20
	)
	port map (
		clk => clk,
		str => string2char_array("STREAK = ") & char_array'(O"60" + streak(1), O"60" + streak(0)),
		pixel_row => pixel_row, pixel_col => pixel_col,
		enable => all_signals(1).enable,
		character_address => all_signals(1).character_address,
		font_row => all_signals(1).font_row,
		font_col => all_signals(1).font_col
	);
	
	LINE1_NEXT : draw_string 
	generic map (
		N => 11, x => 530, y => 10
	)
	port map (
		clk => clk,
		str => string2char_array(" SCORE = ") & char_array'(O"60" + score(1), O"60" + score(0)),
		pixel_row => pixel_row_next, pixel_col => pixel_col_next,
		enable => next_pixel_signals(0).enable,
		character_address => next_pixel_signals(0).character_address,
		font_row => next_pixel_signals(0).font_row,
		font_col => next_pixel_signals(0).font_col
	);
	
	LINE2_NEXT : draw_string 
	generic map (
		N => 11, x => 530, y => 20
	)
	port map (
		clk => clk,
		str => string2char_array("STREAK = ") & char_array'(O"60" + streak(1), O"60" + streak(0)),
		pixel_row => pixel_row_next, pixel_col => pixel_col_next,
		enable => next_pixel_signals(1).enable,
		character_address => next_pixel_signals(1).character_address,
		font_row => next_pixel_signals(1).font_row,
		font_col => next_pixel_signals(1).font_col
	);
	
	next_pixel : process (next_pixel_signals) is
	begin	
		character_address <= "000000";
		row <= "000";
		col <= "000";
		for i in 1 downto 0 loop
			if next_pixel_signals(i).enable = '1' then
				character_address <= next_pixel_signals(i).character_address;
				row <= next_pixel_signals(i).font_row;
				col <= next_pixel_signals(i).font_col;
			end if;
		end loop;
	end process next_pixel;
	
	output : process (rom_out, all_signals) is
	begin
		colour_out <= X"0000";		
		for i in 1 downto 0 loop
			if all_signals(i).enable = '1' then
				if (rom_out = '1') then
					colour_out <= "1000000000011111";
				end if;
			end if;
		end loop;
	end process output;
	
end architecture arch;
