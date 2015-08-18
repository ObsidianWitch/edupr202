library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity cnt is 
	generic (
		N	: natural := 4;
		MAX	: natural := 10
	);
	
	Port (
		enclk 	: in  STD_LOGIC; -- clock enable (from clock divider)
		cnten 	: in  STD_LOGIC; -- count enable
		arst 	: in  STD_LOGIC;
		srst    : in  STD_LOGIC;
		clk 	: in  STD_LOGIC;
		q 		: out STD_LOGIC_VECTOR (N-1 downto 0);
		maxed 	: out STD_LOGIC -- high when MAX-1 value reached
	);
end entity cnt;

architecture Behavioral of cnt is
	signal valint, valint1, valint2, valint3, valint4 : STD_LOGIC_VECTOR(N-1 downto 0);
	signal maxedint	: STD_LOGIC;

begin
	q <= valint;
	valint  <= (others => '0') when arst='1' else 
	           valint1 when rising_edge(clk); 
			  
	valint1 <= valint2 when enclk='1' or srst='1' else 
	           valint;
	
	valint2 <= valint3 when srst='0' else
	           (others => '0');
			   
	valint3 <= valint4 when cnten='1' else 
	           valint;
			   
	valint4 <= (others => '0') when maxedint='1' else 
	           STD_LOGIC_VECTOR(unsigned(valint) + 1);
	
	maxed    <= maxedint;
	maxedint <= '1' when unsigned(valint) = MAX - 1 else '0';
end architecture Behavioral;