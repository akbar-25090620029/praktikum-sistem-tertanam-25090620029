library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux8to1 is
    Port (
        sel : in  STD_LOGIC_VECTOR (2 downto 0); -- Selector 3-bit
        in0 : in  STD_LOGIC_VECTOR (3 downto 0); -- 8 input 4-bit
        in1 : in  STD_LOGIC_VECTOR (3 downto 0);
        in2 : in  STD_LOGIC_VECTOR (3 downto 0);
        in3 : in  STD_LOGIC_VECTOR (3 downto 0);
        in4 : in  STD_LOGIC_VECTOR (3 downto 0);
        in5 : in  STD_LOGIC_VECTOR (3 downto 0);
        in6 : in  STD_LOGIC_VECTOR (3 downto 0);
        in7 : in  STD_LOGIC_VECTOR (3 downto 0);
        y   : out STD_LOGIC_VECTOR (3 downto 0)  -- Output 4-bit
    );
end mux8to1;

architecture Behavioral of mux8to1 is
begin
    process(sel, in0, in1, in2, in3, in4, in5, in6, in7)
    begin
        case sel is
            when "000" => y <= in0;
            when "001" => y <= in1;
            when "010" => y <= in2;
            when "011" => y <= in3;
            when "100" => y <= in4;
            when "101" => y <= in5;
            when "110" => y <= in6;
            when "111" => y <= in7;
            when others => y <= (others => '0');
        end case;
    end process;
end Behavioral;