LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.util.all;

entity draw_string is
	generic (
		N, x, y : in natural
	);
	port (
		clk : in std_logic;
		str : in char_array(N-1 downto 0);
		pixel_row, pixel_col : in std_logic_vector(9 downto 0);
		enable : out std_logic;
		character_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
end entity draw_string;

architecture arch of draw_string is
	
	signal all_signals : signals_array((N-1) downto 0);

begin

	GEN : for i in (N-1) downto 0 generate
		CHARACTER_DRAW : entity work.draw_character
		generic map (
			x => x + (N-1-i)*8, y => y
		)
		port map (
			char => str(i),
			pixel_row => pixel_row, pixel_col => pixel_col,
			enable => all_signals(i).enable,
			character_address => all_signals(i).character_address,
			font_row => all_signals(i).font_row, font_col => all_signals(i).font_col
		);
	end generate GEN;

	process (all_signals) is
	begin
		enable <= '0';
		character_address <= O"00";
		font_row <= "000";
		font_col <= "000";
		
		for i in (N-1) downto 0 loop
			if all_signals(i).enable = '1' then
				enable <= '1';
				character_address <= all_signals(i).character_address;
				font_row <= all_signals(i).font_row;
				font_col <= all_signals(i).font_col;				
			end if;
		end loop;
	end process;

end architecture arch;
