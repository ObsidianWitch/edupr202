library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.vga_pkg.ALL;

package game_pkg is
	-- general
	constant CLK_GAME : INTEGER := 250; 

	-- score
	constant N_SCORE        : INTEGER := 4;
	constant MAX_SCORE      : INTEGER := 10;
	constant H_OFST_SCORE1  : INTEGER := 290;
	constant H_OFST_SCORE2  : INTEGER := 335;
	constant V_OFST_SCORE   : INTEGER := 50;
	
	-- player
	constant CLK_PLAYER    : INTEGER := 500;
	constant OFST_PLAYER   : INTEGER := 10;  -- player cursor offset
	constant WIDTH_PLAYER  : INTEGER := 4;   -- player cursor width
	constant HEIGHT_PLAYER : INTEGER := 80;  -- player cursor height
	-- player areas
	constant DIVIDE_P  : INTEGER := 19;
	constant TOP_P     : STD_LOGIC_VECTOR(2 downto 0) := "101";
	constant TOPCENT_P : STD_LOGIC_VECTOR(2 downto 0) := "100";
	constant BOTTOM_P  : STD_LOGIC_VECTOR(2 downto 0) := "011";
	constant BOTCENT_P : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant CENTER_P  : STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant OUTSIDE_P : STD_LOGIC_VECTOR(2 downto 0) := "000";
	
	-- ball
	constant SIZE_BALL     : INTEGER := 15;
	constant H_START_BALL  : INTEGER := 312;
	constant V_START_BALL  : INTEGER := 239;
	constant CNT_MODE_H    : INTEGER := 0;
	constant CNT_MODE_V    : INTEGER := 1;
	constant SPEED_0       : STD_LOGIC_VECTOR(1 downto 0) := "00";
	constant SPEED_1       : STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant SPEED_2       : STD_LOGIC_VECTOR(1 downto 0) := "10";
	constant INCR          : STD_LOGIC := '1';
	constant DECR          : STD_LOGIC := '0';
	
	-- font	
	constant N_FT_ADR      : INTEGER := 10;
	constant N_FT_OUT      : INTEGER := 14;
	constant N_FTCNT       : INTEGER := 4;
	constant FONT_HEIGHT   : INTEGER := 14;
	constant FONT_WIDTH    : INTEGER := 14;
	constant FONT_PADDING  : INTEGER := 2;
	constant BASE_EMPTY    : INTEGER := 511;
	constant BASE_E        : INTEGER := 56;
	constant BASE_I        : INTEGER := 112;
	constant BASE_N        : INTEGER := 182;
	constant BASE_P        : INTEGER := 210;
	constant BASE_R        : INTEGER := 238;
	constant BASE_S        : INTEGER := 252;
	constant BASE_T        : INTEGER := 266;
	constant BASE_W        : INTEGER := 308;
	constant BASE_NUMBERS  : INTEGER := 364; -- base address for numbers
	constant BASE_0        : INTEGER := BASE_NUMBERS;
	constant BASE_1        : INTEGER := BASE_NUMBERS + FONT_HEIGHT;
	constant BASE_2        : INTEGER := BASE_NUMBERS + (2*FONT_HEIGHT);
	
	-- states
	constant START : STD_LOGIC_VECTOR(1 downto 0) := "00";
	constant GAME  : STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant WIN1  : STD_LOGIC_VECTOR(1 downto 0) := "10";
	constant WIN2  : STD_LOGIC_VECTOR(1 downto 0) := "11";
	
	-- start screen
	constant H_OFST_START  : INTEGER := 281;
	constant WIDTH_START   : INTEGER := 140;
	constant HEIGHT_START  : INTEGER := (2*FONT_HEIGHT) + FONT_PADDING;
	constant V_OFST_START1 : INTEGER := 70;
	constant V_OFST_START2 : INTEGER := 86;
	
	-- win screen
	constant H_OFST_WIN : INTEGER := H_OFST_START;
	constant V_OFST_WIN : INTEGER := V_OFST_START1;
	constant WIDTH_WIN  : INTEGER := WIDTH_START;
	constant HEIGHT_WIN : INTEGER := FONT_HEIGHT;
	
	-- background
	constant N_BG_ADR  : INTEGER   := 14;
	constant N_BG_OUT  : INTEGER   := 8;
	constant ZERO    : INTEGER   := 0;
	constant H_FULL  : INTEGER := H_AT - 1;
	constant V_FULL  : INTEGER := V_AT - 1;
	constant H_HALF1 : INTEGER := 319;
	constant H_HALF2 : INTEGER := 320;
	constant V_HALF1 : INTEGER := 239;
	constant V_HALF2 : INTEGER := 240;
	constant WIDTH_BG  : INTEGER := 95;
	constant HEIGHT_BG : INTEGER := 128;
	constant H_OFST_BG : INTEGER := H_HALF1 - (WIDTH_BG/2);
	constant V_OFST_BG : INTEGER := V_HALF1 - (HEIGHT_BG/2);
	constant SIZE_BG   : INTEGER := WIDTH_BG * HEIGHT_BG;
	
	-- sounds
	constant HOLD_SOUND : INTEGER := 8;
	constant BUMP_SOUND : INTEGER := 200;
	
end game_pkg;
