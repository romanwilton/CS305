LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity draw_score is
	port(
		clk : in std_logic;
		digit1, digit2 : in std_logic_vector(3 downto 0);
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
	
	component draw_character is
		generic (
			x, y : in natural
		);
		port (
			digit : in std_logic_vector(3 downto 0);
			pixel_row, pixel_col : in std_logic_vector(9 downto 0);
			enable : out std_logic;
			character_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			font_row, font_col : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
		);
	end component draw_character;
	
	signal character_address, ca1, ca2 : STD_LOGIC_VECTOR (5 DOWNTO 0);
	signal row, col, row1, col1, row2, col2: STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal rom_out, en1, en2 : std_logic;

begin

	CHARACTER_ROM: char_rom port map (character_address, row, col, clk, rom_out);
	
	DIGIT1_DRAW : draw_character generic map (592, 10) 
		port map (digit1, pixel_row, pixel_col, en1, ca1, row1, col1);
	DIGIT2_DRAW : draw_character generic map (582, 10) 
		port map (digit2, pixel_row, pixel_col, en2, ca2, row2, col2);
	
	process (en1, en2, ca1, ca2, row1, row2, col1, col2) is
	begin
	
		character_address <= "000000";
		row <= "000";
		col <= "000";
	
		if en1 = '1' then
			character_address <= ca1;
			row <= row1;
			col <= col1;
		end if;
		
		if en2 = '1' then
			character_address <= ca2;
			row <= row2;
			col <= col2;
		end if;
	
	end process;
	
	process (rom_out, en1, en2) is
	begin
		colour_out <= X"0000";
		if (en1 = '1' or en2 = '1') then
			if (rom_out = '1') then
				colour_out <= "1000000000011111";
			end if;
		end if;
	end process;
	
end architecture arch;
