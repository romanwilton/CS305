LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package util is
	type pixel is array (integer range <>) of std_logic_vector(15 downto 0);
end util;
