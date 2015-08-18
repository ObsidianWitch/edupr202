library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity cnt_player is 
	generic (
		N	: natural := 10;
		MAX	: natural := 10
	);
	
	Port (
		enclk 	 : in  STD_LOGIC; 
		key_up   : in STD_LOGIC;
		key_down : in STD_LOGIC;
		arst 	 : in  STD_LOGIC;
		clk      : in  STD_LOGIC;
		q        : out STD_LOGIC_VECTOR (N-1 downto 0)
	);
end entity cnt_player;

architecture Behavioral of cnt_player is
	signal valint, valint1, valint2	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal valincr1	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal valdecr1	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal maxedint	: STD_LOGIC;

begin
	q <= valint;
	valint  <= (others => '0') when arst='1' else 
	           valint1 when rising_edge(clk);
			   
	valint1 <= valint2 when enclk='1' else
	           valint;
			   
	valint2 <= valincr1 when key_down='1' and key_up='0' else 
	           valdecr1 when key_up='1' and key_down='0' else
	           valint;
	
	valincr1 <= valint when maxedint='1' else 
	            STD_LOGIC_VECTOR(unsigned(valint) + 1);
	
	valdecr1 <= valint when unsigned(valint) <= 0 else 
	            STD_LOGIC_VECTOR(unsigned(valint) - 1);
	
	maxedint <= '1' when unsigned(valint) = MAX - 1 else 
	            '0';
end architecture Behavioral;