LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.util.all;

entity counter is
	generic (
		N : integer := 2 
		);
	port (
		clock, count, reset : IN std_logic;
		Q : OUT N_digit_num(N-1 downto 0)
	);
end entity counter;

architecture arch of counter is
begin

	counter : process( clock )
		variable v_Q : N_digit_num(N-1 downto 0) := (others => "0000");
	begin
		if(rising_edge(clock)) then
			if(count = '1') then
				v_Q(0) := v_Q(0) + 1;
				upCounter : for i in 0 to N-2 loop
					if(v_Q(i) = "1001") then
						v_Q(i) := "0000";
						v_Q(i+1) := v_Q(i+1) + 1;
					end if;
				end loop ; -- upCounter
			elsif (reset = '1') then
				resetLoop : for i in 0 to N-1 loop
					v_Q(i) := "0000";
				end loop ; -- resetLoop
			end if;
		end if;
		Q <= v_Q;
	end process ; -- counter
end architecture arch;