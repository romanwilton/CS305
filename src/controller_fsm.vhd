LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.util.all;

entity controller_fsm is
	port (
		clock, play, train, win, die, mouse_left, reset : IN std_logic;
		show_menu, trainingMode : OUT std_logic;
		level : OUT std_logic_vector(1 downto 0);
		state_out : OUT states
	);
end entity controller_fsm;

architecture arch of controller_fsm is
	signal state : states := menu;
	signal next_state : states;
begin

	progress_state : process (clock) is
	begin
		if rising_edge(clock) then
			state <= next_state;
		end if;
	end process progress_state;

	next_state_logic : process (state, play, train, win, die, mouse_left, reset) is
	begin
		case state is
			when menu =>
				if (play = '1') then
					next_state <= level1;
				elsif (train = '1') then
					next_state <= training;
				else
					next_state <= menu;
				end if;
			when level1 =>
				if (reset = '1') then
					next_state <= menu;
				elsif (win = '1') then
					next_state <= level2;
				elsif (die = '1') then
					next_state <= fail;
				else
					next_state <= level1;
				end if;
			when level2 =>
				if (reset = '1') then
					next_state <= menu;
				elsif (win = '1') then
					next_state <= level3;
				elsif (die = '1') then
					next_state <= fail;
				else
					next_state <= level2;
				end if;
			when level3 =>
				if (reset = '1') then
					next_state <= menu;
				elsif (win = '1') then
					next_state <= success;
				elsif (die = '1') then
					next_state <= fail;
				else
					next_state <= level3;
				end if;
			when training =>
				if (reset = '1') then
					next_state <= menu;
				elsif (die = '1') then
					next_state <= menu;
				else
					next_state <= training;
				end if;
			when fail =>
				if (mouse_left = '1' or reset = '1') then
					next_state <= menu;
				else
					next_state <= fail;
				end if;
			when success =>
				if (mouse_left = '1' or reset = '1') then
					next_state <= menu;
				else
					next_state <= success;
				end if;
		end case;
	end process next_state_logic;
	
	output_logic : process (state) is
	begin
		show_menu <= '0';
		trainingMode <= '0';
		level <= "00";


		case state is
			when menu =>
				show_menu <= '1';
			when level1 =>
				level <= "01";
			when level2 =>
				level <= "10";
			when level3 =>
				level <= "11";
			when training =>
				trainingMode <= '1';
				level <= "01";
			when fail =>
				show_menu <= '1';
			when success =>
				show_menu <= '1';
		end case;
	end process output_logic;

state_out <= state;
end architecture arch;
