library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_pipe2 is
    Port (
        clk    : in  STD_LOGIC;
        a      : in  STD_LOGIC_VECTOR(15 downto 0);
        b      : in  STD_LOGIC_VECTOR(15 downto 0);
        result : out STD_LOGIC_VECTOR(15 downto 0)
    );
end fixed_mul_pipe2;

architecture Behavioral of fixed_mul_pipe2 is
    signal product_reg : unsigned(31 downto 0) := (others => '0');
    signal result_reg  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            product_reg <= unsigned(a) * unsigned(b);
            result_reg <= std_logic_vector(product_reg(23 downto 8));
        end if;
    end process;

    result <= result_reg;
end Behavioral;
