LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fsm is
	port (
		clock, btn_1, left_btn, right_btn, off_screen, collision : IN std_logic;
		buttet_shot, ai_reset : OUT std_logic
	);
end entity fsm;
