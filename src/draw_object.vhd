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

	COMPONENT image_rom IS
		generic (
			image_path : string;
			width, height : integer
		);
		PORT (
			pixel_x, pixel_y, show_x, show_y	:	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			clock								: 	IN STD_LOGIC;
			RGB									:	OUT STD_LOGIC_VECTOR(15 downto 0)
		);
	END COMPONENT image_rom;
	
	signal RGB : std_logic_vector(15 downto 0);

begin

	comp : image_rom
		GENERIC MAP (image_path, width, height)
		PORT MAP (pixel_col, pixel_row, x, y, clock, RGB);

	process (pixel_row, pixel_col, x, y, RGB) is
	begin
		RGB_out <= X"0000";
		if (x < pixel_col + width/2) and (x + width/2 > pixel_col) then
			if (y < pixel_row + height/2) and (y + height/2 > pixel_row) then
				RGB_out <= RGB;
			end if;
		end if;
	end process;
end architecture;
