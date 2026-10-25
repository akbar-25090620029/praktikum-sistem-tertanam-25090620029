----------------------------------------------------------------------------------
-- Jobsheet 8 - Prosedur 1
-- tb_bram_256x8.vhd : tulis beberapa data ke alamat berbeda, baca kembali, verifikasi dengan assert
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_256x8 is
end tb_bram_256x8;

architecture Behavioral of tb_bram_256x8 is
    component bram_256x8
        Port ( clk  : in  STD_LOGIC;
               we   : in  STD_LOGIC;
               addr : in  STD_LOGIC_VECTOR (7 downto 0);
               din  : in  STD_LOGIC_VECTOR (7 downto 0);
               dout : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal din  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR (7 downto 0);
    signal sim_done : boolean := false;

    constant CLK_PERIOD : time := 10 ns;
    constant N : integer := 10;
    type addr_array is array (0 to N-1) of integer range 0 to 255;
    constant TEST_ADDR : addr_array := (0, 1, 2, 17, 50, 100, 128, 200, 254, 255);
begin
    uut : bram_256x8 port map (clk => clk, we => we, addr => addr, din => din, dout => dout);

    clk_proc : process
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim_proc : process
        variable expected : STD_LOGIC_VECTOR(7 downto 0);
    begin
        wait for 4 * CLK_PERIOD;

        -- 1) Tulis N data ke alamat berbeda (data = alamat XOR x"A5")
        for i in 0 to N-1 loop
            wait until falling_edge(clk);
            addr <= std_logic_vector(to_unsigned(TEST_ADDR(i), 8));
            din  <= std_logic_vector(to_unsigned(TEST_ADDR(i), 8)) xor x"A5";
            we   <= '1';
        end loop;
        wait until falling_edge(clk);
        we <= '0';

        -- 2) Baca kembali dan verifikasi (dout registered -> valid 1 siklus clock setelah alamat)
        for i in 0 to N-1 loop
            wait until falling_edge(clk);
            addr <= std_logic_vector(to_unsigned(TEST_ADDR(i), 8));
            wait until rising_edge(clk);
            wait for 1 ns;
            expected := std_logic_vector(to_unsigned(TEST_ADDR(i), 8)) xor x"A5";
            assert dout = expected
                report "BRAM MISMATCH di alamat " & integer'image(TEST_ADDR(i)) &
                       " : dibaca " & integer'image(to_integer(unsigned(dout))) &
                       ", seharusnya " & integer'image(to_integer(unsigned(expected)))
                severity error;
        end loop;

        -- 3) Alamat yang tidak pernah ditulis harus bernilai 0 (inisialisasi)
        wait until falling_edge(clk);
        addr <= x"07";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"00"
            report "Alamat 7 seharusnya 0 (belum pernah ditulis)" severity error;

        report "tb_bram_256x8 SELESAI - jika tidak ada error di atas, semua data cocok." severity note;
        sim_done <= true;
        wait;
    end process;
end Behavioral;
