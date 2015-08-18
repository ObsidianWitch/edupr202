library IEEE;
use IEEE.std_logic_1164.ALL;
use work.kbd_pkg.ALL;

entity keyboard is
	port (
		clk  : in STD_LOGIC;
		arst : in STD_LOGIC;

		kbd_clk  : in STD_LOGIC;
		kbd_data : in STD_LOGIC;

		key_up1   : out STD_LOGIC;
		key_down1 : out STD_LOGIC;
		key_up2   : out STD_LOGIC;
		key_down2 : out STD_LOGIC;
		kbd_enter : out STD_LOGIC
	);
end keyboard;

architecture Behavioral of keyboard is
	signal old_data : STD_LOGIC_VECTOR(7 downto 0);
	signal data     : STD_LOGIC_VECTOR(7 downto 0);
	signal data1    : STD_LOGIC_VECTOR(7 downto 0);

	signal data_shift  : STD_LOGIC_VECTOR(PS2_N-1 downto 0);
	signal data_shift1 : STD_LOGIC_VECTOR(PS2_N-1 downto 0);
	signal last_bit    : STD_LOGIC;

	signal kbd_en      : STD_LOGIC;
	signal kbd_clk_new : STD_LOGIC;
	signal kbd_clk_old : STD_LOGIC;

	signal key_pressed : STD_LOGIC;
	signal key_select  : STD_LOGIC_VECTOR(4 downto 0);
	signal key_select1 : STD_LOGIC_VECTOR(4 downto 0);
	signal key_select2 : STD_LOGIC_VECTOR(4 downto 0);	
  
begin
	-- clock enable
	kbd_clk_new <= '1' when arst='1' else kbd_clk when rising_edge(clk);
	kbd_clk_old <= '1' when arst='1' else kbd_clk_new when rising_edge(clk);
	kbd_en <= (NOT kbd_clk_new) AND kbd_clk_old; 
	
	-- data
	data <= (others => '0') when arst='1' else data1 when rising_edge(clk);
	data1 <= data_shift(8 downto 1) when last_bit='1' else data;
	
	-- data shift
	data_shift  <= (others => '1') when arst='1' else data_shift1 when rising_edge(clk);
	data_shift1 <= (others => '1') when last_bit='1' else
					  kbd_data & data_shift(PS2_N-1 downto 1) when kbd_en='1' else
					  data_shift;

	last_bit <= NOT data_shift(0);
	
	-- keys
	key_pressed <= '0' when arst='1' else last_bit when rising_edge(clk);
	
	-- control
	old_data <= (others => '0') when arst='1' else data when rising_edge(clk);
	
	key_select <= (others => '0') when arst='1' else key_select1 when rising_edge(clk);
	key_select1 <= key_select2 when key_pressed='1' else key_select;
					  
	key_select_loop: FOR i IN 0 TO 4 GENERATE
		key_select2(i) <= '0' when data=KEYS(i) and old_data=KEY_RLS else
						  '1' when data=KEYS(i) else
						  key_select(i);
	END GENERATE;
	
	kbd_enter <= key_select(4);
	key_up1   <= key_select(3);
	key_down1 <= key_select(2);
	key_up2   <= key_select(1);
	key_down2 <= key_select(0);
	
end Behavioral;