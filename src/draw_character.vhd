LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity draw_character is
	generic (
		x, y : in natural
	);
	port (
		char : in std_logic_vector(5 downto 0);
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		enable : out std_logic;
		character_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
end entity draw_character;

architecture arch of draw_character is
begin
	
	process (pixel_col, pixel_row, char) is
		variable col_v, row_v : STD_LOGIC_VECTOR(9 DOWNTO 0);
	begin
		
		enable <= '0';
		character_address <= "000000";
		font_row <= "000";
		font_col <= "000";
	
		if (pixel_col >= x and pixel_col < (x + 8)) then
			if (pixel_row >= y and pixel_row < (y + 8)) then
				character_address <= char;
				col_v := pixel_col - x;
				font_col <= col_v(2 downto 0);
				row_v := pixel_row - y;
				font_row <= row_v(2 downto 0);
				enable <= '1';
			end if;
		end if;
	
	end process;
	
end architecture arch;
