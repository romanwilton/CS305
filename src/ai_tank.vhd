LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ai_tank is
	port (
		clock, reset : IN std_logic;
		pixel_row, pixel_col, new_pos, bullet_pos : IN std_logic_vector(9 downto 0);
		collision	: OUT std_logic;
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity ai_tank;

architecture arch of ai_tank is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(80, 10));
	component draw_object is
		port (
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(2 downto 0)
		);
	end component draw_object;
begin
	output_drawing : draw_object port map(pixel_row, pixel_col, x, y, RGB_out);
	collision <= '0';
	clockDriven : process( clock )
	begin
		if(rising_edge(clock)) then
			if(x < std_logic_vector(to_unsigned(640, 10))) then
				x <= x+1;
			end if;
		end if;
	end process ; -- clockDriven
end architecture arch;
