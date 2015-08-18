library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.game_pkg.ALL;

entity game_state is
	PORT (
		clk  : in  STD_LOGIC;
		arst : in  STD_LOGIC;
		
		kbd_enter : in STD_LOGIC;
		win_player1 : in STD_LOGIC;
		win_player2 : in STD_LOGIC;
		
		state_out : out STD_LOGIC_VECTOR(1 downto 0)
	);
end game_state;

architecture Behavioral of game_state is
	signal game_state : STD_LOGIC_VECTOR(1 downto 0);
	signal game_state1 : STD_LOGIC_VECTOR(1 downto 0);
	
	signal kbd_enter_new : STD_LOGIC;
	signal kbd_enter_old : STD_LOGIC;
	
begin
	kbd_enter_new <= '0' when arst='1' else kbd_enter when rising_edge(clk);
	kbd_enter_old <= '0' when arst='1' else kbd_enter_new when rising_edge(clk);
	
	state_out <= game_state;
	game_state  <= START when arst='1' else game_state1 when rising_edge(clk);
	game_state1 <= GAME when game_state=START and kbd_enter_new='1' and kbd_enter_old='0' else
				   WIN1 when game_state=GAME and win_player1='1' else
				   WIN2 when game_state=GAME and win_player2='1' else
				   START when (game_state=WIN1 or game_state=WIN2) and kbd_enter_new='1' else
	               game_state;
	
end Behavioral;