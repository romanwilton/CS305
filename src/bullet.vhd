LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity bullet is
	port (
		clock, move : IN std_logic;
		pixel_row, pixel_col, new_pos : IN std_logic_vector(9 downto 0);
		off_screen : OUT std_logic;
		current_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity bullet;

architecture arch of bullet is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(400, 10));
	signal newClk : std_logic := '0';
	component draw_object is
		port (
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(2 downto 0)
		);
	end component draw_object;
begin
	output_drawing : draw_object port map(pixel_row, pixel_col, x, y, RGB_out);

	clockDiv : process( clock )
		variable counter : std_logic_vector(14 downto 0) := "000000000000000";
	begin
		if(rising_edge(clock)) then
			if(counter = "111111111111111") then
				newClk <= NOT newClk;
			end if;
			counter := counter +1;
		end if;
	end process ; -- clockDiv


	clockDriven : process( newClk )
	begin
		if(rising_edge(newClk)) then
			if(move = '0') then
				x <= new_pos;
				y <= std_logic_vector(to_unsigned(400, 10));
			elsif(move = '1') then
				y <= y-1;
			end if;

			if (y = "0000000000") then
				off_screen <= '1';
			else
				off_screen <= '0';
			end if;
		end if;
	end process ; -- clockDriven

	current_pos <= "0000000000";
end architecture arch;
