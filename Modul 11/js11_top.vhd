----------------------------------------------------------------------------------
-- Jobsheet 11 - Antarmuka VGA: Video Sync Generator
-- File   : js11_top.vhd
-- Fungsi : Top-level. Clocking Wizard (100 MHz -> 25 MHz) + vga_sync +
--          color_bar_pattern. Keluaran RGB dipaksa hitam di luar area aktif.
--
-- Catatan: Clocking Wizard dibuat dengan nama komponen "clk_wiz_0",
--          input clk_in1 = 100 MHz, output clk_out1 = 25 MHz, dengan port
--          "reset" (aktif high) dan "locked" diaktifkan.
--          Jika nama/port IP Anda berbeda, sesuaikan deklarasi component di bawah.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_top is
    Port ( clk      : in  STD_LOGIC;                        -- 100 MHz onboard (W5)
           btnC     : in  STD_LOGIC;                        -- reset (tombol tengah)
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync    : out STD_LOGIC;
           Vsync    : out STD_LOGIC );
end js11_top;

architecture Behavioral of js11_top is

    -- IP Clocking Wizard (hasil generate dari IP Catalog)
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

    component color_bar_pattern
        Port ( h_count : in  integer range 0 to 799;
               rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    signal pclk      : STD_LOGIC;
    signal locked    : STD_LOGIC;
    signal rst_vga   : STD_LOGIC;
    signal video_on  : STD_LOGIC;
    signal h_count   : integer range 0 to 799;
    signal v_count   : integer range 0 to 524;
    signal rgb       : STD_LOGIC_VECTOR(11 downto 0);

begin

    -- Pixel clock 25 MHz
    u_clk : clk_wiz_0
        port map ( clk_out1 => pclk,
                   reset    => btnC,
                   locked   => locked,
                   clk_in1  => clk );

    -- Tahan counter VGA dalam kondisi reset sampai clock stabil (locked = '1')
    rst_vga <= not locked;

    u_sync : vga_sync
        port map ( pclk     => pclk,
                   rst      => rst_vga,
                   hsync    => Hsync,
                   vsync    => Vsync,
                   video_on => video_on,
                   h_count  => h_count,
                   v_count  => v_count );

    u_pattern : color_bar_pattern
        port map ( h_count => h_count,
                   rgb     => rgb );

    -- Paksa hitam di luar area aktif (rgb x video_on)
    vgaRed   <= rgb(11 downto 8) when video_on = '1' else "0000";
    vgaGreen <= rgb(7 downto 4)  when video_on = '1' else "0000";
    vgaBlue  <= rgb(3 downto 0)  when video_on = '1' else "0000";

end Behavioral;
