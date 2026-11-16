----------------------------------------------------------------------------------
-- Jobsheet 11 - Antarmuka VGA
-- File   : color_bar_pattern.vhd
-- Fungsi : Pola batang warna vertikal. Layar aktif (640 piksel) dibagi
--          menjadi 8 zona @ 80 piksel; tiap zona satu warna dasar.
--          Format keluaran rgb = RRRR GGGG BBBB (12-bit).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity color_bar_pattern is
    Port ( h_count : in  integer range 0 to 799;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is
    signal zone : integer range 0 to 9;   -- 0..7 di area aktif, 8..9 di luar
begin

    zone <= h_count / 80;

    process(zone)
    begin
        case zone is
            when 0 => rgb <= x"FFF";   -- Putih
            when 1 => rgb <= x"FF0";   -- Kuning
            when 2 => rgb <= x"0FF";   -- Cyan
            when 3 => rgb <= x"0F0";   -- Hijau
            when 4 => rgb <= x"F0F";   -- Magenta
            when 5 => rgb <= x"F00";   -- Merah
            when 6 => rgb <= x"00F";   -- Biru
            when 7 => rgb <= x"000";   -- Hitam
            when others => rgb <= x"000";
        end case;
    end process;

end Behavioral;
