LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity layer_control is
	port (
		layers : IN std_logic_vector(8 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity layer_control;

architecture arch of layer_control is
begin
	process (layers) is
	begin
		if (layers(8 downto 6) /= "000") then
			RGB_out <= layers(8 downto 6);
		elsif (layers(5 downto 3) /= "000") then
			RGB_out <= layers(5 downto 3);
		elsif (layers(2 downto 0) /= "000") then
			RGB_out <= layers(2 downto 0);
		else
			RGB_out <= "000";
		end if;
	end process;
end architecture arch;
