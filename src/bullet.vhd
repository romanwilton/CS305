LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity bullet is
	port (
		clock, move : IN std_logic;
		pixel_row, pixel_col, new_pos : IN std_logic_vector(9 downto 0);
		off_screen : OUT std_logic;
		current_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity bullet;
