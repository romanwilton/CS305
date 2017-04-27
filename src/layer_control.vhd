LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity layer_control is
	generic (
		NUM_INPUTS : integer := 3
	);
	port (
		layers : IN std_logic_vector((12*NUM_INPUTS -1) downto 0);
		RGB_out	: OUT std_logic_vector(11 downto 0)
	);
end entity layer_control;

architecture arch of layer_control is
begin
	process (layers) is
	begin
		RGB_out <= X"FA4";
		for i in NUM_INPUTS downto 1 loop
			if layers((12*i -1) downto 12*(i-1)) /= "000000000000" then
				RGB_out <= layers((12*i -1) downto 12*(i-1));
			end if;
		end loop;
	end process;
end architecture arch;
