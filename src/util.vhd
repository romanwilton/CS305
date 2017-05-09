LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

package util is
	type pixel is array (integer range <>) of std_logic_vector(15 downto 0);
	
	type char_array is array (integer range <>) of std_logic_vector(5 downto 0);
	
	type char_signals is record
		enable : std_logic;
		character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col : STD_LOGIC_VECTOR (2 DOWNTO 0);
	end record char_signals;
	type char_signals_array is array (integer range <>) of char_signals;
	constant char_signals_zero : char_signals := ('0', (others => '0'), (others => '0'), (others => '0'));
	
	type N_digit_num is array (natural range <>) of std_logic_vector(3 downto 0);
	
	function string2char_array(str : string) return char_array;
	function num2char_array(num : N_digit_num) return char_array;
	
end util;

package body util is

	function string2char_array(str : string) return char_array is
		variable output : char_array(str'length-1 downto 0);
		variable temp : std_logic_vector(9 downto 0);
	begin
		for i in 1 to str'length loop
			case str(i) is
				when '=' => 
					output(str'length-i) := O"72";
				when ' ' => 
					output(str'length-i) := O"40";
				when others =>
					temp := std_logic_vector(to_unsigned(character'pos(str(i)), 10) - to_unsigned(64, 10));
					output(str'length-i) := temp(5 downto 0);
			end case;
		end loop;
		return output;
	end string2char_array;
	
	function num2char_array(num : N_digit_num) return char_array is
		variable output : char_array(num'length-1 downto 0);
	begin
		for i in num'length-1 downto 0 loop
			output(i) := O"60" + num(i);
		end loop;
		return output;
	end num2char_array;

end package body util;
