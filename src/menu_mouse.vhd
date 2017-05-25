LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.util.all;


entity menu_mouse is
	port (
		clock, mouse_left, enable_move : IN std_logic;
		state : IN states;
		mouse_x, mouse_y : IN std_logic_vector(9 downto 0);
		pixel_row, pixel_col : IN std_logic_vector(9 downto 0);
		play_hover, play_click, train_hover, train_click : OUT std_logic;
		RGB_out	: OUT std_logic_vector(15 downto 0)
	);
end entity menu_mouse;


architecture arch of menu_mouse is
	constant IMAGE : string := "images/cursor.mif";
	constant width, height : integer := 10;
	signal x, y : std_logic_vector(9 downto 0);
	signal RGB_out_s : std_logic_vector(15 downto 0);
begin
	output_drawing : entity work.draw_object generic map (IMAGE, width, height) 
	port map(clock, pixel_row, pixel_col, x, y, RGB_out_s);

	RGB_out <= RGB_out_s when state = menu else X"0000";

	process( clock )
			variable mouse_left_rising_edge, oldvalue : std_logic;
	begin
		if(rising_edge(clock)) then
			if(enable_move = '1') then
				x <= mouse_x;
				y <= mouse_y;
			end if;

			if (oldvalue /= mouse_left) and mouse_left = '1' and state = menu then
				mouse_left_rising_edge := '1';
			else
				mouse_left_rising_edge := '0';
			end if;
			oldvalue := mouse_left;


			if(mouse_y >= 160 and mouse_y < 260 and mouse_x >= 200 and mouse_x < 460) then
				play_hover <= '1';
				train_hover <= '0';
				if(mouse_left_rising_edge = '1') then
					play_click <= '1';
				else
					play_click <= '0';
				end if;
			elsif(mouse_y >= 300 and mouse_y < 400 and mouse_x >= 180 and mouse_x < 500) then
				train_hover <= '1';
				play_hover <= '0';
				if(mouse_left_rising_edge = '1') then
					train_click <= '1';
				else
					train_click <= '0';
				end if;
			end if;
		end if;
	end process ;

end architecture ; -- arch