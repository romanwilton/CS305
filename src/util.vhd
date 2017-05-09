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
	
	type N_digit_num is array (natural range <>) of std_logic_vector(3 downto 0);
	
	function string2char_array(str : string) return char_array;
	function num2char_array(num : N_digit_num) return char_array;
	procedure reset_AI_tank (
		signal new_pos : in std_logic_vector(9 downto 0);
		constant intital_y : in std_logic_vector(9 downto 0);
		variable rand_in : inout unsigned(9 downto 0);
		variable intermediate : inout std_logic_vector(14 downto 0);
		variable x_var : inout std_logic_vector(9 downto 0);
		signal x, y : out std_logic_vector(9 downto 0);
		signal moveDir : out std_logic
	);
	
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

	procedure reset_AI_tank (
		signal new_pos : in std_logic_vector(9 downto 0);
		constant intital_y : in std_logic_vector(9 downto 0);
		variable rand_in : inout unsigned(9 downto 0);
		variable intermediate : inout std_logic_vector(14 downto 0);
		variable x_var : inout std_logic_vector(9 downto 0);
		signal x, y : out std_logic_vector(9 downto 0);
		signal moveDir : out std_logic
	) is
	begin
		-- Multiply by ~0.6 using (<<4 + <<1 + <<0)>>5
		rand_in := unsigned(new_pos);
		intermediate := std_logic_vector(("0"&rand_in&"0000") + ("0000"&rand_in&"0") + ("00000"&rand_in));
		x_var := intermediate(14 downto 5);
		x <= x_var;
		y <= intital_y;
		if x_var > 320 then
			moveDir <= '1';
		else
			moveDir <= '0';
		end if;
	end procedure;

end package body util;
