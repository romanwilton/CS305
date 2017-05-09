LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity background is
	port (
		clock : IN std_logic;
		pixel_row, pixel_col : IN std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity background;

architecture arch of background is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0);
	signal row, col: integer;
begin
	output_drawing : entity work.draw_object generic map ("images/grass.mif", 90, 90) port map(clock, pixel_row, pixel_col, x, y, RGB_out);

	col <=
		0 when pixel_row >= 0 AND pixel_row < 90 else
		1 when pixel_row >= 90 AND pixel_row < 180 else
		2 when pixel_row >= 180 AND pixel_row < 270 else
		3 when pixel_row >= 270 AND pixel_row < 360 else
		4 when pixel_row >= 360 AND pixel_row < 450 else
		5 when pixel_row >= 450 AND pixel_row < 540 else
		6 when pixel_row >= 540 AND pixel_row < 630 else
		7 when pixel_row >= 630 AND pixel_row < 720;

	row <=
		0 when pixel_col >= 0 AND pixel_col < 90 else
		1 when pixel_col >= 90 AND pixel_col < 180 else
		2 when pixel_col >= 180 AND pixel_col < 270 else
		3 when pixel_col >= 270 AND pixel_col < 360 else
		4 when pixel_col >= 360 AND pixel_col < 450 else
		5 when pixel_col >= 450 AND pixel_col < 540 else
		6 when pixel_col >= 540 AND pixel_col < 630 else
		7 when pixel_col >= 630 AND pixel_col < 720;

	x <= std_logic_vector(to_unsigned((45 + 90 * row), 10));
	y <= std_logic_vector(to_unsigned((45 + 90 * col), 10));

end architecture arch;
