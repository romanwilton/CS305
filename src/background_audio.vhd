LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.util.all;

entity background_audio is
	port(
		clk : in std_logic;
		background : in integer range 0 to 5;
		play_hover, train_hover : IN std_logic;
		flash_address : out std_logic_vector(21 downto 0);
		flash_data : in std_logic_vector(15 downto 0);
		pixel_row, pixel_col, h_count : in std_logic_vector(9 downto 0);
		RGB_out	: out std_logic_vector(15 downto 0);
		PWM : out std_logic
	);
end entity;

architecture arch of background_audio is
	constant IM_SIZE : integer := 320*240;
	constant sound_length : integer := 1120000;
	constant sound_start : integer := IM_SIZE*6;
	
	signal buff : pixel(639 downto 0);
	signal duty : std_logic_vector(9 DOWNTO 0);
begin

	process (clk) is
		variable count : integer range 0 to 420 := 0;
		variable wait_cnt : integer range -1 to 1 := 0;
		variable next_row : std_logic_vector(9 downto 0);
		variable sound_address : std_logic_vector(21 downto 0);
		variable flash_address_temp : std_logic_vector(21 downto 0);
	begin
		if (rising_edge(clk)) then
		
			if (h_count = 0) then
				count := 0;
				wait_cnt := 0;
				
				if (pixel_row = 479) then
					next_row := (others => '0');
				else
					next_row := pixel_row + 1;
				end if;
			else

				if (h_count(9 downto 1) <= duty) then
					PWM <= '1';
				else
					PWM <= '0';
				end if;
			
				-- Triggered every second clock cycle (every 80ns)
				if (wait_cnt = 1) then
				
					if (count > 2 and count < 330) then
						flash_address_temp := ("0000000000000" & next_row(9 downto 1)) + (count - 3)*240;
						flash_address <= flash_address_temp + IM_SIZE*background;
					end if;

					if (count > 3 and count < 330) then
						buff(count - 5) <= flash_data(7 downto 0) & flash_data(15 downto 8);
					end if;
					
					if (count = 0) then
						if sound_address + 1 = sound_length then
							sound_address := (others => '0');
						else
							sound_address := sound_address + 1;
						end if;	
						flash_address <= sound_address(21 downto 1) + CONV_STD_LOGIC_VECTOR(sound_start, 22);
					end if;
					
					if (count = 2) then
						if (sound_address(0) = '1') then
							duty <= "00" & flash_data(15 downto 8);
						else
							duty <= "00" & flash_data(7 downto 0);
						end if;
					end if;

					count := count + 1;
					wait_cnt := -1;
				
				end if;
				wait_cnt := wait_cnt + 1;
			
			end if;
			
		end if;
	end process;

	MenuSelector : process( buff, pixel_col, pixel_row, play_hover, train_hover )
		variable current_RGB_out : std_logic_vector(15 downto 0);
	begin
		current_RGB_out := buff(CONV_INTEGER(pixel_col(9 downto 1)));

		if(play_hover = '1') then
			if(pixel_row <=260 and current_RGB_out = X"FFFF")then
				RGB_out <= "1101001010110101";
			else
				RGB_out <= current_RGB_out;
			end if;
		elsif(train_hover = '1') then
			if(pixel_row >=300 and current_RGB_out = X"FFFF")then
				RGB_out <= "1101001010110101";
			else
				RGB_out <= current_RGB_out;
			end if;
		else
			RGB_out <= current_RGB_out;
		end if;
	end process ; -- MenuSelector
end architecture;
