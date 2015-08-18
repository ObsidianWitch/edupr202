library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity clkdiv is 
	generic (
		FDIV : natural := 10000000
	);
		
    Port (
		arst : in  STD_LOGIC;
		en   : in STD_LOGIC;
        clk  : in  STD_LOGIC;
		
		enclk : out STD_LOGIC
	);
end entity clkdiv;

architecture Behavioral of clkdiv is
signal valint, valint1, valint2 : STD_LOGIC_VECTOR (25 downto 0);
signal enclkint : STD_LOGIC;

constant FSYS : natural := 50000000; 
constant MAX  : natural := (FSYS/FDIV) - 1;

begin
	valint  <= (others=> '0') when arst='1' else 
	           valint1 when rising_edge(clk); 
	
	valint1 <= valint2 when en='1' else valint;
	
	valint2 <= (others=> '0') when enclkint='1' else 
	           STD_LOGIC_VECTOR(unsigned(valint)+1);
			   
	enclkint  <= '1' when unsigned(valint) = MAX else '0';
	enclk   <= enclkint;
end architecture Behavioral;