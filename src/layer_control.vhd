LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity layer_control is
	port (
		layers : IN std_logic_vector(8 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity layer_control;
