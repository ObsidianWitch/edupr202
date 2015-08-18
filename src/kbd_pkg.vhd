library IEEE;
use IEEE.STD_LOGIC_1164.all;

package kbd_pkg is
	type ARR_KEYS is ARRAY(4 downto 0) of STD_LOGIC_VECTOR(7 downto 0);

	constant PS2_N    : INTEGER := 11;
	
	constant KEY_ENTR : STD_LOGIC_VECTOR(7 downto 0) := x"5A";
	constant KEY_A    : STD_LOGIC_VECTOR(7 downto 0) := x"15";
	constant KEY_Q    : STD_LOGIC_VECTOR(7 downto 0) := x"1C";
	constant KEY_Z    : STD_LOGIC_VECTOR(7 downto 0) := x"1D";
	constant KEY_S    : STD_LOGIC_VECTOR(7 downto 0) := x"1B";
	constant KEY_RLS  : STD_LOGIC_VECTOR(7 downto 0) := x"F0";
	
	constant KEYS : ARR_KEYS := (KEY_ENTR,KEY_A,KEY_Q,KEY_Z,KEY_S);
end kbd_pkg;
