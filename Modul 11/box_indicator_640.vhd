----------------------------------------------------------------------------------
-- Jobsheet 11 - Tugas 2
-- File   : box_indicator_640.vhd
-- Fungsi : Sinyal box_on untuk kotak indikator 40x40 piksel (resolusi 640x480).
--          Posisi horizontal mengikuti sw(3 downto 0):
--            x awal = sw * 40  -> sw=0 di kiri (x=0), sw=15 di kanan (x=600..639)
--          Posisi vertikal tetap di tengah layar (y = 220..259).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity box_indicator_640 is
    Port ( sw      : in  STD_LOGIC_VECTOR(3 downto 0);
           h_count : in  integer range 0 to 799;
           v_count : in  integer range 0 to 524;
           box_on  : out STD_LOGIC );
end box_indicator_640;

architecture Behavioral of box_indicator_640 is
    constant BOX_SIZE : integer := 40;
    constant BOX_Y    : integer := 220;
    signal x0 : integer range 0 to 600;
begin

    x0 <= to_integer(unsigned(sw)) * BOX_SIZE;

    box_on <= '1' when (h_count >= x0)    and (h_count < x0 + BOX_SIZE) and
                       (v_count >= BOX_Y) and (v_count < BOX_Y + BOX_SIZE) else '0';

end Behavioral;
