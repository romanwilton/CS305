LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity streakCounter is
	port (
		clock, ai_reset, offscreen : IN std_logic;
		streak : OUT std_logic_vector(3 downto 0)
	);
end entity streakCounter;

architecture arch of streakCounter is
	signal internalCount : std_logic_vector(3 downto 0) := "0000";
begin

	counter : process( clock )
	begin
		if(rising_edge(clock)) then
			if(ai_reset = '1') then
				internalCount <= internalCount + 1;
			elsif (offscreen = '1') then
				internalCount <= "0000";
			end if;
		end if;
	end process ; -- counter
	streak <= internalCount;
end architecture arch;