library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.game_pkg.ALL;

entity sounds is	
	port (
		clk  : in  STD_LOGIC;
		arst : in  STD_LOGIC;
		
		hit_ball : in STD_LOGIC;
		
		snd : out STD_LOGIC
	);
end sounds;

architecture Behavioral of sounds is
	signal snd_int  : STD_LOGIC;
	signal snd_int1 : STD_LOGIC;
	
	signal en_bumpsnd : STD_LOGIC;
	signal bumpsnd    : STD_LOGIC;
	signal bumpsnd1   : STD_LOGIC;
	
	signal en_hold    : STD_LOGIC;
	signal hold_hit_ball  : STD_LOGIC;
	signal hold_hit_ball1 : STD_LOGIC;
	
begin
	snd <= snd_int;
	snd_int  <= '0' when arst='1' else snd_int1 when rising_edge(clk);
	snd_int1 <= bumpsnd when hold_hit_ball='1' else '0';
	
	-- one eigth second
	hold_clk: 	entity work.clkdiv(Behavioral)
		GENERIC MAP (
			FDIV => HOLD_SOUND
		)
		PORT MAP (
			arst  => arst,
			en    => hold_hit_ball,
			clk   => clk,
			enclk => en_hold
		);
	
	-- hold bump state for one half second
	hold_hit_ball  <= '0' when arst='1' else hold_hit_ball1 when rising_edge(clk);
	hold_hit_ball1 <= '1' when hit_ball='1' else 
				      '0' when en_hold='1' else hold_hit_ball;
	
	-- bump sound (400 Hz)
	bumpsnd  <= '0' when arst='1' else bumpsnd1 when rising_edge(clk);
	bumpsnd1 <= NOT bumpsnd when en_bumpsnd='1' else bumpsnd;
	
	-- bump sound enable (200 Hz)
	bumpsnd_clk: entity work.clkdiv(Behavioral)
		GENERIC MAP (
			FDIV => BUMP_SOUND
		)
		PORT MAP (
			arst  => arst,
			en    => '1',
			clk   => clk,
			enclk => en_bumpsnd
		);

end Behavioral;