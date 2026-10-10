library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detect is
    Port ( clk    : in  STD_LOGIC;
           sig_in : in  STD_LOGIC;
           pulse  : out STD_LOGIC );  -- pulsa 1-siklus saat rising edge terjadi
end edge_detect;

architecture Behavioral of edge_detect is
    signal prev : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            prev <= sig_in;
        end if;
    end process;

    pulse <= sig_in and not prev;  -- '1' hanya pada siklus saat sig_in baru menjadi '1'
end Behavioral;
