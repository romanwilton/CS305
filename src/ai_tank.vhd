LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ai_tank is
	port (
		clock, reset : IN std_logic;
		pixel_row, pixel_col, new_pos, bullet_pos : IN std_logic_vector(9 downto 0);
		collision	: OUT std_logic;
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity ai_tank;
