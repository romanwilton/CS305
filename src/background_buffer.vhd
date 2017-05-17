LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.util.all;

entity background_buffer is
	port(
		clk : in std_logic;
		flash_address : out std_logic_vector(21 downto 0);
		flash_data : in std_logic_vector(15 downto 0);
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity;

architecture arch of background_buffer is
	signal buff : pixel(639 downto 0);
begin

	process (clk) is
		variable count : integer range 0 to 640 := 0;
		variable wait_cnt : integer range -1 to 3 := 0;
		variable p_row_plus_1 : std_logic_vector(9 downto 0);
	begin
		if (rising_edge(clk)) then
			if (pixel_col = 639) then
				count := 0;
				wait_cnt := 0;
				p_row_plus_1 := pixel_row + 1;
			end if;
			if (count < 320) then
				if (wait_cnt = 1) then
					buff(count) <= flash_data(7 downto 0) & flash_data(15 downto 8);
					flash_address <= ("0000000000000" & p_row_plus_1(9 downto 1)) + count*240;
					count := count + 1;
					wait_cnt := -1;
				end if;
				wait_cnt := wait_cnt + 1;
			end if;
		end if;
	end process;
	
	RGB_out <= buff(CONV_INTEGER(pixel_col(9 downto 1) + pixel_col(0)));

end architecture;
