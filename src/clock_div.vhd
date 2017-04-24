library ieee;
use ieee.std_logic_1164.all;

entity clock_div is
	port(
		clock : in std_logic;
		q : out std_logic
	);
end entity clock_div;

architecture arch of clock_div is
	signal q_s : std_logic := '0';
begin
	process (clock) is
	begin
		if rising_edge(clock) then
			q_s <= not q_s;
		end if;
	end process;
	q <= q_s;
end architecture;
