library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.game_pkg.ALL;

entity cnt_ball is 
	generic (
		N	     : INTEGER;
		MAX	     : INTEGER;
		MIN      : INTEGER;
		START    : INTEGER;
		CNT_MODE : INTEGER -- horizontal or vertical mode
	);
	
	Port (
		-- in
		enclk 	 : in  STD_LOGIC; 
		arst 	 : in  STD_LOGIC; -- asynchronous reset
		srst     : in  STD_LOGIC; -- synchronous reset
		clk 	 : in  STD_LOGIC;
		hit_rgt  : in  STD_LOGIC;
		hit_lft  : in  STD_LOGIC;
		hit_lft_area : in STD_LOGIC_VECTOR(2 downto 0);
		hit_rgt_area : in STD_LOGIC_VECTOR(2 downto 0);
		
		-- out
		q 		: out STD_LOGIC_VECTOR (N-1 downto 0);
		oob     : out STD_LOGIC; -- ball out-of-bounds
		oob_rgt : out STD_LOGIC;
		oob_lft : out STD_LOGIC
	);
end entity cnt_ball;

architecture Behavioral of cnt_ball is
	signal valint, valint1, valint2, valint3 : STD_LOGIC_VECTOR(N-1 downto 0);
	signal oob_int, maxedint, minint : STD_LOGIC;
	signal mode, mode1, mode2, mode3v, mode3h : STD_LOGIC;
	
	signal spd_mod : STD_LOGIC_VECTOR(1 downto 0);
	signal spd_mod_h, spd_mod_h1, spd_mod_h2 : STD_LOGIC_VECTOR(1 downto 0);
	signal spd_mod_v, spd_mod_v1, spd_mod_v2 : STD_LOGIC_VECTOR(1 downto 0);
begin
	q <= valint;
	valint  <= STD_LOGIC_VECTOR(to_unsigned(START,N)) when arst='1' else valint1 when rising_edge(clk);  
	valint1 <= valint2 when enclk='1' else valint;
	valint2 <= STD_LOGIC_VECTOR(to_unsigned(START,N)) when srst='1' else valint3;
	valint3 <= STD_LOGIC_VECTOR(to_unsigned(START,N)) when oob_int='1' and CNT_MODE=CNT_MODE_H else
	           STD_LOGIC_VECTOR(unsigned(valint) + unsigned(spd_mod)) when mode = INCR else 
	           STD_LOGIC_VECTOR(unsigned(valint) - unsigned(spd_mod)) when mode = DECR else
			   valint;
	
	-- mode (incrementation / decrementation)
	mode  <= INCR when arst='1' else mode1 when rising_edge(clk);
	mode1 <= mode2 when enclk='1' else mode;
	mode2 <= mode3h when CNT_MODE = CNT_MODE_H else mode3v;
	
	mode3h <= NOT mode when oob_int='1' else
			DECR when mode=INCR and hit_rgt='1' else
			INCR when mode=DECR and hit_lft='1' else 
			mode;
			  
	mode3v <= INCR when srst='1' else
			  DECR when maxedint='1' else
			  INCR when minint='1' else
			  mode;
	
	-- speed modifier	
	spd_mod <= spd_mod_h when CNT_MODE=CNT_MODE_H else spd_mod_v;
	
	spd_mod_h  <= SPEED_1 when arst='1' else spd_mod_h1 when rising_edge(clk);
	spd_mod_h1 <= SPEED_1 when srst='1' or (oob_int='1' and CNT_MODE=CNT_MODE_H) else spd_mod_h2;
	spd_mod_h2 <= SPEED_1 when hit_lft_area=CENTER_P or hit_rgt_area=CENTER_P else
				  SPEED_2 when hit_lft_area=TOP_P or hit_lft_area=BOTTOM_P
							   or hit_rgt_area=TOP_P or hit_rgt_area=BOTTOM_P
							   or hit_rgt_area=TOPCENT_P or hit_rgt_area=BOTCENT_P
							   or hit_lft_area=TOPCENT_P or hit_lft_area=BOTCENT_P else
				  spd_mod_h;
		
	spd_mod_v  <= SPEED_1 when arst='1' else spd_mod_v1 when rising_edge(clk);
	spd_mod_v1 <= SPEED_1 when srst='1' or (oob_int='1' and CNT_MODE=CNT_MODE_H) else spd_mod_v2;
	spd_mod_v2 <= SPEED_0 when hit_lft_area=TOP_P or hit_lft_area=BOTTOM_P
							   or hit_rgt_area=TOP_P or hit_rgt_area=BOTTOM_P else
				  SPEED_1 when hit_lft_area=CENTER_P or hit_rgt_area=CENTER_P 
							   or hit_rgt_area=TOPCENT_P or hit_rgt_area=BOTCENT_P
							   or hit_lft_area=TOPCENT_P or hit_lft_area=BOTCENT_P else
				  spd_mod_v;
	
	-- ball is out-of-bounds (a player has failed to retrieve the ball)
	oob      <= oob_int;
	oob_int  <= '1' when maxedint='1' or minint='1' else '0';
	
	oob_rgt <= maxedint;
	maxedint <= '1' when unsigned(valint) = MAX - 1 else '0';
	
	oob_lft <= minint;
	minint   <= '1' when unsigned(valint) = MIN else '0';
end architecture Behavioral;