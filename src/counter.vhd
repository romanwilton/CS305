LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity counter is
	port (
		count : IN std_logic;
		Q_1, Q_2 : OUT std_logic_vector(3 downto 0)
	);
end entity counter;

architecture arch of counter is
	signal internal_counter_1 : std_logic_vector(3 downto 0) := "0000";
	signal internal_counter_2 : std_logic_vector(3 downto 0) := "0000";
begin
	countLogic : process( count )
	begin
		if(rising_edge(count)) then
			if(internal_counter_1 = "1001") then
				internal_counter_1 <= "0000";
				internal_counter_2 <= internal_counter_2 + 1;
				if(internal_counter_2 = "1001") then
					internal_counter_2 <= "0000";
				end if;
			else
				internal_counter_1 <= internal_counter_1 + 1;
			end if;
		end if;
	end process ; -- countLogic
	Q_1 <= internal_counter_1;
	Q_2 <= internal_counter_2;
end architecture arch;
