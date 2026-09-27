library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg8_en is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en  : in STD_LOGIC; -- enable pemuatan data
           d   : in STD_LOGIC_VECTOR (7 downto 0);
           q   : out STD_LOGIC_VECTOR (7 downto 0) );
end reg8_en;

architecture Behavioral of reg8_en is
    signal q_int : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q_int <= (others => '0');
            elsif en = '1' then
                q_int <= d;
            end if;
            -- jika rst='0' dan en='0': q_int mempertahankan nilai (hold)
        end if;
    end process;
    q <= q_int;
end Behavioral;
