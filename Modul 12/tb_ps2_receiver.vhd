library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ps2_receiver is
end tb_ps2_receiver;

architecture sim of tb_ps2_receiver is
    signal clk        : STD_LOGIC := '0';
    signal ps2_clk    : STD_LOGIC := '1';
    signal ps2_data   : STD_LOGIC := '1';
    signal scan_code  : STD_LOGIC_VECTOR (7 downto 0);
    signal data_ready : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;    -- 100 MHz
    constant PS2_HALF   : time := 30 us;    -- periode PS/2 ~60 us (~16,7 kHz)
begin
    uut : entity work.ps2_receiver
        port map (clk => clk, ps2_clk => ps2_clk, ps2_data => ps2_data,
                  scan_code => scan_code, data_ready => data_ready);

    clk <= not clk after CLK_PERIOD / 2;

    stim : process
        -- kirim satu bit: data stabil sebelum tepi turun, disampel pada tepi turun
        procedure send_bit(b : STD_LOGIC) is
        begin
            ps2_data <= b;
            wait for PS2_HALF / 2;
            ps2_clk <= '0';
            wait for PS2_HALF;
            ps2_clk <= '1';
            wait for PS2_HALF / 2;
        end procedure;

        -- kirim satu frame 11-bit; bad_parity = true membalik bit parity (untuk uji error)
        procedure send_frame(data : STD_LOGIC_VECTOR(7 downto 0); bad_parity : boolean := false) is
            variable p : STD_LOGIC := '1';   -- odd parity
        begin
            for i in 0 to 7 loop
                p := p xor data(i);
            end loop;
            if bad_parity then p := not p; end if;
            send_bit('0');                               -- start
            for i in 0 to 7 loop send_bit(data(i)); end loop;  -- data, LSB dulu
            send_bit(p);                                 -- parity
            ps2_data <= '1';                             -- stop (tepi turun terakhir = bit stop)
            wait for PS2_HALF / 2;
            ps2_clk <= '0';
            wait until data_ready = '1' for 2 us;        -- pulsa muncul beberapa siklus clk setelah tepi turun
            wait for PS2_HALF;
            ps2_clk <= '1';
            wait for PS2_HALF / 2;
            ps2_data <= '1';
            wait for 100 us;
        end procedure;

        procedure expect_code(data : STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            send_frame(data);
            assert scan_code = data
                report "scan_code salah" severity error;
        end procedure;
    begin
        wait for 1 us;

        -- Tekan 'A' (make 0x1C), lepas 'A' (0xF0, 0x1C)
        send_frame(x"1C");
        assert scan_code = x"1C" report "FAIL: make code 0x1C" severity error;

        send_frame(x"F0");
        assert scan_code = x"F0" report "FAIL: break prefix 0xF0" severity error;

        send_frame(x"1C");
        assert scan_code = x"1C" report "FAIL: break code 0x1C" severity error;

        -- Tombol lain
        send_frame(x"32");
        assert scan_code = x"32" report "FAIL: make code 0x32 ('B')" severity error;

        -- Frame dengan parity salah harus diabaikan (scan_code tetap 0x32, tidak ada data_ready)
        send_frame(x"21", bad_parity => true);
        assert scan_code = x"32" report "FAIL: frame parity salah tidak boleh diterima" severity error;

        report "Simulasi selesai: semua assert lulus bila tidak ada pesan FAIL di atas." severity note;
        wait;
    end process;

    -- Monitor: data_ready harus berupa pulsa 1 siklus clk
    mon : process
    begin
        wait until rising_edge(data_ready);
        wait for CLK_PERIOD * 1.5;
        assert data_ready = '0' report "FAIL: data_ready lebih dari 1 siklus" severity error;
    end process;
end sim;
