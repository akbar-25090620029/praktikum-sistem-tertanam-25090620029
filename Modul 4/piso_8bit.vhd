library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_8bit is
    Port ( clk  : in  STD_LOGIC;
           load : in  STD_LOGIC;                     -- '1' = muat paralel
           din  : in  STD_LOGIC_VECTOR (7 downto 0);  -- data paralel masuk
           sout : out STD_LOGIC );                    -- keluaran serial
end piso_8bit;

architecture Behavioral of piso_8bit is
    signal shreg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                shreg <= din;                     -- muat paralel
            else
                shreg <= shreg(6 downto 0) & '0';  -- geser kiri, isi '0' di LSB
            end if;
        end if;
    end process;

    sout <= shreg(7); -- bit paling kiri (MSB) keluar lebih dulu
end Behavioral;