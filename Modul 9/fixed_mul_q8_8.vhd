library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_q8_8 is
    Port (
        a      : in  STD_LOGIC_VECTOR(15 downto 0);
        b      : in  STD_LOGIC_VECTOR(15 downto 0);
        result : out STD_LOGIC_VECTOR(15 downto 0)
    );
end fixed_mul_q8_8;

architecture Behavioral of fixed_mul_q8_8 is
    signal product : unsigned(31 downto 0);
begin
    product <= unsigned(a) * unsigned(b);
    result <= std_logic_vector(product(23 downto 8));
end Behavioral;
