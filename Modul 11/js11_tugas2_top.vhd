----------------------------------------------------------------------------------
-- Jobsheet 11 - Tugas 2 (top-level)
-- File   : js11_tugas2_top.vhd
-- Fungsi : Papan catur (Tugas 1) + kotak merah yang posisi horizontalnya
--          mengikuti sw(3 downto 0). Resolusi 640x480.
--          Memakai vga_sync.vhd, checkerboard_pattern.vhd, box_indicator_640.vhd,
--          Clocking Wizard clk_wiz_0 (100 MHz -> clk_out1 25 MHz, port reset & locked).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_tugas2_top is
    Port ( clk      : in  STD_LOGIC;
           btnC     : in  STD_LOGIC;
           sw       : in  STD_LOGIC_VECTOR(3 downto 0);
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync    : out STD_LOGIC;
           Vsync    : out STD_LOGIC );
end js11_tugas2_top;

architecture Behavioral of js11_tugas2_top is

    component clk_wiz_0
        port ( clk_out1 : out STD_LOGIC;
               reset    : in  STD_LOGIC;
               locked   : out STD_LOGIC;
               clk_in1  : in  STD_LOGIC );
    end component;

    component vga_sync
        Port ( pclk     : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               hsync    : out STD_LOGIC;
               vsync    : out STD_LOGIC;
               video_on : out STD_LOGIC;
               h_count  : out integer range 0 to 799;
               v_count  : out integer range 0 to 524 );
    end component;

    component checkerboard_pattern
        Port ( h_count : in  integer range 0 to 799;
               v_count : in  integer range 0 to 524;
               rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    component box_indicator_640
        Port ( sw      : in  STD_LOGIC_VECTOR(3 downto 0);
               h_count : in  integer range 0 to 799;
               v_count : in  integer range 0 to 524;
               box_on  : out STD_LOGIC );
    end component;

    signal pclk     : STD_LOGIC;
    signal locked   : STD_LOGIC;
    signal rst_vga  : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_count  : integer range 0 to 799;
    signal v_count  : integer range 0 to 524;
    signal chk_rgb  : STD_LOGIC_VECTOR(11 downto 0);
    signal rgb      : STD_LOGIC_VECTOR(11 downto 0);
    signal box_on   : STD_LOGIC;

begin

    u_clk : clk_wiz_0
        port map ( clk_out1 => pclk,
                   reset    => btnC,
                   locked   => locked,
                   clk_in1  => clk );

    rst_vga <= not locked;

    u_sync : vga_sync
        port map ( pclk     => pclk,
                   rst      => rst_vga,
                   hsync    => Hsync,
                   vsync    => Vsync,
                   video_on => video_on,
                   h_count  => h_count,
                   v_count  => v_count );

    u_checker : checkerboard_pattern
        port map ( h_count => h_count,
                   v_count => v_count,
                   rgb     => chk_rgb );

    u_box : box_indicator_640
        port map ( sw      => sw,
                   h_count => h_count,
                   v_count => v_count,
                   box_on  => box_on );

    -- Kotak merah di atas papan catur
    rgb <= x"F00" when box_on = '1' else chk_rgb;

    -- Paksa hitam di luar area aktif
    vgaRed   <= rgb(11 downto 8) when video_on = '1' else "0000";
    vgaGreen <= rgb(7 downto 4)  when video_on = '1' else "0000";
    vgaBlue  <= rgb(3 downto 0)  when video_on = '1' else "0000";

end Behavioral;
