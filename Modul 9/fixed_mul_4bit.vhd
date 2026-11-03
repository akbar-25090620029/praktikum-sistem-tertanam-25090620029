library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Basys 3: SW3..SW0 = A, SW7..SW4 = B.
-- Hasil perkalian unsigned 4x4 bit (0..225) tampil sebagai 2 digit hex.
entity fixed_mul_4bit is
    Port (
        clk : in  STD_LOGIC;
        sw  : in  STD_LOGIC_VECTOR(7 downto 0);
        seg : out STD_LOGIC_VECTOR(6 downto 0);
        an  : out STD_LOGIC_VECTOR(3 downto 0);
        dp  : out STD_LOGIC
    );
end fixed_mul_4bit;

architecture Behavioral of fixed_mul_4bit is
    signal a : unsigned(3 downto 0);
    signal b : unsigned(3 downto 0);
    signal product : unsigned(7 downto 0);

    signal refresh_counter : unsigned(15 downto 0) := (others => '0');
    signal digit_select : STD_LOGIC_VECTOR(1 downto 0);
    signal digit : STD_LOGIC_VECTOR(3 downto 0);
    signal an_i : STD_LOGIC_VECTOR(3 downto 0);
begin
    a <= unsigned(sw(3 downto 0));
    b <= unsigned(sw(7 downto 4));
    product <= a * b;

    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    digit_select <= std_logic_vector(refresh_counter(15 downto 14));

    process(digit_select, product)
    begin
        case digit_select is
            when "00" =>
                digit <= product(3 downto 0);
                an_i <= "1110";
            when "01" =>
                digit <= product(7 downto 4);
                an_i <= "1101";
            when others =>
                digit <= "0000";
                an_i <= "1111";
        end case;
    end process;

    process(digit)
    begin
        case digit is
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0000110"; -- E
            when others => seg <= "0001110"; -- F
        end case;
    end process;

    an <= an_i;
    dp <= '1';
end Behavioral;
