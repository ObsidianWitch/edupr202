library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.vga_pkg.ALL;
use work.game_pkg.ALL;

entity rom_font_addr_selection is
	port (
		clk        : in STD_LOGIC;
		game_state : in STD_LOGIC_VECTOR(1 downto 0);
		
		-- vga
		h_q_vga  : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		v_q_vga  : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		
		-- score
		q_sc1 : in STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
		q_sc2 : in STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
		
		-- display enable for each object
		en_score1_addr  : in STD_LOGIC;
		en_score2_addr  : in STD_LOGIC;
		en_start1_addr  : in STD_LOGIC;
		en_start2_addr  : in STD_LOGIC;
		en_win_addr     : in STD_LOGIC;
		
		-- out
		q_rom_font : out STD_LOGIC_VECTOR(0 TO N_FT_OUT-1) -- invert bit order else inverted images
	);
end rom_font_addr_selection;

architecture Behavioral of rom_font_addr_selection is
	constant BASE_EMPTY_VECT : STD_LOGIC_VECTOR(N_VGA-1 DOWNTO 0) 
		:= std_logic_vector(to_unsigned(BASE_EMPTY, N_VGA));
	
	-- font rom
	signal addr_rom_font : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
	signal addr_score    : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
	signal addr_start1     : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
	signal addr_start1_int : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
	signal addr_start2     : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
	signal addr_start2_int : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
	signal addr_win      : STD_LOGIC_VECTOR(N_FT_ADR-1 DOWNTO 0);
