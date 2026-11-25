library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level Tugas Jobsheet 12 (Tugas 1 dan 2).
--  * Tugas 1: scan code -> ASCII (lihat ps2_ascii.vhd).
--             Seven-segment: 2 digit kiri = scan code tombol terakhir ditekan,
--                            2 digit kanan = kode ASCII (hex) tombol tersebut.
--             Contoh: tekan 'A' -> "1C41", tekan '5' -> "2E35".
--  * Tugas 2: deteksi break code (0xF0 + scan code).
--             led(0) menyala selama tombol TARGET_KEY ditekan, padam saat dilepas.
entity js12_tugas_top is
    Generic ( TARGET_KEY : STD_LOGIC_VECTOR (7 downto 0) := x"1C" );  -- 0x1C = tombol 'A'
    Port ( clk      : in  STD_LOGIC;                       -- 100 MHz (W5)
           PS2Clk   : in  STD_LOGIC;                       -- C17
           PS2Data  : in  STD_LOGIC;                       -- B17
           seg      : out STD_LOGIC_VECTOR (6 downto 0);
           an       : out STD_LOGIC_VECTOR (3 downto 0);
           dp       : out STD_LOGIC;
           led      : out STD_LOGIC_VECTOR (0 downto 0) );  -- led(0) = U16
end js12_tugas_top;

architecture Behavioral of js12_tugas_top is
    signal scan_code  : STD_LOGIC_VECTOR (7 downto 0);
    signal data_ready : STD_LOGIC;
    signal ascii      : STD_LOGIC_VECTOR (7 downto 0);

    signal break_flag : STD_LOGIC := '0';                       -- '1' = byte berikutnya adalah break code
    signal key_down   : STD_LOGIC := '0';                       -- status tombol TARGET_KEY
    signal last_make  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal last_ascii : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    u_ps2 : entity work.ps2_receiver
        port map (clk => clk, ps2_clk => PS2Clk, ps2_data => PS2Data,
                  scan_code => scan_code, data_ready => data_ready);

    -- Tugas 1: lookup scan code -> ASCII
    u_ascii : entity work.ps2_ascii
        port map (scan => scan_code, ascii => ascii);

    -- Tugas 2: pembeda make code vs break code
    process(clk)
    begin
        if rising_edge(clk) then
            if data_ready = '1' then
                if scan_code = x"F0" then
                    break_flag <= '1';                  -- prefix break: tombol akan dilepas
                elsif scan_code = x"E0" then
                    null;                               -- prefix tombol extended: abaikan, flag tidak berubah
                else
                    if break_flag = '1' then
                        -- break code: tombol dilepas
                        if scan_code = TARGET_KEY then
                            key_down <= '0';
                        end if;
                        break_flag <= '0';
                    else
                        -- make code: tombol ditekan
                        if scan_code = TARGET_KEY then
                            key_down <= '1';
                        end if;
                        last_make  <= scan_code;
                        last_ascii <= ascii;
                    end if;
                end if;
            end if;
        end if;
    end process;

    led(0) <= key_down;

    u_seg : entity work.seg7_driver
        port map (clk => clk, data => last_make & last_ascii,
                  seg => seg, an => an, dp => dp);
end Behavioral;
