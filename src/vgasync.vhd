library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.vga_pkg.ALL;

entity vgasync is	
	port (
		clk  : in  STD_LOGIC;
		arst : in  STD_LOGIC;
		
		en_px    : out STD_LOGIC;
		h_sync   : out STD_LOGIC;
		v_sync   : out STD_LOGIC;
		video_on : out STD_LOGIC; -- signal active during horizontal and vertical active time
		
		h_q_vga : out STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		v_q_vga : out STD_LOGIC_VECTOR(N_VGA-1 downto 0)
	);
end vgasync;

architecture Behavioral of vgasync is
	signal en_px_int : STD_LOGIC; -- pixel clock enable
	signal h_maxed   : STD_LOGIC; -- active signal when cnt_vga_h has reached his max value
	signal h_q_int   : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	signal v_q_int   : STD_LOGIC_VECTOR(N_VGA-1 downto 0);
	
begin
	-- pixel clock (clock divider)
	px_clk: entity work.clkdiv(Behavioral)
		GENERIC MAP (
			FDIV => CLK_PX
		)
		PORT MAP (
			arst  => arst,
			en    => '1',
			clk   => clk,
			enclk => en_px_int
		);
	
	-- pixel counter
	cnt_vga_h: entity work.cnt(Behavioral)
		GENERIC MAP (
			N   => N_VGA,
			MAX => H_AT + H_FP + H_BP + H_SP
		)
		PORT MAP (
			arst  => arst,
			srst  => '0',
			clk   => clk,
			enclk => en_px_int,
			cnten => '1',	-- pixel counter always enabled
			maxed => h_maxed,
			q     => h_q_int
		);
	
	-- line counter
	cnt_vga_v: entity work.cnt(Behavioral)
		GENERIC MAP (
			N   => N_VGA,
			MAX => V_AT + V_FP + V_BP + V_SP
		)
		PORT MAP (
			arst  => arst,
			srst  => '0',
			clk   => clk,
			enclk => en_px_int,
			cnten => h_maxed, -- line counter enabled when cnt_ball_h max value reached
			maxed => open, -- unconnected output maxed
			q     => v_q_int
		);
		
	-- synchronization
	h_sync <= '0' when 
			h_q_int >= H_AT + H_FP
			and h_q_int < H_AT + H_FP + H_SP
		else '1';
	
	v_sync <= '0' when 
			v_q_int >= V_AT + V_FP
			and v_q_int < V_AT + V_FP + V_SP
		else '1';				  
	
	-- active zone
	video_on <= '1' when 
			h_q_int < H_AT 
			and v_q_int < V_AT
		else '0';
	
	-- counters outputs
	h_q_vga <= h_q_int;
	v_q_vga <= v_q_int;
	
	-- en_px output
	en_px <= en_px_int;
end Behavioral;

