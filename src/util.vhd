LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package util is
	type pixel is array (integer range <>) of std_logic_vector(15 downto 0);
	type char_array is array (integer range <>) of std_logic_vector(5 downto 0);
	type signals is record
		enable : std_logic;
		character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col : STD_LOGIC_VECTOR (2 DOWNTO 0);
	end record signals;
	type signals_array is array (integer range <>) of signals;
end util;
