LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity draw_score is
	port(
		clk : in std_logic;
		digit1, digit2 : in std_logic_vector(3 downto 0);
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		colour_out : out std_logic_vector(15 downto 0)
	);
end entity draw_score;

architecture arch of draw_score is
	
	component char_rom is
		port (
			character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			clock				: 	IN STD_LOGIC ;
			rom_mux_output		:	OUT STD_LOGIC
		);
	end component char_rom;
	
	signal character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
	signal row, col : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal rom_out : std_logic;

begin

	D: char_rom port map (character_address, row, col, clk, rom_out);
	
	process (pixel_col, pixel_row, digit1, rom_out) is
		variable col_v, row_v : STD_LOGIC_VECTOR(9 DOWNTO 0);
	begin
		
		colour_out <= X"0000";
	
		if (pixel_col >= 572 and pixel_col < 580) then
			if (pixel_row >= 10 and pixel_row < 18) then
				character_address <= O"60" + digit1;
				col_v := pixel_col - 572;
				col <= col_v(2 downto 0);
				row_v := pixel_row - 10;
				row <= row_v(2 downto 0);
				if (rom_out = '1') then
					colour_out <= "1000000000011111";
				end if;
			end if;
		end if;
	
	end process;
	
end architecture arch;
