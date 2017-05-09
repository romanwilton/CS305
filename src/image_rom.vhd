LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.std_logic_arith.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY image_rom IS
	generic (
		image_path : string;
		width, height : integer
	);
	PORT (
		pixel_x, pixel_y, show_x, show_y	:	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock								: 	IN STD_LOGIC;
		RGB									:	OUT STD_LOGIC_VECTOR(15 downto 0)
	);
END image_rom;

ARCHITECTURE SYN OF image_rom IS

	SIGNAL rom_data		: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL rom_address	: STD_LOGIC_VECTOR (15 DOWNTO 0);

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
		init_file => image_path,
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => width*height,
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
		variable x, y : std_logic_vector(9 downto 0);
		variable address_temp : std_logic_vector(15 downto 0);
	begin
		x := pixel_x + width/2 - show_x;
		y := pixel_y + height/2 - show_y;
		address_temp := y + x(7 downto 0)*CONV_STD_LOGIC_VECTOR(height, 8);
		if address_temp < width*height then
			rom_address <= address_temp;
		else
			rom_address <= X"0000";
		end if;
	end process;
	
	RGB <= rom_data;

END SYN;
