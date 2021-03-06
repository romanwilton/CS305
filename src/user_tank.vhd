LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

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
begin
	y <= CONV_STD_LOGIC_VECTOR(420, 10);
	output_drawing : entity work.draw_object generic map ("images/tank.mif", 50, 54) 
		port map(clock, pixel_row, pixel_col, x, y, RGB_out);
	clockDriven : process(clock, enable_move) is
	begin
		if (rising_edge(clock) and enable_move = '1') then
			x <= mouse_col;
		end if;
	end process ; -- clockDriven
	current_pos <= x;
end architecture arch;
