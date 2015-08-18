library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.vga_pkg.ALL;
use work.game_pkg.ALL;
use work.reduce_pack.ALL;

entity game_gen is
	port (
		clk   : in STD_LOGIC;
		arst  : in STD_LOGIC;
		
		-- vga
		video_on : in STD_LOGIC;
		h_q_vga  : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		v_q_vga  : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		en_px    : in STD_LOGIC;
		
		-- colors
		red   : out STD_LOGIC_VECTOR(2 downto 0);
		green : out STD_LOGIC_VECTOR(2 downto 0);
		blue  : out STD_LOGIC_VECTOR(1 downto 0);
		
		-- state
		game_state : in STD_LOGIC_VECTOR(1 downto 0);
		
		-- score
		q_sc1 : in STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
		q_sc2 : in STD_LOGIC_VECTOR(N_SCORE-1 downto 0);
		
		-- players
		q_player1 : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		q_player2 : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		
		-- ball
		v_q_ball : in STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		h_q_ball : in STD_LOGIC_VECTOR(N_VGA-1 downto 0)
	);
end game_gen;

architecture Behavioral of game_gen is
	-- colors generation for each object
	signal color_gen  : STD_LOGIC_VECTOR(7 downto 0);
	signal player_gen : STD_LOGIC_VECTOR(7 downto 0);
	signal bg_gen     : STD_LOGIC_VECTOR(7 downto 0);
	signal ball_gen   : STD_LOGIC_VECTOR(7 downto 0);
	signal score1_gen : STD_LOGIC_VECTOR(7 downto 0);
	signal score2_gen : STD_LOGIC_VECTOR(7 downto 0);
	signal start_gen  : STD_LOGIC_VECTOR(7 downto 0);
	signal win_gen    : STD_LOGIC_VECTOR(7 downto 0);
	
	-- display enable for each object
	signal sel_obj        : STD_LOGIC_VECTOR(2 downto 0);
	signal sel_obj1       : STD_LOGIC_VECTOR(2 downto 0);
	signal en_player1_gen : STD_LOGIC;
	signal en_player2_gen : STD_LOGIC;
	signal en_ball_gen    : STD_LOGIC;
	signal en_score1_gen  : STD_LOGIC;
	signal en_score2_gen  : STD_LOGIC;
	signal en_start_gen   : STD_LOGIC;
	signal en_win_gen     : STD_LOGIC;
	
	-- font rom
	signal en_score1_addr : STD_LOGIC;
	signal en_score2_addr : STD_LOGIC;
	signal en_start1_addr : STD_LOGIC;
	signal en_start2_addr : STD_LOGIC;
	signal en_win_addr    : STD_LOGIC;
	signal q_rom_font  : STD_LOGIC_VECTOR(0 TO N_FT_OUT - 1);
	signal cnt_font_start_en : STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal cnt_font_win_en : STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	-- background rom
	signal q_rom_bg : STD_LOGIC_VECTOR(7 downto 0);
	signal cnt_rom_bg_en : STD_LOGIC;
	signal q_cnt_rom_bg : STD_LOGIC_VECTOR(N_BG_ADR-1 downto 0);
	
