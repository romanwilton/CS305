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
		pixel_row, pixel_col, h_count : in std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(15 downto 0);
		PWM : OUT std_logic
	);
end entity;

architecture arch of background_buffer is
	constant sound_length : integer := 320000;
	constant sound_start : integer := 320*240;
	
	signal buff : pixel(639 downto 0);
	SIGNAL duty : STD_LOGIC_VECTOR (9 DOWNTO 0);
begin

	process (clk) is
		variable count : integer range 0 to 420 := 0;
		variable wait_cnt : integer range -1 to 3 := 0;
		variable p_row_plus_1 : std_logic_vector(9 downto 0);
		variable sound_address : std_logic_vector(21 downto 0);
	begin
		if (rising_edge(clk)) then
		
			if (h_count = 0) then
				count := 0;
				wait_cnt := 0;
				p_row_plus_1 := pixel_row + 1;
			else

				if (h_count(9 downto 1) <= duty) then
					PWM <= '1';
				else
					PWM <= '0';
				end if;
			
				-- Triggered every second clock cycle (every 80us)
				if (wait_cnt = 1) then
				
					if (count > 2 and count < 330) then
						flash_address <= ("0000000000000" & p_row_plus_1(9 downto 1)) + (count - 3)*240;
					end if;

					if (count > 3 and count < 330) then
						buff(count - 4) <= flash_data(7 downto 0) & flash_data(15 downto 8);
					end if;
					
					if (count = 0) then
						if sound_address + 1 = sound_length then
							sound_address := (others => '0');
						else
							sound_address := sound_address + 1;
						end if;	
						flash_address <= sound_address + CONV_STD_LOGIC_VECTOR(sound_start, 22);
					end if;
					
					if (count = 2) then
						duty <= "00" & flash_data(15 downto 8);
					end if;

					count := count + 1;
					wait_cnt := -1;
				
				end if;
				wait_cnt := wait_cnt + 1;
			
			end if;
			
		end if;
	end process;
	
	RGB_out <= buff(CONV_INTEGER(pixel_col(9 downto 1)));

end architecture;
