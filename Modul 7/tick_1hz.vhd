library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tick_1hz is
    Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : out STD_LOGIC );  -- pulsa 1 siklus, setiap 1 detik
end tick_1hz;

architecture Behavioral of tick_1hz is
    signal cnt : integer range 0 to CLK_FREQ_HZ-1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt  <= 0;
                tick <= '0';
            elsif cnt = CLK_FREQ_HZ-1 then
                cnt  <= 0;
                tick <= '1';
            else
                cnt  <= cnt + 1;
                tick <= '0';
            end if;
        end if;
    end process;
end Behavioral;
