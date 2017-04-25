LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fsm is
	port (
		clock, btn_1, left_btn, right_btn, off_screen, collision : IN std_logic;
		bullet_shot, ai_reset : OUT std_logic
	);
end entity fsm;

architecture arch of fsm is
	type states is (start, not_shot, shot, collided);
	signal state : states := start;
	signal next_state : states;
begin

	progress_state : process (clock) is
	begin
		if rising_edge(clock) then
			state <= next_state;
		end if;
	end process progress_state;

	next_state_logic : process (btn_1, left_btn, right_btn, off_screen, collision) is
	begin
		case state is
			when start =>
				if (btn_1 = '1') then
					next_state <= not_shot;
				else
					next_state <= start;
				end if;
			when not_shot =>
				if (left_btn = '1') then
					next_state <= shot;
				else
					next_state <= not_shot;
				end if;
			when shot =>
				if (off_screen = '1') then
					next_state <= not_shot;
				elsif (collision = '1') then
					next_state <= collided;
				else
					next_state <= shot;
				end if;
			when collided =>
				next_state <= not_shot;
		end case;
	end process next_state_logic;
	
	output_logic : process (state) is
	begin
		case state is
			when start =>
				bullet_shot <= '0';
				ai_reset <= '1';
			when not_shot =>
				bullet_shot <= '0';
				ai_reset <= '0';
			when shot =>
				bullet_shot <= '1';
				ai_reset <= '0';
			when collided =>
				bullet_shot <= '0';
				ai_reset <= '1';
		end case;
	end process output_logic;

end architecture arch;
