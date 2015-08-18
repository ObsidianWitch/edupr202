library IEEE;
use IEEE.STD_LOGIC_1164.all;

package vga_pkg is
	constant N_VGA  : INTEGER := 10; -- number of bits necessary for cnt output bus
	constant CLK_PX : INTEGER := 25000000; -- pixel clock
	
	constant H_AT : INTEGER := 640;	-- horizontal active time
	constant H_FP : INTEGER := 16;	-- horizontal front porch
	constant H_BP : INTEGER := 48;	-- horizontal back porch
	constant H_SP : INTEGER := 96;	-- horizontal sync pulse
	
	constant V_AT : INTEGER := 480;	-- vertical active time
	constant V_FP : INTEGER := 10;	-- vertical front porch
	constant V_BP : INTEGER := 33;	-- vertical back porch
	constant V_SP : INTEGER := 2;	-- vertical sync pulse
	
	-- Colors
	constant WHITE   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111";
	constant BLACK   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	constant GRAY    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001001";
	constant RED1    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11100000";
	constant GREEN1  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011100";
	constant BLUE1   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000011";
	constant BLUE2   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00100101";
	constant PURPLE  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11100011";
end vga_pkg;
