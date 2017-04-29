LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ai_tank is
	port (
		clock, reset, hold : IN std_logic;
		pixel_row, pixel_col, new_pos, bullet_x_pos, bullet_y_pos : IN std_logic_vector(9 downto 0);
		collision	: OUT std_logic;
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity ai_tank;

architecture arch of ai_tank is
	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(80, 10));
	signal moveDir : std_logic := '0';
	component draw_object is
		generic (
			image_path : string;
			width, height : integer
		);
		port (
			clock : IN std_logic;
			pixel_row, pixel_col, x, y : IN std_logic_vector(9 downto 0);
			RGB_out	: OUT std_logic_vector(15 downto 0)
		);
	end component draw_object;
begin
	output_drawing : draw_object generic map ("images/tank2.mif", 80, 24) port map(clock, pixel_row, pixel_col, x, y, RGB_out);

	movement : process( clock )
		variable counter : std_logic_vector(17 downto 0) := "000000000000000000";
	begin
		if(rising_edge(clock)) then
			if(reset = '1') then
				x <= new_pos;
			end if;

			counter := counter +1;

			if(counter = "111111111111111111" AND hold = '0') then
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
		end if;
	end process ; -- movement

	collisions : process (bullet_y_pos, bullet_x_pos, x) is
	begin
		if(bullet_y_pos < std_logic_vector(to_unsigned(90, 10)) AND bullet_y_pos > std_logic_vector(to_unsigned(70, 10))) then
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
