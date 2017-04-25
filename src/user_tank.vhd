LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity user_tank is
	port (
		clock : IN std_logic;
		pixel_row, pixel_col, mouse_col : IN std_logic_vector(9 downto 0);
		current_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity user_tank;

architecture arch of user_tank is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(420, 10));
	component draw_object is
		port (
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(2 downto 0)
		);
	end component draw_object;
begin
	output_drawing : draw_object port map(pixel_row, pixel_col, x, y, RGB_out);
	clockDriven : process( clock )
	begin
		if(rising_edge(clock)) then
			x <= mouse_col;
			current_pos <= x;
		end if;
	end process ; -- clockDriven
end architecture arch;
