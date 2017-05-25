LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.util.all;

entity draw_character is
	generic (
		x, y : in natural;
		scale_factor : in natural
	);
	port (
		char : in std_logic_vector(5 downto 0);
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		signals : out char_signals
	);
end entity draw_character;

architecture arch of draw_character is
begin
	
	process (pixel_col, pixel_row, char) is
		variable col_v, row_v : STD_LOGIC_VECTOR(9 DOWNTO 0);
	begin
		signals <= char_signals_zero;
		if (pixel_col >= x and pixel_col < (x + 8*2**scale_factor)) then
			if (pixel_row >= y and pixel_row < (y + 8*2**scale_factor)) then
				signals.character_address <= char;
				col_v := pixel_col - x;
				signals.font_col <= col_v(2+scale_factor downto scale_factor);
				row_v := pixel_row - y;
				signals.font_row <= row_v(2+scale_factor downto scale_factor);
				signals.enable <= '1';
			end if;
		end if;
	
	end process;
	
end architecture arch;
