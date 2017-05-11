LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity audio is
	generic (
		sound_path : string;
		sound_length : integer
	);
	port (
  		clock : IN std_logic;
  		PWM : OUT std_logic
	);
end entity ; -- audio

architecture arch of audio is
	SIGNAL rom_data		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL duty			: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL rom_address	: STD_LOGIC_VECTOR (15 DOWNTO 0) := X"0000";


	COMPONENT altsyncram
	GENERIC (
		address_aclr_a			: STRING;
		clock_enable_input_a	: STRING;
		clock_enable_output_a	: STRING;
		init_file				: STRING;
		intended_device_family	: STRING;
		lpm_hint				: STRING;
		lpm_type				: STRING;
		numwords_a				: NATURAL;
		operation_mode			: STRING;
		outdata_aclr_a			: STRING;
		outdata_reg_a			: STRING;
		widthad_a				: NATURAL;
		width_a					: NATURAL;
		width_byteena_a			: NATURAL
	);
	PORT (
		clock0		: IN STD_LOGIC ;
		address_a	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		q_a			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END COMPONENT;

begin
	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => sound_path,
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => sound_length,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 16,
		width_a => 8,
		width_byteena_a => 2
	)
	PORT MAP (
		clock0 => clock,
		address_a => rom_address,
		q_a => rom_data
	);

	duty <= rom_data & "00";


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
				rom_address <= rom_address + 1;
			end if;
		end if;
	end process ; -- PlaybackHandling
end architecture ; -- arch