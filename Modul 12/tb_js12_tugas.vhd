library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench Tugas 1 & 2: tekan 'A', tekan '5', lepas 'A' (tombol lain tidak boleh mematikan LED).
entity tb_js12_tugas is
end tb_js12_tugas;

architecture sim of tb_js12_tugas is
    signal clk     : STD_LOGIC := '0';
    signal ps2_clk : STD_LOGIC := '1';
    signal ps2_dat : STD_LOGIC := '1';
    signal seg     : STD_LOGIC_VECTOR (6 downto 0);
    signal an      : STD_LOGIC_VECTOR (3 downto 0);
    signal dp      : STD_LOGIC;
    signal led     : STD_LOGIC_VECTOR (0 downto 0);

    constant PS2_HALF : time := 30 us;
begin
    clk <= not clk after 5 ns;

    uut : entity work.js12_tugas_top
        generic map (TARGET_KEY => x"1C")
        port map (clk => clk, PS2Clk => ps2_clk, PS2Data => ps2_dat,
                  seg => seg, an => an, dp => dp, led => led);

    stim : process
        procedure send_bit(b : STD_LOGIC) is
        begin
            ps2_dat <= b;  wait for PS2_HALF / 2;
            ps2_clk <= '0'; wait for PS2_HALF;
            ps2_clk <= '1'; wait for PS2_HALF / 2;
        end procedure;

        procedure send_frame(data : STD_LOGIC_VECTOR(7 downto 0)) is
            variable p : STD_LOGIC := '1';
        begin
            for i in 0 to 7 loop p := p xor data(i); end loop;
            send_bit('0');
            for i in 0 to 7 loop send_bit(data(i)); end loop;
            send_bit(p);
            send_bit('1');
            ps2_dat <= '1';
            wait for 100 us;
        end procedure;
    begin
        wait for 1 us;
        assert led(0) = '0' report "FAIL: LED harus padam di awal" severity error;

        send_frame(x"1C");                       -- tekan A
        assert led(0) = '1' report "FAIL: LED harus nyala saat A ditekan" severity error;

        send_frame(x"2E");                       -- tekan 5
        assert led(0) = '1' report "FAIL: LED harus tetap nyala (tombol lain ditekan)" severity error;

        send_frame(x"F0"); send_frame(x"2E");    -- lepas 5
        assert led(0) = '1' report "FAIL: melepas tombol lain tidak boleh mematikan LED" severity error;

        send_frame(x"F0"); send_frame(x"1C");    -- lepas A
        assert led(0) = '0' report "FAIL: LED harus padam saat A dilepas" severity error;

        report "Simulasi Tugas selesai: semua assert lulus bila tidak ada pesan FAIL." severity note;
        wait;
    end process;
end sim;
