LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;

entity draw_object_test is
end entity;

architecture arch of draw_object_test is

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
	
	signal pixel_x_t, pixel_y_t, x_t, y_t : STD_LOGIC_VECTOR (9 DOWNTO 0) := "1111111111";
	signal clock_t, enable : STD_LOGIC := '0';
	signal RGB_t : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
	signal R, G, B : STD_LOGIC_VECTOR(4 downto 0) := "00000";

begin

	DUT: draw_object generic map ("test2.mif", 2, 2) port map (clock_t, pixel_y_t, pixel_x_t, x_t, y_t, RGB_t);
	
	clk : process is
	begin
		clock_t <= '1';
		wait for 10 ns;
		clock_t <= '0';
		wait for 10 ns;
	end process clk;
	
	x_t <= "0000000010";
	y_t <= "0000000010";
	
	-- pixel_x_t <= "0000000000", "0000000001" after 300 ns, "0000000010" after 2000 ns, "0000000011" after 4000 ns;
	-- pixel_y_t <= "0000000000", "0000000001" after 500 ns, "0000000010" after 1000 ns, "0000000001" after 3000 ns, "0000000011" after 4300 ns;
	
	-- pixel_x_t <= "0000000001";
	-- process is
	-- begin
		-- wait until rising_edge(clock_t);
		-- pixel_y_t <= std_logic_vector(unsigned(pixel_y_t) + 1);
	-- end process;
	
	pixel_y_t <= "0000000001";
	process is
	begin
		wait until rising_edge(clock_t);
		pixel_x_t <= std_logic_vector(unsigned(pixel_x_t) + 1);
	end process;
	
	enable <= RGB_t(15);
	R <= RGB_t(14 downto 10);
	G <= RGB_t(9 downto 5);
	B <= RGB_t(4 downto 0);
	
	testing : process (clock_t) is
	begin
		if clock_t'event and clock_t = '0' then
			if pixel_x_t = "0000000001" and pixel_y_t = "0000000001" then
				assert RGB_t = X"F000";
			elsif pixel_x_t = "0000000001" and pixel_y_t = "0000000010" then
				--assert RGB_t = X"F111";
				assert RGB_t = X"F222";
			elsif pixel_x_t = "0000000010" and pixel_y_t = "0000000001" then
				--assert RGB_t = X"F222";
				assert RGB_t = X"F111";
			elsif pixel_x_t = "0000000010" and pixel_y_t = "0000000010" then
				assert RGB_t = X"F333";
			else
				assert RGB_t = X"0000";
			end if;
		end if;	
	end process testing;
	
end architecture;
