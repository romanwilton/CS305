LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ai_tank is
	port (
		clock, reset : IN std_logic;
		pixel_row, pixel_col, new_pos, bullet_x_pos, bullet_y_pos : IN std_logic_vector(9 downto 0);
		collision	: OUT std_logic;
		RGB_out	: OUT std_logic_vector(2 downto 0)
	);
end entity ai_tank;

architecture arch of ai_tank is
	signal x : std_logic_vector(9 downto 0) := "0000000000";
	signal y : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(80, 10));
	signal newClk : std_logic := '0';
	signal moveDir : std_logic := '0';
	component draw_object is
		port (
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(2 downto 0)
		);
	end component draw_object;
begin
	output_drawing : draw_object port map(pixel_row, pixel_col, x, y, RGB_out);
	

	clockDiv : process( clock )
		variable counter : std_logic_vector(16 downto 0) := "00000000000000000";
	begin
		if(rising_edge(clock)) then
			if(counter = "11111111111111111") then
				newClk <= NOT newClk;
			end if;
			counter := counter +1;
		end if;
	end process ; -- clockDiv

	movement : process( newClk )
	begin
		if(rising_edge(newClk)) then
			if(x = std_logic_vector(to_unsigned(640, 10))) then
				moveDir <= '1';
			elsif(x = "0000000000") then
				moveDir <= '0';
			end if;
			if(moveDir = '0') then
				x <= x+1;
			else
				x <= x-1; 	
			end if; 
		end if;
	end process ; -- movement

	collisions : process( bullet_y_pos, bullet_x_pos )
	begin
		if(bullet_y_pos < std_logic_vector(to_unsigned(90, 10))) then
			if(bullet_x_pos < x+10 AND bullet_x_pos > x-10) then
				collision <= '1';
			else
				collision <= '0';
			end if;
		else
			collision <= '0';
		end if;
	end process ; -- collisions
end architecture arch;
