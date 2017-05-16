LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.util.all;

entity ai_tank is
	generic (
		IMAGE : in string := "images/enemyTank.mif";
		SPEED : in natural := 3
	);
	port (
		clock, reset, respawn, hold, enable_move : IN std_logic;
		pixel_row, pixel_col, new_pos, bullet_x_pos, bullet_y_pos : IN std_logic_vector(9 downto 0);
		collision, win	: OUT std_logic;
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity ai_tank;

architecture arch of ai_tank is
	constant width : natural := 50;
	constant height : natural := 54;
	constant intital_y : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(80, 10);
	
	procedure reset_AI_tank (
		signal new_pos : in std_logic_vector(9 downto 0);
		constant intital_y : in std_logic_vector(9 downto 0);
		variable rand_in : inout std_logic_vector(9 downto 0);
		variable intermediate : inout std_logic_vector(14 downto 0);
		variable x_var : inout std_logic_vector(9 downto 0);
		signal x, y : out std_logic_vector(9 downto 0);
		signal moveDir : out std_logic
	) is
	begin
		-- Multiply by ~0.6 using (<<4 + <<1 + <<0)>>5
		rand_in := new_pos;
		intermediate := ("0"&rand_in&"0000") + ("0000"&rand_in&"0") + ("00000"&rand_in);
		x_var := intermediate(14 downto 5);
		x <= x_var;
		y <= intital_y;
		if x_var > 320 then
			moveDir <= '1';
		else
			moveDir <= '0';
		end if;
	end procedure;

	signal x : std_logic_vector(9 downto 0);
	signal y : std_logic_vector(9 downto 0);
	signal moveDir : std_logic := '0';
	signal s_collision, do_display : std_logic := '0';
	signal RGB : std_logic_vector(15 downto 0);
begin
	output_drawing : entity work.draw_object generic map (IMAGE, width, height) 
		port map(clock, pixel_row, pixel_col, x, y, RGB);

	movement : process (clock) is
		variable rand_in : std_logic_vector(9 downto 0);
		variable intermediate : std_logic_vector(14 downto 0);
		variable x_var : std_logic_vector(9 downto 0);
	begin
		if (rising_edge(clock)) then
			if (reset = '1' or (respawn = '1' and s_collision = '1')) then
			
				do_display <= '1';
				reset_AI_tank(new_pos, intital_y, rand_in, intermediate, x_var, x, y, moveDir);
				
			end if;
			if (enable_move = '1' AND hold = '0') then
				
				if (x >= CONV_STD_LOGIC_VECTOR(640, 10)) and (x <= CONV_STD_LOGIC_VECTOR(650, 10)) then
					y <= y + 20;
					moveDir <= '1';
				elsif (x >= CONV_STD_LOGIC_VECTOR(800, 10)) then
					moveDir <= '0';
					y <= y + 20;
				end if;

				if(moveDir = '0') then
					x <= x + SPEED;
				else
					x <= x - SPEED; 	
				end if; 

			end if;
			if(y >= CONV_STD_LOGIC_VECTOR(420, 10)) then
					win <= '1';
					reset_AI_tank(new_pos, intital_y, rand_in, intermediate, x_var, x, y, moveDir);
				else
					win <= '0';
				end if;
		end if;
	end process ; -- movement

	collisions : process (bullet_y_pos, bullet_x_pos, x, y) is
	begin
		if(bullet_y_pos < y + height/2 AND bullet_y_pos > y - height/2) then
			if(bullet_x_pos < x + width/2 AND bullet_x_pos + width/2 > x) then
				s_collision <= '1';
			else
				s_collision <= '0';
			end if;
		else
			s_collision <= '0';
		end if;
	end process ; -- collisions
	
	collision <= s_collision;
	RGB_out <= RGB when do_display = '1' else X"0000";
end architecture arch;
