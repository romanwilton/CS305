LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity streakCounter is
	port (
		clock, ai_reset, offscreen : IN std_logic;
		Q_1, Q_2 : OUT std_logic_vector(3 downto 0)
	);
end entity streakCounter;

architecture arch of streakCounter is
	signal internal_counter_1 : std_logic_vector(3 downto 0) := "0000";
	signal internal_counter_2 : std_logic_vector(3 downto 0) := "0000";
begin

	counter : process( clock )
	begin
		if(rising_edge(clock)) then
			if(ai_reset = '1') then
				if(internal_counter_1 = "1001") then
					internal_counter_1 <= "0000";
					internal_counter_2 <= internal_counter_2 + 1;
					if(internal_counter_2 = "1001") then
						internal_counter_2 <= "0000";
					end if;
				else
					internal_counter_1 <= internal_counter_1 + 1;
				end if;
			elsif (offscreen = '1') then
				internal_counter_1 <= "0000";
				internal_counter_2 <= "0000";
			end if;
		end if;
	end process ; -- counter
	Q_1 <= internal_counter_1;
	Q_2 <= internal_counter_2;
end architecture arch;