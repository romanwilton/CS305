LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.util.all;

entity layer_control is
	generic (
		NUM_INPUTS : integer := 3
	);
	port (
		show_game_objects : std_logic;
		layers : IN pixel((NUM_INPUTS - 1) downto 0);
		RGB_out	: OUT std_logic_vector(11 downto 0)
	);
end entity layer_control;

architecture arch of layer_control is
begin
	process (layers) is
		variable mif_data : std_logic_vector(15 downto 0);
	begin
		RGB_out <= X"FA4";
		for i in NUM_INPUTS-1 downto 0 loop
			if layers(i)(15) = '1' and (i = NUM_INPUTS-1 or i = 4 or show_game_objects = '1') then
				mif_data := layers(i);
				RGB_out <= mif_data(14 downto 11) & mif_data(9 downto 6) & mif_data(4 downto 1);
			end if;
		end loop;
	end process;
end architecture arch;
