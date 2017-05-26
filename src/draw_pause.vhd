LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.util.all;

entity draw_pause is
	port(
		clk, enabled : in std_logic;
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		colour_out : out std_logic_vector(15 downto 0)
	);
end entity draw_pause;

architecture arch of draw_pause is

	constant N_LINES : natural := 1;
	
	signal rom_out : std_logic;
	signal character_address : STD_LOGIC_VECTOR (5 DOWNTO 0);
	signal row, col : STD_LOGIC_VECTOR (2 DOWNTO 0);	
	signal all_signals, next_pixel_signals : char_signals_array(N_LINES-1 downto 0);

begin

	CHARACTER_ROM: entity work.char_rom port map (character_address, row, col, clk, rom_out);
	
	LINE1 : entity work.draw_string 
	generic map (
		N => 6, x => 640/2-3*8*2**2, y => 480/2-4*2**2, scale_factor => 2
	)
	port map (
		clk => clk,
		str => string2char_array("PAUSED"),
		pixel_row => pixel_row, pixel_col => pixel_col,
		signals => all_signals(0), next_signals => next_pixel_signals(0)
	);
	
	next_pixel : process (next_pixel_signals) is
	begin	
		character_address <= "000000";
		row <= "000";
		for i in N_LINES-1 downto 0 loop
			if next_pixel_signals(i).enable = '1' then
				character_address <= next_pixel_signals(i).character_address;
				row <= next_pixel_signals(i).font_row;
			end if;
		end loop;
	end process next_pixel;
	
	column : process (all_signals) is
	begin
		col <= "000";
		for i in N_LINES-1 downto 0 loop
			if all_signals(i).enable = '1' then
				col <= all_signals(i).font_col;
			end if;
		end loop;
	end process column;
	
	colour_out <= X"FFFF" when rom_out = '1' and enabled = '1' else X"0000";
	
end architecture arch;
