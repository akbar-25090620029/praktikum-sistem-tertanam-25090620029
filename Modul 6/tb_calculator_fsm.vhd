library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture sim of tb_calculator_fsm is
    signal clk_tb : STD_LOGIC := '0';
    signal rst_tb : STD_LOGIC := '0';
    signal sw_tb  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal u_tb, d_tb, l_tb, r_tb, c_tb : STD_LOGIC := '0';
    signal result_tb : STD_LOGIC_VECTOR (7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    -- Prosedur bantu: berikan pulsa 1-siklus ke sinyal tertentu
    procedure pulse(signal s : out STD_LOGIC) is
    begin
        s <= '1';
        wait for CLK_PERIOD;
        s <= '0';
        wait for CLK_PERIOD;
    end procedure;
begin
    UUT: entity work.calculator_fsm
        port map ( clk => clk_tb, rst => rst_tb, sw => sw_tb,
                   u_pulse => u_tb, d_pulse => d_tb,
                   l_pulse => l_tb, r_pulse => r_tb, c_pulse => c_tb,
                   result => result_tb );

    clk_process : process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD/2;
        clk_tb <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_process : process
    begin
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        -- Skenario 1: 15 + 10 = 25
        sw_tb <= std_logic_vector(to_unsigned(15, 8));
        pulse(u_tb);                       -- muat A=15, pindah ke S_WAIT_B

        sw_tb <= std_logic_vector(to_unsigned(10, 8));
        pulse(d_tb);                       -- muat B=10, tetap di S_WAIT_B

        pulse(l_tb);                       -- pilih operasi tambah
        pulse(c_tb);                       -- -> S_COMPUTE -> S_SHOW
        wait for CLK_PERIOD*2;
        -- Periksa di waveform: result_tb harus = 25 ("00011001")

        pulse(c_tb);                       -- konfirmasi: -> S_WAIT_A lagi

        -- Skenario 2: 20 - 5 = 15
        sw_tb <= std_logic_vector(to_unsigned(20, 8));
        pulse(u_tb);

        sw_tb <= std_logic_vector(to_unsigned(5, 8));
        pulse(d_tb);

        pulse(r_tb);                       -- pilih operasi kurang
        pulse(c_tb);
        wait for CLK_PERIOD*2;
        -- Periksa: result_tb harus = 15 ("00001111")

        wait;
    end process;
end sim;
