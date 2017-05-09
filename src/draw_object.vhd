LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity draw_object is
	generic (
		image_path : string;
		width, height : integer
	);
	port (
		clock : IN std_logic;
		pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity draw_object;

architecture arch of draw_object is
	
	signal RGB : std_logic_vector(15 downto 0);
	signal pixel_x_in, pixel_y_in : STD_LOGIC_VECTOR (9 DOWNTO 0);

begin

	comp : entity work.image_rom
		GENERIC MAP (image_path, width, height)
		PORT MAP (pixel_x_in, pixel_y_in, x, y, clock, RGB);
		
	process (pixel_col, pixel_row) is
	begin
		if (pixel_row = "0111100000") then --480
			pixel_x_in <= "0000000000";
			pixel_y_in <= "0000000000";
		elsif (pixel_col = "1001111111") then --639
			pixel_x_in <= "0000000000";
			pixel_y_in <= pixel_row + 1;
		else
			pixel_x_in <= pixel_col + 1;
			pixel_y_in <= pixel_row;
		end if;
	end process;

	process (pixel_row, pixel_col, x, y, RGB) is
	begin
		RGB_out <= X"0000";
		if (x <= pixel_col + width/2) and (x + width/2 > pixel_col) then
			if (y <= pixel_row + height/2) and (y + height/2 > pixel_row) then
				RGB_out <= RGB;
			end if;
		end if;
	end process;
end architecture;
