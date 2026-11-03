library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fixed_mul_q8_8_tb is
end fixed_mul_q8_8_tb;

architecture sim of fixed_mul_q8_8_tb is
    signal a      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal b      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR(15 downto 0);
begin
    uut: entity work.fixed_mul_q8_8
        port map (a => a, b => b, result => result);

    stimulus: process
    begin
        a <= x"0200"; b <= x"0300"; wait for 20 ns;
        assert result = x"0600" report "Error: 2.0 x 3.0" severity error;

        a <= x"0180"; b <= x"0200"; wait for 20 ns;
        assert result = x"0300" report "Error: 1.5 x 2.0" severity error;

        a <= x"0400"; b <= x"0200"; wait for 20 ns;
        assert result = x"0800" report "Error: 4.0 x 2.0" severity error;

        a <= x"0080"; b <= x"0080"; wait for 20 ns;
        assert result = x"0040" report "Error: 0.5 x 0.5" severity error;

        report "Semua pengujian selesai" severity note;
        wait;
    end process;
end sim;
