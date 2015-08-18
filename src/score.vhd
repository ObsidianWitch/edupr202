library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.game_pkg.ALL;

entity score is 
	Port (
		clk       : in STD_LOGIC;
		arst      : in STD_LOGIC;
		srst      : in STD_LOGIC;
		en_score  : in STD_LOGIC;
		
		h_oob_rgt_ball : in STD_LOGIC;
		h_oob_lft_ball : in STD_LOGIC;
		
		q_sc1     : out STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
		q_sc2     : out STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
		
		maxed_sc1 : out STD_LOGIC;
		maxed_sc2 : out STD_LOGIC
	);
end entity score;

architecture Behavioral of score is
	-- score
	signal maxed_sc1_int : STD_LOGIC;
	signal maxed_sc2_int : STD_LOGIC;
	
begin
	-- player1 score counter
	cnt_score1: entity work.cnt(Behavioral)
		GENERIC MAP (
			N   => N_SCORE,
			MAX => MAX_SCORE
		)
		PORT MAP (
			arst  => arst,
			srst  => maxed_sc2_int OR srst,
			clk   => clk,
			enclk => en_score,
			cnten => h_oob_rgt_ball,
			maxed => maxed_sc1_int,
			q     => q_sc1
		);
	
	-- player2 score counter
	cnt_score2: entity work.cnt(Behavioral)
		GENERIC MAP (
			N   => N_SCORE,
			MAX => MAX_SCORE
		)
		PORT MAP (
			arst  => arst,
			srst  => maxed_sc1_int OR srst,
			clk   => clk,
			enclk => en_score,
			cnten => h_oob_lft_ball,
			maxed => maxed_sc2_int,
			q     => q_sc2
		);
	
	maxed_sc1 <= maxed_sc1_int;
	maxed_sc2 <= maxed_sc2_int;
	
end architecture Behavioral;