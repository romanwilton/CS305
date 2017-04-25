LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity draw_object is
	port (
		pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity draw_object;

architecture arch of draw_object is
begin
	process (pixel_row, pixel_col, x, y) is
	begin
		RGB_out <= "000";
		if (x < pixel_col + 10) and (x > pixel_col - 10) then
			if (y < pixel_row + 10) and (y > pixel_row - 10) then
				RGB_out <= "100";
			end if;	
		end if;
	end process;
end architecture;
