library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity updown_counter is
    Port ( clk   : in  STD_LOGIC;
           up    : in  STD_LOGIC;    -- pulsa 1-siklus dari edge_detect (btnU)
           down  : in  STD_LOGIC;    -- pulsa 1-siklus dari edge_detect (btnD)
           clr   : in  STD_LOGIC;    -- kembali ke nol (btnC, sudah di-debounce)
           count : out STD_LOGIC_VECTOR (15 downto 0) );
end updown_counter;

architecture Behavioral of updown_counter is
    signal cnt : unsigned (15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                cnt <= (others => '0');
            elsif up = '1' then
                cnt <= cnt + 1;
            elsif down = '1' then
                cnt <= cnt - 1;
            end if;
        end if;
    end process;

    count <= STD_LOGIC_VECTOR(cnt);
end Behavioral;
