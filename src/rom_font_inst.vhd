rom_font_inst : entity work.rom_font PORT MAP (
		address	 => address_sig,
		clock	 => clock_sig,
		q	 => q_sig
	);
