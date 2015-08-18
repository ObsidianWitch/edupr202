library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.vga_pkg.ALL;
use work.game_pkg.ALL;

entity game is
	port (
		clk  : in  STD_LOGIC;
		arst : in  STD_LOGIC;
		
		video_on : in STD_LOGIC;
		h_q_vga  : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		v_q_vga  : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		en_px    : in STD_LOGIC;

		key_up1   : in STD_LOGIC;
		key_down1 : in STD_LOGIC;
		key_up2   : in STD_LOGIC;
		key_down2 : in STD_LOGIC;
		kbd_enter : in STD_LOGIC;
		
		red   : out STD_LOGIC_VECTOR(2 downto 0);
		green : out STD_LOGIC_VECTOR(2 downto 0);
		blue  : out STD_LOGIC_VECTOR(1 downto 0);
		
		snd : out STD_LOGIC
	);
end game;

architecture Behavioral of game is
	-- general
	signal srst_game  : STD_LOGIC;
	signal en_game    : STD_LOGIC;
	signal en_game1   : STD_LOGIC;
	signal game_state : STD_LOGIC_VECTOR(1 downto 0);

	-- score
	signal q_sc1 : STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
	signal q_sc2 : STD_LOGIC_VECTOR(N_SCORE-1 downto 0);	
	signal win_player1 : STD_LOGIC;
	signal win_player2 : STD_LOGIC;
	
	-- players
	signal en_player  : STD_LOGIC;
	signal en_player1 : STD_LOGIC;
	signal q_player1  : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	signal q_player2  : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	
	-- ball
	signal v_q_ball : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	signal h_q_ball : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	signal h_oob_rgt_ball : STD_LOGIC;
	signal h_oob_lft_ball : STD_LOGIC;
	signal hit_ball : STD_LOGIC;

begin
	-- game enable (clock divider)
	game_clk: entity work.clkdiv(Behavioral)
		GENERIC MAP (
			FDIV => CLK_GAME
		)
		PORT MAP (
			arst  => arst,
			en    => '1',
			clk   => clk,
			enclk => en_game1
		);
	
	-- player enable (clock divider)
	player_clk: entity work.clkdiv(Behavioral)
		GENERIC MAP (
			FDIV => CLK_PLAYER
		)
		PORT MAP (
			arst  => arst,
			en    => '1',
			clk   => clk,
			enclk => en_player1
		);

	-- player
	player: entity work.player(Behavioral)
		PORT MAP (
			-- in
			clk       => clk,
			arst      => arst,
			en_player => en_player,
			key_up1   => key_up1,
			key_down1 => key_down1,
			key_up2   => key_up2,
			key_down2 => key_down2,
			
			-- out
			q_player1 => q_player1,
			q_player2 => q_player2
		);
	
	-- sounds
	sounds: entity work.sounds(Behavioral)
		PORT MAP (
			clk  => clk,
			arst => arst,
			hit_ball => hit_ball,
			snd => snd
		);
		
	-- ball
	ball: entity work.ball(Behavioral)
		PORT MAP (
			-- in
			clk       => clk,
			arst      => arst,
			en_ball   => en_game,
			q_player1 => q_player1,
			q_player2 => q_player2,
			
			-- out
			v_q_ball       => v_q_ball,
			h_q_ball       => h_q_ball,
			h_oob_rgt_ball => h_oob_rgt_ball,
			h_oob_lft_ball => h_oob_lft_ball,
			hit_ball => hit_ball
		);
	
	-- score
	score: entity work.score(Behavioral)
		PORT MAP (
			-- in
			clk            => clk,
			arst           => arst,
			srst           => srst_game,
			en_score       => en_game,
			h_oob_rgt_ball => h_oob_rgt_ball,
			h_oob_lft_ball => h_oob_lft_ball,
			
			-- out
			q_sc1 => q_sc1,
			q_sc2 => q_sc2,
			maxed_sc1 => win_player1,
			maxed_sc2 => win_player2
		);
	
	-- game generator (colors generator)
	game_gen : entity work.game_gen 
		PORT MAP (
			-- in
			clk           => clk,
			arst          => arst,
			video_on      => video_on,
			h_q_vga       => h_q_vga,
			v_q_vga       => v_q_vga,
			en_px         => en_px,
			q_sc1         => q_sc1,
			q_sc2         => q_sc2,
			q_player1     => q_player1,
			q_player2     => q_player2,
			v_q_ball      => v_q_ball,
			h_q_ball      => h_q_ball,
			game_state    => game_state,
			
			-- out
			red   => red,
			green => green,
			blue  => blue
		);

	-- game state
	state : entity work.game_state
		PORT MAP (
			clk => clk,
			arst => arst,
			kbd_enter => kbd_enter,
			win_player1 => win_player1,
			win_player2 => win_player2,
			state_out => game_state
		);
	
	-- game entities (ball, player and score) enabled only when game started (game_state=GAME) and
	-- clk_div output high.
	-- note: conflict between this entity name (game) and game_pkg GAME constant
	en_game <= '1' when en_game1='1' and game_state = work.game_pkg.GAME else '0';
	en_player <= '1' when en_player1='1' and game_state = work.game_pkg.GAME else '0'; 
	
	srst_game <= '1' when game_state /= work.game_pkg.GAME else '0';
	
end Behavioral;