begin
	-- rom font
	rom_font_inst : entity work.rom_font PORT MAP (
		address => addr_rom_font(8 downto 0),
		clock	=> clk,
		q	    => q_rom_font
	);
	
	-- rom font address selection
	addr_rom_font <= -- score
					 addr_score when en_score1_addr='1' or en_score2_addr='1' else
					 -- "press enter" text
					 addr_start1 when en_start1_addr='1' else
					 addr_start2 when en_start2_addr='1' else
					 -- "p1/2wins" text
					 addr_win when en_win_addr='1' else
					 BASE_EMPTY_VECT;
	
	-- score
	addr_score <= BASE_NUMBERS + v_q_vga - V_OFST_SCORE + 
						  (FONT_HEIGHT*conv_integer(q_sc1)) when en_score1_addr='1' else 
						   BASE_NUMBERS + v_q_vga - V_OFST_SCORE +
						  (FONT_HEIGHT*conv_integer(q_sc2)) when en_score2_addr='1' else
				  BASE_EMPTY_VECT;
	
	-- "PRESS" text
	addr_start1 <=   -- P
					 BASE_P + v_q_vga - V_OFST_START1 when
						h_q_vga >= H_OFST_START - 1
						and h_q_vga < H_OFST_START + FONT_WIDTH - 1 else
					 -- R
					 BASE_R + v_q_vga - V_OFST_START1 when
						h_q_vga >= H_OFST_START + FONT_WIDTH + FONT_PADDING - 1
						and h_q_vga < H_OFST_START + (2*FONT_WIDTH) + FONT_PADDING - 1 else
					 -- E
					 BASE_E + v_q_vga - V_OFST_START1 when
						h_q_vga >= H_OFST_START + (2*FONT_WIDTH) + (FONT_PADDING*2) - 1
						and h_q_vga < H_OFST_START + (3*FONT_WIDTH) + (FONT_PADDING*2) - 1 else
					 -- S
					 BASE_S + v_q_vga - V_OFST_START1 when
						h_q_vga >= H_OFST_START + (3*FONT_WIDTH) + (FONT_PADDING*3) - 1
						and h_q_vga < H_OFST_START + (4*FONT_WIDTH) + (FONT_PADDING*3) - 1 else
					 -- S
					 BASE_S + v_q_vga - V_OFST_START1 when 
						h_q_vga >= H_OFST_START + (4*FONT_WIDTH) + (FONT_PADDING*4) - 1 
						and h_q_vga < H_OFST_START + (5*FONT_WIDTH) + (FONT_PADDING*4) - 1 else
					BASE_EMPTY_VECT;
	
	-- "ENTER" text
	addr_start2 <=   -- E
					 BASE_E + v_q_vga - V_OFST_START2 when 
						h_q_vga >= H_OFST_START - 1 
						and h_q_vga < H_OFST_START + FONT_WIDTH - 1 else
					 -- N
					 BASE_N + v_q_vga - V_OFST_START2 when
						h_q_vga >= H_OFST_START + FONT_WIDTH + FONT_PADDING - 1 
						and h_q_vga < H_OFST_START + (2*FONT_WIDTH) + FONT_PADDING - 1 else
					 -- T
					 BASE_T + v_q_vga - V_OFST_START2 when
						h_q_vga >= H_OFST_START + (2*FONT_WIDTH) + (FONT_PADDING*2) - 1 
						and h_q_vga < H_OFST_START + (3*FONT_WIDTH) + (FONT_PADDING*2) - 1 else
					 -- E
					 BASE_E + v_q_vga - V_OFST_START2 when
						h_q_vga >= H_OFST_START + (3*FONT_WIDTH) + (FONT_PADDING*3) - 1 
						and h_q_vga < H_OFST_START + (4*FONT_WIDTH) + (FONT_PADDING*3) - 1 else
					 -- R
					 BASE_R + v_q_vga - V_OFST_START2 when
						h_q_vga >= H_OFST_START + (4*FONT_WIDTH) + (FONT_PADDING*4) - 1 
						and h_q_vga < H_OFST_START + (5*FONT_WIDTH) + (FONT_PADDING*4) - 1 else
					 BASE_EMPTY_VECT;
	
	-- "P1WINS" or "P2WINS" text
	addr_win <=  -- P
				 BASE_P + v_q_vga - V_OFST_WIN when 
					h_q_vga >= H_OFST_WIN - 1 
					and h_q_vga < H_OFST_WIN + FONT_WIDTH - 1 else
				 -- 1
				 BASE_1 + v_q_vga - V_OFST_WIN when
					game_state = WIN1
					and h_q_vga >= H_OFST_WIN + FONT_WIDTH + FONT_PADDING - 1 
					and h_q_vga<H_OFST_WIN + (2*FONT_WIDTH) + FONT_PADDING - 1 else
				 -- 2
				 BASE_2 + v_q_vga - V_OFST_WIN when
					game_state = WIN2
					and h_q_vga >= H_OFST_WIN + FONT_WIDTH + FONT_PADDING - 1 
					and h_q_vga < H_OFST_WIN + (2*FONT_WIDTH) + FONT_PADDING - 1 else
				 -- W
				 BASE_W + v_q_vga - V_OFST_WIN when
					h_q_vga >= H_OFST_WIN + (2*FONT_WIDTH) + (FONT_PADDING*2)- 1 
					and h_q_vga < H_OFST_WIN + (3*FONT_WIDTH) + (FONT_PADDING*2) - 1 else
				 -- I
				 BASE_I + v_q_vga - V_OFST_WIN when
					h_q_vga >= H_OFST_WIN + (3*FONT_WIDTH) + (FONT_PADDING*3) - 1 
					and h_q_vga < H_OFST_WIN + (4*FONT_WIDTH) + (FONT_PADDING*3) - 1 else
				 -- N
				 BASE_N + v_q_vga - V_OFST_WIN when
					h_q_vga >= H_OFST_WIN + (4*FONT_WIDTH) + (FONT_PADDING*4) - 1 
					and h_q_vga < H_OFST_WIN + (5*FONT_WIDTH) + (FONT_PADDING*4) - 1 else
				 -- S
				 BASE_S + v_q_vga - V_OFST_WIN when
					h_q_vga >= H_OFST_WIN + (5*FONT_WIDTH) + (FONT_PADDING*5) - 1 
					and h_q_vga < H_OFST_WIN + (6*FONT_WIDTH) + (FONT_PADDING*5) - 1 else
				 BASE_EMPTY_VECT;
end Behavioral;
