LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity counter is
	port (
		count : IN std_logic;
		Q	: OUT std_logic_vector(3 downto 0)
	);
end entity counter;

architecture arch of counter is
	signal internal_counter : std_logic_vector(3 downto 0) := "0000";
begin
	countLogic : process( count )
	begin
		if(rising_edge(count)) then
			internal_counter <= internal_counter + 1;
		end if;
	end process ; -- countLogic
	Q <= internal_counter;
end architecture arch;
