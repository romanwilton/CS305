LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fsm is
	port (
		clock, btn_1, left_btn, right_btn, off_screen, collision : IN std_logic;
		bullet_shot, ai_reset, ai_hold, increase_score : OUT std_logic;
		state_indicator : OUT std_logic_vector(3 downto 0)
	);
end entity fsm;

architecture arch of fsm is
	type states is (start, hold, not_shot, shot, collided);
	signal state : states := start;
	signal next_state : states;
begin

	progress_state : process (clock) is
	begin
		if rising_edge(clock) then
			state <= next_state;
		end if;
	end process progress_state;

	next_state_logic : process (state, btn_1, left_btn, right_btn, off_screen, collision) is
	begin
		case state is
			when start =>
				next_state <= hold;
			when hold =>
				if (btn_1 = '1') then
					next_state <= not_shot;
				else
					next_state <= hold;
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
				increase_score <= '0';
				ai_reset <= '1';
				ai_hold <= '0';
				state_indicator <= "0001";
			when hold =>
				bullet_shot <= '0';
				increase_score <= '0';
				ai_reset <= '0';
				ai_hold <= '1';
				state_indicator <= "0001";
			when not_shot =>
				bullet_shot <= '0';
				increase_score <= '0';
				ai_reset <= '0';
				ai_hold <= '0';
				state_indicator <= "0010";
			when shot =>
				bullet_shot <= '1';
				increase_score <= '0';
				ai_reset <= '0';
				ai_hold <= '0';
				state_indicator <= "0100";
			when collided =>
				bullet_shot <= '0';
				increase_score <= '1';
				ai_reset <= '1';
				ai_hold <= '0';
				state_indicator <= "1000";
		end case;
	end process output_logic;

end architecture arch;
