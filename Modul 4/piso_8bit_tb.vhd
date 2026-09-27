library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_8bit_tb is
end piso_8bit_tb;

architecture sim of piso_8bit_tb is

    component piso_8bit
        Port ( clk  : in STD_LOGIC;
               load : in STD_LOGIC;
               din  : in STD_LOGIC_VECTOR (7 downto 0);
               sout : out STD_LOGIC );
    end component;

    signal clk_tb  : STD_LOGIC := '0';
    signal load_tb : STD_LOGIC := '0';
    signal din_tb  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal sout_tb : STD_LOGIC;

    constant CLK_PERIOD : time := 20 ns;

begin
    UUT: piso_8bit
        port map ( clk => clk_tb, load => load_tb, din => din_tb, sout => sout_tb );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_process : process
    begin
        -- muat pola contoh 1011_0010 secara paralel
        din_tb  <= "10110010";
        load_tb <= '1';
        wait for CLK_PERIOD;   -- satu tepi clock cukup untuk meng-load

        load_tb <= '0';
        -- 8 tepi clock berikutnya: harus keluar berurutan 1,0,1,1,0,0,1,0 di sout
        wait for CLK_PERIOD*8;

        -- putaran tambahan: sout harus tetap '0' (isian geseran) setelah 8 bit habis
        wait for CLK_PERIOD*2;

        wait;
    end process;

end sim;
