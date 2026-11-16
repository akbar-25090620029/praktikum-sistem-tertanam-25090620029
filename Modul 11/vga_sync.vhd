----------------------------------------------------------------------------------
-- Jobsheet 11 - Antarmuka VGA: Video Sync Generator
-- File   : vga_sync.vhd
-- Fungsi : Pembangkit sinkronisasi VGA 640x480 @ 60 Hz (pixel clock 25 MHz)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync is
    Port ( pclk     : in  STD_LOGIC;                 -- pixel clock, 25 MHz
           rst      : in  STD_LOGIC;                 -- reset sinkron, aktif high
           hsync    : out STD_LOGIC;
           vsync    : out STD_LOGIC;
           video_on : out STD_LOGIC;
           h_count  : out integer range 0 to 799;
           v_count  : out integer range 0 to 524 );
end vga_sync;

architecture Behavioral of vga_sync is
    -- Parameter horizontal (piksel)
    constant H_DISPLAY : integer := 640;
    constant H_FPORCH  : integer := 16;
    constant H_SYNC    : integer := 96;
    constant H_TOTAL   : integer := 800;
    -- Parameter vertikal (baris)
    constant V_DISPLAY : integer := 480;
    constant V_FPORCH  : integer := 10;
    constant V_SYNC    : integer := 2;
    constant V_TOTAL   : integer := 525;

    signal hc : integer range 0 to H_TOTAL-1 := 0;
    signal vc : integer range 0 to V_TOTAL-1 := 0;
begin

    -- Pencacah horizontal dan vertikal
    process(pclk)
    begin
        if rising_edge(pclk) then
            if rst = '1' then
                hc <= 0;
                vc <= 0;
            elsif hc = H_TOTAL-1 then
                hc <= 0;
                if vc = V_TOTAL-1 then
                    vc <= 0;
                else
                    vc <= vc + 1;
                end if;
            else
                hc <= hc + 1;
            end if;
        end if;
    end process;

    -- Pulsa sinkronisasi (aktif low untuk 640x480@60Hz)
    hsync <= '0' when (hc >= H_DISPLAY+H_FPORCH) and
                      (hc <  H_DISPLAY+H_FPORCH+H_SYNC) else '1';
    vsync <= '0' when (vc >= V_DISPLAY+V_FPORCH) and
                      (vc <  V_DISPLAY+V_FPORCH+V_SYNC) else '1';

    -- Area tampilan aktif
    video_on <= '1' when (hc < H_DISPLAY) and (vc < V_DISPLAY) else '0';

    h_count <= hc;
    v_count <= vc;

end Behavioral;
