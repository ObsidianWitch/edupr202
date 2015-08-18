library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.vga_pkg.ALL;
use work.game_pkg.ALL;

entity ball is
	port (
		clk     : in  STD_LOGIC;
		arst    : in  STD_LOGIC;
		en_ball : in  STD_LOGIC;
		
		q_player1 : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		q_player2 : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		
		v_q_ball : out STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		h_q_ball : out STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		h_oob_rgt_ball : out STD_LOGIC;
		h_oob_lft_ball : out STD_LOGIC;
		hit_ball : out STD_LOGIC
	);
end ball;

architecture Behavioral of ball is
	signal v_q_ball_int  : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	signal h_q_ball_int  : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	
	signal hit_lft_area : STD_LOGIC_VECTOR(2 downto 0);
	signal hit_lft_area1 : STD_LOGIC_VECTOR(2 downto 0);
	signal hit_rgt_area : STD_LOGIC_VECTOR(2 downto 0);
	signal hit_rgt_area1 : STD_LOGIC_VECTOR(2 downto 0);
	
	signal rgt_hit_ball : STD_LOGIC;
	signal lft_hit_ball : STD_LOGIC;
	signal h_oob_ball   : STD_LOGIC;
	
begin
	-- ball counter horizontal
	cnt_ball_h: entity work.cnt_ball(Behavioral)
		GENERIC MAP (
			N => N_VGA,
			MAX => H_AT - SIZE_BALL,
			MIN => 0,
			START => H_START_BALL,
			CNT_MODE => CNT_MODE_H
		)
		PORT MAP (
			-- in
			enclk   => en_ball,
			arst    => arst,
			srst    => '0',
			clk     => clk,
			hit_rgt => rgt_hit_ball,
			hit_lft => lft_hit_ball,
			hit_lft_area => hit_lft_area,
			hit_rgt_area => hit_rgt_area,
			
			-- out
			q       => h_q_ball_int,
			oob     => h_oob_ball,
			oob_rgt => h_oob_rgt_ball,
			oob_lft => h_oob_lft_ball
		);
		
	-- ball counter vertical
	cnt_ball_v: entity work.cnt_ball(Behavioral)
		GENERIC MAP (
			N => N_VGA,
			MAX => V_AT - SIZE_BALL,
			MIN => 0,
			START => V_START_BALL,
			CNT_MODE => CNT_MODE_V
		)
		PORT MAP (
			-- in
			enclk   => en_ball,
			arst    => arst,
			srst    => h_oob_ball, -- reset ball vert. pos. when ball oob horizontally
			clk     => clk,
			hit_rgt => rgt_hit_ball,
			hit_lft => lft_hit_ball,
			hit_lft_area => hit_lft_area,
			hit_rgt_area => hit_rgt_area,
			
			-- out
			q       => v_q_ball_int,
			oob     => open,
			oob_rgt => open,
			oob_lft => open
		);
	
	-- ball collision with the paddle
	hit_ball <= '1' when lft_hit_ball='1' or rgt_hit_ball='1' else '0';
	lft_hit_ball <= '1' when
			(v_q_ball_int >= q_player1 - SIZE_BALL
			or v_q_ball_int >= q_player1) -- avoid collision problem top-left of the screen
			and v_q_ball_int < q_player1 + HEIGHT_PLAYER
			and h_q_ball_int = OFST_PLAYER + WIDTH_PLAYER
		else '0';
	rgt_hit_ball <= '1' when 
			(v_q_ball_int >= q_player2 - SIZE_BALL
			or v_q_ball_int >= q_player2) -- avoid collision problem top-right of the screen
			and v_q_ball_int < q_player2 + HEIGHT_PLAYER
			and h_q_ball_int = H_AT - OFST_PLAYER - WIDTH_PLAYER - SIZE_BALL - 1
		else '0';
	
	-- collision areas with the paddle (3 areas: TOP_P, CENTER_P and BOTTOM_P)
	hit_lft_area  <= hit_lft_area1 when lft_hit_ball='1' else OUTSIDE_P;
	hit_lft_area1 <= TOP_P    when v_q_ball_int >= q_player1 - SIZE_BALL
							   and v_q_ball_int < q_player1 - SIZE_BALL + DIVIDE_P else
					TOPCENT_P when v_q_ball_int >= q_player1 - SIZE_BALL + DIVIDE_P
								   and v_q_ball_int < q_player1 - SIZE_BALL + (2*DIVIDE_P) else
					CENTER_P  when v_q_ball_int >= q_player1 - SIZE_BALL + (2*DIVIDE_P)
								   and v_q_ball_int < q_player1 - SIZE_BALL + (3*DIVIDE_P) else
					BOTCENT_P when v_q_ball_int >= q_player1 - SIZE_BALL + (3*DIVIDE_P)
								   and v_q_ball_int < q_player1 - SIZE_BALL + (4*DIVIDE_P) else
					BOTTOM_P  when v_q_ball_int >= q_player1 - SIZE_BALL + (4*DIVIDE_P)
								   and v_q_ball_int < q_player1 - SIZE_BALL + (5*DIVIDE_P) else
					OUTSIDE_P;
					 
	hit_rgt_area  <= hit_rgt_area1 when rgt_hit_ball='1' else OUTSIDE_P;
	hit_rgt_area1 <= TOP_P    when v_q_ball_int >= q_player2 - SIZE_BALL
							   and v_q_ball_int < q_player2 - SIZE_BALL + DIVIDE_P else
					TOPCENT_P when v_q_ball_int >= q_player2 - SIZE_BALL + DIVIDE_P
								   and v_q_ball_int < q_player2 - SIZE_BALL + (2*DIVIDE_P) else
					CENTER_P  when v_q_ball_int >= q_player2 - SIZE_BALL + (2*DIVIDE_P)
								   and v_q_ball_int < q_player2 - SIZE_BALL + (3*DIVIDE_P) else
					BOTCENT_P when v_q_ball_int >= q_player2 - SIZE_BALL + (3*DIVIDE_P)
								   and v_q_ball_int < q_player2 - SIZE_BALL + (4*DIVIDE_P) else
					BOTTOM_P  when v_q_ball_int >= q_player2 - SIZE_BALL + (4*DIVIDE_P)
								   and v_q_ball_int < q_player2 - SIZE_BALL + (5*DIVIDE_P) else
					OUTSIDE_P;
	
	-- ball counter outputs
	h_q_ball <= h_q_ball_int;
	v_q_ball <= v_q_ball_int;
end Behavioral;
