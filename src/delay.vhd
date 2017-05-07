LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity delay is
	port(
		clk, input : in std_logic;
		output : out std_logic
	);
end entity;

-- Delay of 4s with 25MHz
architecture arch of delay is
begin
	process (clk) is
		variable count : integer := 0;
		variable enable : std_logic := '0';
	begin
		if rising_edge(clk) then
		
			if input = '1' then
				enable := '1';
			end if;
			
			if enable = '1' then
				count := count + 1;
			end if;
			
			if count = 100000000 then
				output <= '1';
				count := 0;
				enable := '0';
			else
				output <= '0';
			end if;
			
		end if;
	end process;
end architecture;
