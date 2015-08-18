library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.game_pkg.ALL;
use work.vga_pkg.ALL;

entity player is 
	Port (
		clk       : in STD_LOGIC;
		arst      : in STD_LOGIC;
		en_player : in STD_LOGIC;
		
		key_up1   : in STD_LOGIC;
		key_down1 : in STD_LOGIC;
		key_up2   : in STD_LOGIC;
		key_down2 : in STD_LOGIC;
		
		q_player1 : out STD_LOGIC_VECTOR(N_VGA-1 downto 0);
		q_player2 : out STD_LOGIC_VECTOR(N_VGA-1 downto 0)
	);
end entity player;

architecture Behavioral of player is
	
begin
	-- player1 paddle position counter
	cnt_player1: entity work.cnt_player(Behavioral)
		GENERIC MAP (
			N   => N_VGA,
			MAX => V_AT - HEIGHT_PLAYER
		)
		PORT MAP (
			enclk    => en_player,
			key_up   => key_up1,
			key_down => key_down1,
			arst     => arst,
			clk      => clk,
			q        => q_player1
		);
		
	-- player2 paddle position counter
	cnt_player2: entity work.cnt_player(Behavioral)
		GENERIC MAP (
			N   => N_VGA,
			MAX => V_AT - HEIGHT_PLAYER
		)
		PORT MAP (
			enclk    => en_player,
			key_up   => key_up2,
			key_down => key_down2,
			arst     => arst,
			clk      => clk,
			q        => q_player2
		);
end architecture Behavioral;