LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity debounce is
	port (
		clock, button : IN std_logic;
		Q : OUT std_logic
	);
end entity debounce;

architecture arch of debounce is
begin

	debouncingIsh : process( clock, button )
		variable lastState : std_logic;
	begin
		if(rising_edge(clock)) then
			if(lastState = '0' and button = '1') then
				Q <= '1';
			else
				Q <= '0';
			end if;
			lastState := button;
		end if;
	end process ; -- debouncingIsh

end architecture ; -- arch