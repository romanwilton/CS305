LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.util.all;

entity counter is
	generic (
		N : integer;
		COUNT_DOWN : boolean;
		RESET_VAL : N_digit_num
	);
	port (
		clock, count, reset : IN std_logic;
		Q : OUT N_digit_num(N-1 downto 0)
	);
end entity counter;

architecture arch of counter is
begin

	counter : process( clock )
		variable v_Q : N_digit_num(N-1 downto 0) := RESET_VAL;
	begin
		if (rising_edge(clock)) then
			if (count = '1') then
				if COUNT_DOWN then
					v_Q(0) := v_Q(0) - 1;
				else
					v_Q(0) := v_Q(0) + 1;
				end if;
				
				for i in 0 to N-2 loop
					if (v_Q(i) >= "1010") then
						if COUNT_DOWN then
							v_Q(i+1) := v_Q(i+1) - 1;
							v_Q(i) := CONV_STD_LOGIC_VECTOR(9, 4);
						else
							v_Q(i+1) := v_Q(i+1) + 1;
							v_Q(i) := "0000";
						end if;
					end if;
				end loop;
			elsif (reset = '1') then
				v_Q := RESET_VAL;
			end if;
		end if;
		Q <= v_Q;
	end process counter;

end architecture arch;
