library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_switch_top is
    Port ( sw  : in  STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end led_switch_top;

architecture Behavioral of led_switch_top is
begin
    -- Rangkaian kombinasional: setiap LED mengikuti kondisi switch yang bersesuaian
    led <= sw;
end Behavioral;