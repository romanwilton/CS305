LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fsm is
	port (
		clock, btn_1, left_btn, right_btn, off_screen, collision, win, game_over : IN std_logic;
		bullet_shot, ai_reset, ai_respawn, increase_score, increase_streak : OUT std_logic;
		state_indicator : OUT std_logic_vector(3 downto 0)
	);
end entity fsm;

architecture arch of fsm is
	type states is (start, not_shot, shot, collided, ai_win);
	signal state : states := start;
	signal next_state : states;
begin

	progress_state : process (clock) is
	begin
		if rising_edge(clock) then
			state <= next_state;
		end if;
	end process progress_state;

	next_state_logic : process (state, btn_1, left_btn, right_btn, off_screen, collision, win, game_over) is
	begin
		case state is
			when start =>
				if (game_over = '1') then
					next_state <= start;
				else
					next_state <= not_shot;
				end if;
			when not_shot =>
				if (game_over = '1') then
					next_state <= start;
				elsif (left_btn = '1') then
					next_state <= shot;
				elsif(win = '1') then
					next_state <= ai_win;
				else
					next_state <= not_shot;
				end if;
			when shot =>
				if (game_over = '1') then
					next_state <= start;
				elsif (off_screen = '1') then
					next_state <= not_shot;
				elsif (collision = '1') then
					next_state <= collided;
				else
					next_state <= shot;
				end if;
			when collided =>
			if (game_over = '1') then
					next_state <= start;
				else
					next_state <= not_shot;
				end if;
			when ai_win =>
				if (game_over = '1') then
					next_state <= start;
				else
					next_state <= not_shot;
				end if;
		end case;
	end process next_state_logic;
	
	output_logic : process (state) is
	begin
		bullet_shot <= '0';
		increase_score <= '0';
		ai_reset <= '0';
		ai_respawn <= '0';
		increase_streak <= '0';


		case state is
			when start =>
				ai_reset <= '1';
				state_indicator <= "0001";
			when not_shot =>
				state_indicator <= "0010";
			when shot =>
				bullet_shot <= '1';
				state_indicator <= "0100";
			when collided =>
				increase_score <= '1';
				increase_streak <= '1';
				state_indicator <= "0101";
			when ai_win =>
				ai_respawn <= '1';
				state_indicator <= "0110";
		end case;
	end process output_logic;

end architecture arch;
