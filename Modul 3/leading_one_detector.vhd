library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity leading_one_detector is
    Port (
        input_data : in  STD_LOGIC_VECTOR (7 downto 0);
        pos        : out STD_LOGIC_VECTOR (2 downto 0);
        valid      : out STD_LOGIC
    );
end leading_one_detector;

architecture Behavioral of leading_one_detector is
begin

    process(input_data)
    begin
        -- Nilai default
        pos   <= "000";
        valid <= '0';

        -- Mencari bit '1' paling kiri
        if input_data(7) = '1' then
            pos   <= "111";
            valid <= '1';

        elsif input_data(6) = '1' then
            pos   <= "110";
            valid <= '1';

        elsif input_data(5) = '1' then
            pos   <= "101";
            valid <= '1';

        elsif input_data(4) = '1' then
            pos   <= "100";
            valid <= '1';

        elsif input_data(3) = '1' then
            pos   <= "011";
            valid <= '1';

        elsif input_data(2) = '1' then
            pos   <= "010";
            valid <= '1';

        elsif input_data(1) = '1' then
            pos   <= "001";
            valid <= '1';

        elsif input_data(0) = '1' then
            pos   <= "000";
            valid <= '1';

        else
            pos   <= "000";
            valid <= '0';
        end if;

    end process;

end Behavioral;