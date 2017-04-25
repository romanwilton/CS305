LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity bullet is
	port (
		clock, move : IN std_logic;
		pixel_row, pixel_col, new_pos : IN std_logic_vector(9 downto 0);
		off_screen : OUT std_logic;
		current_x_pos, current_y_pos : OUT std_logic_vector(9 downto 0);
		RGB_out	: OUT std_logic_vector(11 downto 0)
	);
end entity bullet;

architecture arch of bullet is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(400, 10));
	signal newClk : std_logic := '0';
	component draw_object is
		port (
			clock : IN std_logic;
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(11 downto 0)
		);
	end component draw_object;
begin
	output_drawing : draw_object port map(clock, pixel_row, pixel_col, x, y, RGB_out);

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


	position_logic : process (newClk, move, new_pos)
	begin
		if(rising_edge(newClk)) then
			if(move = '1') then
				y <= y-1;
			end if;

			if (y = "0000000000") then
				off_screen <= '1';
			else
				off_screen <= '0';
			end if;
		end if;

		if(move = '0') then
			x <= new_pos;
			y <= std_logic_vector(to_unsigned(400, 10));
		end if;

	end process ; -- position_logic
	
	current_x_pos <= x;
	current_y_pos <= y;
end architecture arch;
