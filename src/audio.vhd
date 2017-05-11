LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.math_real.all;

entity audio is
	generic (
		sound_path : string;
		sound_length : integer
	);
	port (
		clock : IN std_logic;
		data : IN std_logic_vector(7 downto 0);
		PWM : OUT std_logic;
		address : OUT std_logic_vector(21 downto 0)
	);
end entity ; -- audio

architecture arch of audio is

	SIGNAL duty			: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL rom_address	: STD_LOGIC_VECTOR (21 downto 0) := (others => '0');

begin

	PlaybackHandling : process( clock )
		variable count : integer range 0 to 520;
	begin
		if(rising_edge(clock)) then
			count := count + 1;
			if(count <= duty) then
				PWM <= '1';
			else
				PWM <= '0';
			end if;

			if(count = 520) then
				duty <= data & "00";
				if rom_address + 1 = sound_length then
					rom_address <= (others => '0');
				else
					rom_address <= rom_address + 1;
				end if;
				count := 0;
			end if;
		end if;
	end process ; -- PlaybackHandling
	
	address <= rom_address;
	
end architecture ; -- arch
