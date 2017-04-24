LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity user_tank is
	port (
		clock : IN std_logic;
		pixel_row, pixel_col, mouse_col : IN std_logic_vector(9 downto 0);
		current_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity user_tank;
