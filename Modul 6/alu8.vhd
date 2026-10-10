library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU 8-bit, hasil 16-bit (agar perkalian 8x8 tidak terpotong).
-- Operasi kombinasional: tambah, kurang, kali.
entity alu8 is
    Port ( a      : in  STD_LOGIC_VECTOR (7 downto 0);
           b      : in  STD_LOGIC_VECTOR (7 downto 0);
           op_sel : in  STD_LOGIC_VECTOR (1 downto 0);  -- "00"=tambah "01"=kurang "10"=kali
           result : out STD_LOGIC_VECTOR (15 downto 0) );
end alu8;

architecture Behavioral of alu8 is
begin
    process(a, b, op_sel)
        variable a_u, b_u : unsigned(7 downto 0);
        variable r_u      : unsigned(15 downto 0);
    begin
        a_u := unsigned(a);
        b_u := unsigned(b);
        case op_sel is
            when "00" =>
                r_u := resize(a_u, 16) + resize(b_u, 16);   -- tambah (tanpa overflow)
            when "01" =>
                r_u := resize(a_u, 16) - resize(b_u, 16);   -- kurang (negatif = two's complement 16-bit)
            when "10" =>
                r_u := a_u * b_u;                           -- kali 8x8 -> 16-bit
            when others =>
                r_u := (others => '0');                     -- "11" (bagi) ditangani div8
        end case;
        result <= STD_LOGIC_VECTOR(r_u);
    end process;
end Behavioral;