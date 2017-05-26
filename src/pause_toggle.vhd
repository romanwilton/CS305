library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity pause_toggle is
  port (
	clock, toggle, reset : in std_logic;
	Q : out std_logic
  ) ;
end entity ; -- pause_toggle

architecture arch of pause_toggle is
	signal internal_Q : std_logic := '0';
begin
	InputRisingEdgeDetector : process( clock )
		variable oldvalue : std_logic;
	begin
		if (rising_edge(clock)) then
			if (oldvalue /= toggle and toggle = '1') then
				internal_Q <= NOT internal_Q;
			end if;
			oldvalue := toggle;
			if (reset = '1') then
				internal_Q <= '0';
			end if;
		end if;

		Q <= internal_Q;
	end process ; -- InputRisingEdgeDetector

end architecture ; -- arch