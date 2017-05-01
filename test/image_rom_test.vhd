LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;

entity image_rom_test is
end entity;

architecture arch of image_rom_test is

	component image_rom IS
		generic (
			image_path : string;
			width, height : integer
		);
		PORT (
			pixel_x, pixel_y, show_x, show_y	:	IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			clock								: 	IN STD_LOGIC;
			RGB									:	OUT STD_LOGIC_VECTOR(15 downto 0)
		);
	END component image_rom;
	
	signal pixel_x_t, pixel_y_t : STD_LOGIC_VECTOR (9 DOWNTO 0);
	signal clock_t, enable : STD_LOGIC;
	signal RGB_t : STD_LOGIC_VECTOR(15 downto 0);
	signal R, G, B : STD_LOGIC_VECTOR(4 downto 0);

begin

	DUT: image_rom generic map ("test2.mif", 2, 2) port map (pixel_x_t, pixel_y_t, "0000000010", "0000000010", clock_t, RGB_t);
	
	clk : process is
	begin
		clock_t <= '1';
		wait for 10 ns;
		clock_t <= '0';
		wait for 10 ns;
	end process clk;
	
	pixel_x_t <= "0000000001", "0000000010" after 2000 ns;
	pixel_y_t <= "0000000001", "0000000010" after 1000 ns, "0000000001" after 3000 ns;
	
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
				assert RGB_t = X"F111";
			elsif pixel_x_t = "0000000010" and pixel_y_t = "0000000001" then
				assert RGB_t = X"F222";
			elsif pixel_x_t = "0000000010" and pixel_y_t = "0000000010" then
				assert RGB_t = X"F333";
			end if;
		end if;	
	end process testing;
	
end architecture;
