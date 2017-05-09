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
		signals : out char_signals
	);
end entity draw_string;

architecture arch of draw_string is
	
	signal all_signals : char_signals_array(N-1 downto 0);

begin

	GEN : for i in (N-1) downto 0 generate
		CHARACTER_DRAW : entity work.draw_character
		generic map (
			x => x + (N-1-i)*8, y => y
		)
		port map (
			char => str(i),
			pixel_row => pixel_row, pixel_col => pixel_col,
			signals => all_signals(i)
		);
	end generate GEN;

	process (all_signals) is
	begin
		signals.enable <= '0';
		signals.character_address <= O"00";
		signals.font_row <= "000";
		signals.font_col <= "000";
		
		for i in (N-1) downto 0 loop
			if all_signals(i).enable = '1' then
				signals.enable <= '1';
				signals.character_address <= all_signals(i).character_address;
				signals.font_row <= all_signals(i).font_row;
				signals.font_col <= all_signals(i).font_col;				
			end if;
		end loop;
	end process;

end architecture arch;
