library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_tick_1hz is
end tb_tick_1hz;

architecture sim of tb_tick_1hz is
    constant T   : time    := 10 ns;   -- periode clock 100 MHz
    constant DIV : integer := 10;      -- CLK_FREQ_HZ dikecilkan agar simulasi cepat

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '1';
    signal tick : std_logic;
    signal done : boolean   := false;
begin
    uut : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => DIV )
        port map ( clk => clk, rst => rst, tick => tick );

    -- pembangkit clock
    clk_gen : process
    begin
        while not done loop
            clk <= '0'; wait for T/2;
            clk <= '1'; wait for T/2;
        end loop;
        wait;
    end process;

    stim : process
        variable t1, t2 : time;
    begin
        rst <= '1';
        wait for 3*T;
        rst <= '0';

        wait until rising_edge(tick);  t1 := now;
        wait until rising_edge(tick);  t2 := now;

        assert (t2 - t1) = DIV * T
            report "Periode tick salah! Terukur: " & time'image(t2 - t1)
            severity error;
        report "Periode tick terukur = " & time'image(t2 - t1) &
               " (harapan " & time'image(DIV * T) & ")";

        wait for 3*T;
        done <= true;
        wait;
    end process;
end sim;
