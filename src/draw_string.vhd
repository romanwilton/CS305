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
		signals, next_signals : out char_signals
	);
end entity draw_string;

architecture arch of draw_string is
	
	signal all_signals, all_next_signals : char_signals_array(N-1 downto 0);
	signal pixel_row_next, pixel_col_next : std_logic_vector(9 downto 0);

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
		
		CHARACTER_DRAW_NEXT : entity work.draw_character
		generic map (
			x => x + (N-1-i)*8, y => y
		)
		port map (
			char => str(i),
			pixel_row => pixel_row_next, pixel_col => pixel_col_next,
			signals => all_next_signals(i)
		);
	end generate GEN;
	
	next_pixel_calc : process (pixel_row, pixel_col) is
	begin
		if (pixel_row = "0111100000") then --480
			pixel_col_next <= "0000000000";
			pixel_row_next <= "0000000000";
		elsif (pixel_col = "1001111111") then --639
			pixel_col_next <= "0000000000";
			pixel_row_next <= pixel_row + 1;
		else
			pixel_col_next <= pixel_col + 1;
			pixel_row_next <= pixel_row;
		end if;
	end process next_pixel_calc;

	process (all_signals) is
	begin
		signals.enable <= '0';
		signals.character_address <= O"00";
		signals.font_row <= "000";
		signals.font_col <= "000";
		for i in (N-1) downto 0 loop
			if all_signals(i).enable = '1' then
				signals <= all_signals(i);				
			end if;
		end loop;
	end process;
	
	process (all_next_signals) is
	begin
		next_signals.enable <= '0';
		next_signals.character_address <= O"00";
		next_signals.font_row <= "000";
		next_signals.font_col <= "000";
		for i in (N-1) downto 0 loop
			if all_next_signals(i).enable = '1' then
				next_signals <= all_next_signals(i);				
			end if;
		end loop;
	end process;

end architecture arch;
