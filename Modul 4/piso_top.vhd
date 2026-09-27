library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_top is
    Port ( clk  : in  STD_LOGIC;                      -- pin W5, 100 MHz
           sw   : in  STD_LOGIC_VECTOR (7 downto 0);   -- data paralel -> din
           btnC : in  STD_LOGIC;                       -- tombol tengah -> load
           led  : out STD_LOGIC_VECTOR (0 downto 0) ); -- sout -> led(0)
end piso_top;

architecture Behavioral of piso_top is
    component piso_8bit
        Port ( clk  : in STD_LOGIC;
               load : in STD_LOGIC;
               din  : in STD_LOGIC_VECTOR (7 downto 0);
               sout : out STD_LOGIC );
    end component;
begin
    U1: piso_8bit
        port map ( clk => clk, load => btnC, din => sw, sout => led(0) );
end Behavioral;
