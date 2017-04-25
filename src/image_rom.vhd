LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY image_rom IS
	PORT (
		pixel_x, pixel_y, show_x, show_y	:	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock								: 	IN STD_LOGIC;
		RGB									:	OUT STD_LOGIC_VECTOR(11 downto 0)
	);
END image_rom;

ARCHITECTURE SYN OF image_rom IS

	SIGNAL rom_data		: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL rom_address	: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL rom_out 		: std_logic_vector(15 downto 0);

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
		q_a			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "sprite.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 576,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 16,
		width_a => 16,
		width_byteena_a => 2
	)
	PORT MAP (
		clock0 => clock,
		address_a => rom_address,
		q_a => rom_data
	);
	
	process (pixel_x, pixel_y, show_x, show_y) is
		variable x, y : unsigned(9 downto 0);
	begin
		x := unsigned(pixel_x) + 12 - unsigned(show_x);
		y := unsigned(pixel_y) + 12 - unsigned(show_y);
		rom_address <= "0" & std_logic_vector((x + y*to_unsigned(24, 5)));
	end process;
	
	rom_out <= rom_data;
	RGB <= rom_out(14 downto 11) & rom_out(9 downto 6) & rom_out(4 downto 1);

END SYN;