begin
	-- generation
		-- colors generation
		red   <= color_gen(7 downto 5);
		green <= color_gen(4 downto 2);
		blue  <= color_gen(1 downto 0);
		
		-- object selection
		with sel_obj select
		color_gen <= win_gen    when "111",
					 start_gen  when "110",
					 ball_gen   when "101",
					 player_gen when "100",
					 score2_gen when "011",
					 score1_gen when "010",
					 bg_gen     when "001",
					 BLACK      when others;
		
		sel_obj <= sel_obj1 when video_on = '1' else "000";
		sel_obj1 <= "111" when en_win_gen='1' else
					"110" when en_start_gen='1' else
					"101" when en_ball_gen='1' else  
					"100" when en_player1_gen='1' or en_player2_gen='1' else
					"011" when en_score2_gen='1' else
					"010" when en_score1_gen='1' else
					"001"; -- background
		
		-- background generation
		bg_gen <= WHITE when 
				(h_q_vga >= H_HALF1 and h_q_vga <= H_HALF2)
				or (h_q_vga <= H_FULL and v_q_vga = ZERO)
				or (h_q_vga <= H_FULL and v_q_vga = V_FULL)
				or (h_q_vga = ZERO and v_q_vga <= V_FULL)
				or (h_q_vga = H_FULL and v_q_vga <= V_FULL)
			else q_rom_bg when -- background sprite
				h_q_vga >= H_OFST_BG and h_q_vga < H_OFST_BG + WIDTH_BG
				and v_q_vga >= V_OFST_BG and v_q_vga < V_OFST_BG + HEIGHT_BG
			else BLUE2;
		
		rom_bg: entity work.rom_bg
			PORT MAP (
				address => q_cnt_rom_bg,
				clock   => clk,
				q       => q_rom_bg
			);
		
		cnt_rom_bg: entity work.cnt(Behavioral)
			GENERIC MAP (
				N   => N_BG_ADR,
				MAX => SIZE_BG
			)
			PORT MAP (
				enclk => en_px,
				cnten => cnt_rom_bg_en,
				arst  => arst,
				srst  => '0',
				clk   => clk,
				q     => q_cnt_rom_bg,
				maxed => open
			);
		
		cnt_rom_bg_en <= '1' when 
				h_q_vga >= H_OFST_BG - 1 and h_q_vga < H_OFST_BG + WIDTH_BG - 1
				and v_q_vga >= V_OFST_BG - 1 and v_q_vga < V_OFST_BG + HEIGHT_BG - 1
			else '0';
		
		-- player generation
		en_player1_gen <= '1' when 
				h_q_vga >= OFST_PLAYER
				and h_q_vga < OFST_PLAYER + WIDTH_PLAYER 
				and v_q_vga >= q_player1 
				and v_q_vga < q_player1 + HEIGHT_PLAYER
			else '0';
			
		en_player2_gen <= '1' when 
				h_q_vga >= H_AT - OFST_PLAYER - WIDTH_PLAYER 
				and h_q_vga < H_AT - OFST_PLAYER
				and v_q_vga >= q_player2
				and v_q_vga < q_player2 + HEIGHT_PLAYER
			else '0';
			
		player_gen <= WHITE;
		
		-- ball generation
		en_ball_gen <=  '1' when
				h_q_vga >= h_q_ball 
				and h_q_vga < h_q_ball + SIZE_BALL
				and v_q_vga >= v_q_ball
				and v_q_vga < v_q_ball + SIZE_BALL
			else '0';
		
		ball_gen <= RED1;
		
		-- scores generation
		en_score1_gen <= '1' when
				h_q_vga >= H_OFST_SCORE1
				and h_q_vga < H_OFST_SCORE1 + FONT_HEIGHT
				and v_q_vga >= V_OFST_SCORE
				and v_q_vga < V_OFST_SCORE + FONT_WIDTH
			else '0';
		
		en_score2_gen <= '1' when
				h_q_vga >= H_OFST_SCORE2
				and h_q_vga < H_OFST_SCORE2 + FONT_HEIGHT
				and v_q_vga >= V_OFST_SCORE
				and v_q_vga < V_OFST_SCORE + FONT_WIDTH
			else '0';
		
		en_score1_addr <= '1' when
				h_q_vga >= H_OFST_SCORE1 - 1
				and h_q_vga < H_OFST_SCORE1 + FONT_HEIGHT - 1
				and v_q_vga >= V_OFST_SCORE
				and v_q_vga < V_OFST_SCORE + FONT_WIDTH
			else '0';
		
		en_score2_addr <= '1' when
				h_q_vga >= H_OFST_SCORE2 - 1
				and h_q_vga < H_OFST_SCORE2 + FONT_HEIGHT - 1
				and v_q_vga >= V_OFST_SCORE
				and v_q_vga < V_OFST_SCORE + FONT_WIDTH
			else '0';
			
		score1_gen <= WHITE when q_rom_font(conv_integer(h_q_vga) - H_OFST_SCORE1) = '0' 
				 else bg_gen;
		score2_gen <= WHITE when q_rom_font(conv_integer(h_q_vga) - H_OFST_SCORE2) = '0'
				 else bg_gen;
		
		-- start screen generation
		en_start_gen <= '1' when
				game_state=START
				and or_reduce(cnt_font_start_en)='1'
				and 
				((v_q_vga >= V_OFST_START1
				and v_q_vga < V_OFST_START1 + FONT_HEIGHT)
				or
				(v_q_vga >= V_OFST_START2 - 1
				and v_q_vga < V_OFST_START2 + FONT_HEIGHT))
			else '0';
			
		en_start1_addr <= '1' when
				game_state=START
				and h_q_vga >= H_OFST_START - 1
				and h_q_vga < H_OFST_START + WIDTH_START - 1
				and v_q_vga >= V_OFST_START1
				and v_q_vga < V_OFST_START1 + FONT_HEIGHT
			else '0';
		
		en_start2_addr <= '1' when
				game_state=START
				and h_q_vga >= H_OFST_START - 1
				and h_q_vga < H_OFST_START + WIDTH_START - 1
				and v_q_vga >= V_OFST_START2
				and v_q_vga < V_OFST_START2 + FONT_HEIGHT
			else '0';
		
		start_gen <= WHITE when q_rom_font(conv_integer(h_q_vga - H_OFST_START)) = '0' 
			else bg_gen;
				
		-- win screen generation
		en_win_gen <= '1' when -- "P1wins" / "P2wins"
				(game_state=WIN1 or game_state=WIN2)
				and or_reduce(cnt_font_win_en)='1'
				and v_q_vga >= V_OFST_WIN
				and v_q_vga < V_OFST_WIN + FONT_HEIGHT
			else '0';
		
		en_win_addr <= '1' when
				(game_state=WIN1 or game_state=WIN2)
				and h_q_vga >= H_OFST_WIN - 1
				and h_q_vga < H_OFST_WIN + WIDTH_WIN - 1
				and v_q_vga >= V_OFST_WIN
				and v_q_vga < V_OFST_WIN + FONT_HEIGHT
			else '0';
			
		win_gen <= WHITE when q_rom_font(conv_integer(h_q_vga - H_OFST_WIN)) = '0' 
			else bg_gen;
	
	-- font
		-- rom font address selection
		rom_font_addr_selection : entity work.rom_font_addr_selection PORT MAP (
			clk      => clk,
			h_q_vga  => h_q_vga,
			v_q_vga  => v_q_vga,
			q_sc1    => q_sc1,
			q_sc2    => q_sc2,
			en_score1_addr  => en_score1_addr,
			en_score2_addr  => en_score2_addr,
			en_start1_addr  => en_start1_addr,
			en_start2_addr  => en_start2_addr,
			en_win_addr     => en_win_addr,
			game_state     => game_state,
			q_rom_font     => q_rom_font
		);
		
		-- TODO rename
		cnt_font_start_loop : FOR i IN 0 TO 4 GENERATE
			cnt_font_start_en(i) <= '1' when
					h_q_vga >= H_OFST_START + (FONT_WIDTH*i) + (FONT_PADDING*i)
					and h_q_vga < H_OFST_START + (FONT_WIDTH*(i+1)) + (FONT_PADDING*i)
				else '0';
		END GENERATE;
		
		cnt_font_win_loop : FOR i IN 0 TO 5 GENERATE
			cnt_font_win_en(i) <= '1' when
					h_q_vga >= H_OFST_WIN + (FONT_WIDTH*i) + (FONT_PADDING*i)
					and h_q_vga < H_OFST_WIN + (FONT_WIDTH*(i+1)) + (FONT_PADDING*i)
				else '0';
		END GENERATE;
end Behavioral;
