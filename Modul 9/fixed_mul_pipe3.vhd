library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Pipeline 3 tahap dengan alignment data yang konsisten.
-- Tahap 1: hitung empat perkalian parsial dan simpan input terkait.
-- Tahap 2: jumlahkan suku tengah dan susun produk 32-bit.
-- Tahap 3: ambil bit Q8.8 dan simpan hasil.
entity fixed_mul_pipe3 is
    Port (
        clk    : in  STD_LOGIC;
        a      : in  STD_LOGIC_VECTOR(15 downto 0);
        b      : in  STD_LOGIC_VECTOR(15 downto 0);
        result : out STD_LOGIC_VECTOR(15 downto 0)
    );
end fixed_mul_pipe3;

architecture Behavioral of fixed_mul_pipe3 is
    signal p_ll_s1 : unsigned(15 downto 0) := (others => '0');
    signal p_lh_s1 : unsigned(15 downto 0) := (others => '0');
    signal p_hl_s1 : unsigned(15 downto 0) := (others => '0');
    signal p_hh_s1 : unsigned(15 downto 0) := (others => '0');

    signal p_ll_s2 : unsigned(15 downto 0) := (others => '0');
    signal middle_s2 : unsigned(16 downto 0) := (others => '0');
    signal p_hh_s2 : unsigned(15 downto 0) := (others => '0');

    signal product_s3 : unsigned(31 downto 0) := (others => '0');
    signal result_s3 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    -- Tahap 1: empat perkalian 8 x 8 bit.
    process(clk)
    begin
        if rising_edge(clk) then
            p_ll_s1 <= unsigned(a(7 downto 0))  * unsigned(b(7 downto 0));
            p_lh_s1 <= unsigned(a(7 downto 0))  * unsigned(b(15 downto 8));
            p_hl_s1 <= unsigned(a(15 downto 8)) * unsigned(b(7 downto 0));
            p_hh_s1 <= unsigned(a(15 downto 8)) * unsigned(b(15 downto 8));
        end if;
    end process;

    -- Tahap 2: hitung suku tengah dan teruskan suku lain.
    process(clk)
    begin
        if rising_edge(clk) then
            p_ll_s2 <= p_ll_s1;
            middle_s2 <= resize(p_lh_s1, 17) + resize(p_hl_s1, 17);
            p_hh_s2 <= p_hh_s1;
        end if;
    end process;

    -- Tahap 3: susun produk penuh dan ambil Q8.8.
    process(clk)
    begin
        if rising_edge(clk) then
            product_s3 <=
                shift_left(resize(p_hh_s2, 32), 16) +
                shift_left(resize(middle_s2, 32), 8) +
                resize(p_ll_s2, 32);
            result_s3 <= std_logic_vector(product_s3(23 downto 8));
        end if;
    end process;

    result <= result_s3;
end Behavioral;
