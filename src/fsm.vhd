LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fsm is
	port (
		clock, reset, btn_1, left_btn, off_screen, collision, win : IN std_logic;
		bullet_shot, ai_reset, ai_respawn, tank_hit : OUT std_logic
	);
end entity fsm;

architecture arch of fsm is
	type states is (disable, inactive, not_shot, shot, collided, ai_win);
	signal state : states := disable;
	signal next_state : states;
begin

	progress_state : process (clock) is
	begin
		if rising_edge(clock) then
			state <= next_state;
		end if;
	end process progress_state;

	next_state_logic : process (state, reset, btn_1, left_btn, off_screen, collision, win) is
	begin
		case state is
			when disable =>
					next_state <= inactive;
			when inactive =>
				if (reset = '1') then
					next_state <= disable;
				elsif (btn_1 = '1') then
					next_state <= not_shot;
				else
					next_state <= inactive;
				end if;
			when not_shot =>
				if (reset = '1') then
					next_state <= disable;
				elsif (left_btn = '1') then
					next_state <= shot;
				elsif(win = '1') then
					next_state <= ai_win;
				else
					next_state <= not_shot;
				end if;
			when shot =>
				if (reset = '1') then
					next_state <= disable;
				elsif (off_screen = '1') then
					next_state <= not_shot;
				elsif (collision = '1') then
					next_state <= collided;
				else
					next_state <= shot;
				end if;
			when collided =>
				if (reset = '1') then
					next_state <= disable;
				else
					next_state <= not_shot;
				end if;
			when ai_win =>
				if (reset = '1') then
					next_state <= disable;
				else
					next_state <= not_shot;
				end if;
		end case;
	end process next_state_logic;
	
	output_logic : process (state) is
	begin
		bullet_shot <= '0';
		tank_hit <= '0';
		ai_reset <= '0';
		ai_respawn <= '0';


		case state is
			when disable =>
				ai_reset <= '1';
			when inactive =>
			when not_shot =>
			when shot =>
				bullet_shot <= '1';
			when collided =>
				tank_hit <= '1';
			when ai_win =>
				ai_respawn <= '1';
		end case;
	end process output_logic;

end architecture arch;
