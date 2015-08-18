library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.vga_pkg.ALL;

entity pong is	
	port (
		clk  : in  STD_LOGIC;
		arst : in  STD_LOGIC;
		
		kbd_clk  : in STD_LOGIC;
		kbd_data : in STD_LOGIC;
		
		h_sync : out STD_LOGIC;
		v_sync : out STD_LOGIC;
		
		red   : out STD_LOGIC_VECTOR(2 downto 0);
		green : out STD_LOGIC_VECTOR(2 downto 0);
		blue  : out STD_LOGIC_VECTOR(1 downto 0);
		
		snd : out STD_LOGIC
	);
end pong;

architecture Behavioral of pong is
	-- vga
	signal h_q_vga   : STD_LOGIC_VECTOR(N_VGA-1 downto 0); -- cnt_ball_h output bus
	signal v_q_vga   : STD_LOGIC_VECTOR(N_VGA-1 downto 0); -- cnt_ball_v output bus
	signal video_on  : STD_LOGIC; -- signal active when horizontal and vertical active time
	signal en_px     : STD_LOGIC;
	
	-- asynchronous reset
	signal arst_int : std_logic; -- inverted arst (push button active low)
	
	-- keys
	signal kbd_enter : STD_LOGIC;
	signal key_up1   : STD_LOGIC;
	signal key_down1 : STD_LOGIC;
	signal key_up2   : STD_LOGIC;
	signal key_down2 : STD_LOGIC;
	signal keysout : STD_LOGIC_VECTOR(13 downto 0); -- test
	
begin
	-- vgasync
	vgasync : entity work.vgasync(Behavioral)
		PORT MAP (
			clk      => clk,
			arst     => arst_int,
			h_sync   => h_sync,
			v_sync   => v_sync,
			video_on => video_on,
			h_q_vga  => h_q_vga,
			v_q_vga  => v_q_vga,
			en_px    => en_px
		);
	
	-- game
	game: entity work.game(Behavioral)
		PORT MAP (
			clk       => clk,
			arst      => arst_int,
			h_q_vga   => h_q_vga,
			v_q_vga   => v_q_vga,
			video_on  => video_on,
			en_px     => en_px,
			red       => red,
			green     => green,
			blue      => blue,
			key_up1   => key_up1,
			key_down1 => key_down1,
			key_up2   => key_up2,
			key_down2 => key_down2,
			kbd_enter => kbd_enter,
			snd       => snd
		);
	
	-- keyboard
	kbd: entity work.keyboard(Behavioral) 
		PORT MAP (
			clk       => clk,
			arst      => arst_int,
			kbd_clk   => kbd_clk,
			kbd_data  => kbd_data,
			key_up1   => key_up1,
			key_down1 => key_down1,
			key_up2   => key_up2,
			key_down2 => key_down2,
			kbd_enter => kbd_enter
		);

	-- asynchronous reset
	arst_int <= NOT arst; -- push button active low
end Behavioral;