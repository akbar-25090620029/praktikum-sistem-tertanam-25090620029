library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dff_sync_reset_tb is
end dff_sync_reset_tb;

architecture sim of dff_sync_reset_tb is

    component dff_sync_reset
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               d   : in STD_LOGIC;
               q   : out STD_LOGIC );
    end component;

    signal clk_tb : STD_LOGIC := '0';
    signal rst_tb : STD_LOGIC := '0';
    signal d_tb   : STD_LOGIC := '0';
    signal q_tb   : STD_LOGIC;

    constant CLK_PERIOD : time := 20 ns; -- sesuai instruksi jobsheet

begin
    -- Instansiasi DUT (Device Under Test)
    UUT: dff_sync_reset
        port map ( clk => clk_tb,
                    rst => rst_tb,
                    d   => d_tb,
                    q   => q_tb );

    -- Pembangkit clock periodik
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus d dan rst
    stim_process : process
    begin
        -- 1) reset aktif, q harus jatuh ke 0
        rst_tb <= '1'; d_tb <= '0';
        wait for CLK_PERIOD*2;

        -- 2) reset lepas, d=1 -> q harus ikut jadi 1 SETELAH tepi naik berikutnya
        rst_tb <= '0'; d_tb <= '1';
        wait for CLK_PERIOD;

        -- 3) d kembali 0
        d_tb <= '0';
        wait for CLK_PERIOD;

        -- 4) d diubah DI TENGAH periode clock (bukan tepat di tepi)
        --    -> membuktikan q hanya menyalin nilai d pada saat tepi naik terjadi,
        --       bukan seketika saat d berubah
        d_tb <= '1';
        wait for CLK_PERIOD/4;
        d_tb <= '0';
        wait for CLK_PERIOD;

        -- 5) reset lagi
        rst_tb <= '1';
        wait for CLK_PERIOD*2;

        rst_tb <= '0';
        wait;
    end process;

end sim;
