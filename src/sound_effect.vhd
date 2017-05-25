LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.math_real.all;

entity sound_effect is
	generic (
		sound_path : string;
		sound_length : integer
	);
	port (
  		clock, new_value, reset : in std_logic;
  		audio_out : out std_logic_vector(7 downto 0)
	);
end entity sound_effect;

architecture arch of sound_effect is

	constant ADDR_WIDTH : natural := integer(ceil(log2(real(sound_length))));

	SIGNAL rom_address	: STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0) := (others => '0');
	signal rom_out : std_logic_vector(7 downto 0);

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
		address_a	: IN STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
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
		widthad_a => ADDR_WIDTH,
		width_a => 8,
		width_byteena_a => 1
	)
	PORT MAP (
		clock0 => clock,
		address_a => rom_address,
		q_a => rom_out
	);

	audio_out <= rom_out when reset = '0' else X"7F";
	
	address : process (clock) is
	begin
		if (rising_edge(clock)) then
			if (new_value = '1') then
				if rom_address + 1 = sound_length or reset = '1' then
					rom_address <= (others => '0');
				else
					rom_address <= rom_address + 1;
				end if;
			end if;
		end if;
	end process address;
	
end architecture;
