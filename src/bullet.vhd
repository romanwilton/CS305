LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity bullet is
	port (
		clock, move, enable_move : IN std_logic;
		pixel_row, pixel_col, new_pos : IN std_logic_vector(9 downto 0);
		off_screen : OUT std_logic;
		current_x_pos, current_y_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity bullet;

architecture arch of bullet is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0);
	constant default_y : integer := 427;
begin
	output_drawing : entity work.draw_object generic map ("images/bullet.mif", 6, 8) port map(clock, pixel_row, pixel_col, x, y, RGB_out);

	position_logic : process (clock) is
	begin
		if (rising_edge(clock)) then
			if (move = '1') then
				if enable_move = '1' then
					y <= y - 16;
				end if;
			else
				x <= new_pos - 1;
				y <= std_logic_vector(to_unsigned(default_y, 10));
			end if;

			if (y > 480) then
				off_screen <= '1';
			else
				off_screen <= '0';
			end if;
		end if;
	end process ; -- position_logic
	
	current_x_pos <= x;
	current_y_pos <= y;
end architecture arch;
