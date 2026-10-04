library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture sim of tb_debounce is
    signal clk_tb     : STD_LOGIC := '0';
    signal btn_in_tb  : STD_LOGIC := '0';
    signal btn_out_tb : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz
begin
    -- Generic diperkecil khusus simulasi:
    -- LIMIT = (100_000/1000)*1 = 100 siklus = 1 us (bukan 10 ms), supaya simulasi singkat
    UUT: entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000, STABLE_MS => 1 )
        port map ( clk => clk_tb, btn_in => btn_in_tb, btn_out => btn_out_tb );

    clk_process : process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD/2;
        clk_tb <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_process : process
    begin
        btn_in_tb <= '0';
        wait for 500 ns;

        -- Tombol DITEKAN: bouncing 4x (pantulan 100 ns, jauh < 1 us)
        for i in 1 to 4 loop
            btn_in_tb <= '1'; wait for 100 ns;
            btn_in_tb <= '0'; wait for 150 ns;
        end loop;
        btn_in_tb <= '1';         -- akhirnya stabil di '1'
        wait for 3 us;

        -- Tombol DILEPAS: bouncing 4x
        for i in 1 to 4 loop
            btn_in_tb <= '0'; wait for 100 ns;
            btn_in_tb <= '1'; wait for 150 ns;
        end loop;
        btn_in_tb <= '0';         -- akhirnya stabil di '0'
        wait for 3 us;

        wait;
    end process;
end sim;
