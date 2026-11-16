----------------------------------------------------------------------------------
-- Jobsheet 11 - Testbench vga_sync
-- Memverifikasi lebar dan periode pulsa hsync/vsync sesuai Tabel 11.1
-- serta kebenaran sinyal video_on, menggunakan assert.
-- Jalankan simulasi selama minimal 55 ms (sudah otomatis berhenti sendiri).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_sync_tb is
end vga_sync_tb;

architecture Behavioral of vga_sync_tb is

    component vga_sync
        Port ( pclk     : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               hsync    : out STD_LOGIC;
               vsync    : out STD_LOGIC;
               video_on : out STD_LOGIC;
               h_count  : out integer range 0 to 799;
               v_count  : out integer range 0 to 524 );
    end component;

    constant T_PCLK  : time := 40 ns;       -- 25 MHz
    constant H_SYNC  : integer := 96;
    constant H_TOTAL : integer := 800;
    constant V_SYNC  : integer := 2;
    constant V_TOTAL : integer := 525;

    signal pclk     : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_count  : integer range 0 to 799;
    signal v_count  : integer range 0 to 524;

    signal sim_done : boolean := false;

begin

    uut: vga_sync
        port map ( pclk => pclk, rst => rst,
                   hsync => hsync, vsync => vsync, video_on => video_on,
                   h_count => h_count, v_count => v_count );

    -- Pembangkit clock 25 MHz
    pclk <= not pclk after T_PCLK/2 when not sim_done else pclk;

    -- Stimulus: reset lalu jalankan ~3 frame
    stim: process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 55 ms;
        sim_done <= true;
        report "Simulasi selesai: semua pemeriksaan pewaktuan dijalankan." severity note;
        wait;
    end process;

    -- Cek lebar pulsa dan periode hsync (96 piksel, periode 800 piksel)
    chk_hsync: process
        variable t_fall, t_prev : time := 0 ns;
        variable n : integer := 0;
    begin
        wait until falling_edge(hsync);
        t_fall := now;
        if n > 0 then
            assert (t_fall - t_prev) = H_TOTAL * T_PCLK
                report "Periode hsync salah: " & time'image(t_fall - t_prev)
                severity error;
        end if;
        wait until rising_edge(hsync);
        assert (now - t_fall) = H_SYNC * T_PCLK
            report "Lebar pulsa hsync salah: " & time'image(now - t_fall)
            severity error;
        t_prev := t_fall;
        n := n + 1;
    end process;

    -- Cek lebar pulsa dan periode vsync (2 baris, periode 525 baris)
    chk_vsync: process
        variable t_fall, t_prev : time := 0 ns;
        variable n : integer := 0;
    begin
        wait until falling_edge(vsync);
        t_fall := now;
        if n > 0 then
            assert (t_fall - t_prev) = V_TOTAL * H_TOTAL * T_PCLK
                report "Periode vsync salah: " & time'image(t_fall - t_prev)
                severity error;
        end if;
        wait until rising_edge(vsync);
        assert (now - t_fall) = V_SYNC * H_TOTAL * T_PCLK
            report "Lebar pulsa vsync salah: " & time'image(now - t_fall)
            severity error;
        t_prev := t_fall;
        n := n + 1;
    end process;

    -- Cek video_on hanya aktif di area 640x480
    chk_video_on: process(pclk)
    begin
        if falling_edge(pclk) and rst = '0' then
            if (h_count < 640) and (v_count < 480) then
                assert video_on = '1'
                    report "video_on seharusnya '1' di area aktif" severity error;
            else
                assert video_on = '0'
                    report "video_on seharusnya '0' di luar area aktif" severity error;
            end if;
        end if;
    end process;

end Behavioral;
