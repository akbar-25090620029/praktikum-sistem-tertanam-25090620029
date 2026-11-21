library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level Jobsheet 12: tampilkan scan code PS/2 (hex) pada seven-segment.
-- Digit kanan (2 digit) = scan code terbaru, digit kiri (2 digit) = scan code sebelumnya.
-- Contoh: tekan 'A' -> "xx1C"; lepas 'A' -> "F01C" (urutan 0xF0 lalu 0x1C).
entity js12_top is
    Port ( clk      : in  STD_LOGIC;                       -- 100 MHz (W5)
           PS2Clk   : in  STD_LOGIC;                       -- C17
           PS2Data  : in  STD_LOGIC;                       -- B17
           seg      : out STD_LOGIC_VECTOR (6 downto 0);
           an       : out STD_LOGIC_VECTOR (3 downto 0);
           dp       : out STD_LOGIC );
end js12_top;

architecture Behavioral of js12_top is
    signal scan_code  : STD_LOGIC_VECTOR (7 downto 0);
    signal data_ready : STD_LOGIC;
    signal last_code  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal prev_code  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    u_ps2 : entity work.ps2_receiver
        port map (clk => clk, ps2_clk => PS2Clk, ps2_data => PS2Data,
                  scan_code => scan_code, data_ready => data_ready);

    process(clk)
    begin
        if rising_edge(clk) then
            if data_ready = '1' then
                prev_code <= last_code;
                last_code <= scan_code;
            end if;
        end if;
    end process;

    u_seg : entity work.seg7_driver
        port map (clk => clk, data => prev_code & last_code,
                  seg => seg, an => an, dp => dp);
end Behavioral;
