library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu4 is
    Port (
        a      : in  STD_LOGIC_VECTOR (3 downto 0);
        b      : in  STD_LOGIC_VECTOR (3 downto 0);
        opcode : in  STD_LOGIC;
        result : out STD_LOGIC_VECTOR (3 downto 0);
        carry  : out STD_LOGIC
    );
end alu4;

architecture Behavioral of alu4 is

begin

    process(a, b, opcode)

        variable temp : UNSIGNED(4 downto 0);

    begin

        if opcode = '0' then

            -- ADD
            temp := ('0' & unsigned(a)) +
                    ('0' & unsigned(b));

            result <= std_logic_vector(temp(3 downto 0));
            carry  <= temp(4);

        else

            -- SUBTRACT
            temp := ('0' & unsigned(a)) -
                    ('0' & unsigned(b));

            result <= std_logic_vector(temp(3 downto 0));

            if unsigned(a) >= unsigned(b) then
                carry <= '1';
            else
                carry <= '0';
            end if;

        end if;

    end process;

end Behavioral;