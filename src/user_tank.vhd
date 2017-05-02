LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity user_tank is
	port (
		clock, enable_move : IN std_logic;
		pixel_row, pixel_col, mouse_col : IN std_logic_vector(9 downto 0);
		current_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity user_tank;

architecture arch of user_tank is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0);
	component draw_object is
		generic (
			image_path : string;
			width, height : integer
		);
		port (
			clock : IN std_logic;
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(15 downto 0)
		);
	end component draw_object;
begin
	y <= std_logic_vector(to_unsigned(420, 10));
	output_drawing : draw_object generic map ("images/tank.mif", 50, 54) port map(clock, pixel_row, pixel_col, x, y, RGB_out);
	clockDriven : process(clock, enable_move) is
	begin
		if (rising_edge(clock) and enable_move = '1') then
			x <= mouse_col;
		end if;
	end process ; -- clockDriven
	current_pos <= x;
end architecture arch;
