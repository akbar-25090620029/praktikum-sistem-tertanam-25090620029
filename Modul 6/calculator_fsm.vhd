library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator_fsm is
    Port ( clk     : in  STD_LOGIC;
           rst     : in  STD_LOGIC;
           sw      : in  STD_LOGIC_VECTOR (7 downto 0);  -- nilai operand
           u_pulse : in  STD_LOGIC;  -- muat operand A
           d_pulse : in  STD_LOGIC;  -- muat operand B
           l_pulse : in  STD_LOGIC;  -- operasi SEBELUMNYA (siklus mundur)
           r_pulse : in  STD_LOGIC;  -- operasi BERIKUTNYA (siklus maju)
           c_pulse : in  STD_LOGIC;  -- hitung (di S_WAIT_B) / reset (di S_SHOW)
           result  : out STD_LOGIC_VECTOR (15 downto 0);
           op_led  : out STD_LOGIC_VECTOR (3 downto 0) );  -- one-hot: 0=tambah 1=kurang 2=kali 3=bagi
end calculator_fsm;

architecture Behavioral of calculator_fsm is

    component alu8
        Port ( a      : in  STD_LOGIC_VECTOR (7 downto 0);
               b      : in  STD_LOGIC_VECTOR (7 downto 0);
               op_sel : in  STD_LOGIC_VECTOR (1 downto 0);
               result : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    component div8
        Port ( clk       : in  STD_LOGIC;
               start     : in  STD_LOGIC;
               a         : in  STD_LOGIC_VECTOR (7 downto 0);
               b         : in  STD_LOGIC_VECTOR (7 downto 0);
               done      : out STD_LOGIC;
               quotient  : out STD_LOGIC_VECTOR (7 downto 0);
               remainder : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;

    constant OP_ADD : unsigned(1 downto 0) := "00";
    constant OP_SUB : unsigned(1 downto 0) := "01";
    constant OP_MUL : unsigned(1 downto 0) := "10";
    constant OP_DIV : unsigned(1 downto 0) := "11";

    signal reg_a, reg_b : STD_LOGIC_VECTOR (7 downto 0)  := (others => '0');
    signal result_reg   : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal op_sel       : unsigned(1 downto 0) := OP_ADD;

    signal alu_result   : STD_LOGIC_VECTOR (15 downto 0);
    signal div_q, div_r : STD_LOGIC_VECTOR (7 downto 0);
    signal div_done     : STD_LOGIC;
    signal div_start    : STD_LOGIC;
    signal final_result : STD_LOGIC_VECTOR (15 downto 0);

    -- sinyal kontrol dari process 2 (kombinasional) ke process 1 (sinkron)
    signal load_a, load_b, op_prev, op_next, latch_result, do_reset : STD_LOGIC;

begin

    ALU: alu8
        port map ( a => reg_a, b => reg_b, op_sel => STD_LOGIC_VECTOR(op_sel), result => alu_result );

    DIVIDER: div8
        port map ( clk => clk, start => div_start, a => reg_a, b => reg_b,
                   done => div_done, quotient => div_q, remainder => div_r );

    -- Pemilih hasil: bagi memakai div8 (bagi nol -> FFFF), operasi lain dari ALU
    final_result <= alu_result when op_sel /= OP_DIV else
                    (others => '1') when reg_b = x"00" else
                    x"00" & div_q;

    -- Process 1 (SINKRON): satu-satunya tempat register diperbarui
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state      <= S_WAIT_A;
                reg_a      <= (others => '0');
                reg_b      <= (others => '0');
                result_reg <= (others => '0');
                op_sel     <= OP_ADD;
            else
                state <= next_state;

                if do_reset = '1' then
                    -- BTNC ditekan saat S_SHOW: reset total data
                    reg_a  <= (others => '0');
                    reg_b  <= (others => '0');
                    op_sel <= OP_ADD;
                end if;

                if load_a = '1' then
                    reg_a <= sw;
                end if;

                if load_b = '1' then
                    reg_b <= sw;
                end if;

                if op_prev = '1' then
                    op_sel <= op_sel - 1;    -- 00 -> 11 -> 10 -> 01 -> 00 (melingkar)
                elsif op_next = '1' then
                    op_sel <= op_sel + 1;    -- 00 -> 01 -> 10 -> 11 -> 00 (melingkar)
                end if;

                if latch_result = '1' then
                    result_reg <= final_result;
                end if;
            end if;
        end if;
    end process;

    -- Process 2 (KOMBINASIONAL): next_state + sinyal kontrol
    process(state, u_pulse, d_pulse, l_pulse, r_pulse, c_pulse, op_sel, div_done)
    begin
        next_state   <= state;
        load_a       <= '0';
        load_b       <= '0';
        op_prev      <= '0';
        op_next      <= '0';
        latch_result <= '0';
        do_reset     <= '0';
        div_start    <= '0';

        case state is
            when S_WAIT_A =>
                -- operasi boleh dipilih di S_WAIT_A maupun S_WAIT_B
                if l_pulse = '1' then
                    op_prev <= '1';
                elsif r_pulse = '1' then
                    op_next <= '1';
                end if;
                if u_pulse = '1' then
                    load_a     <= '1';
                    next_state <= S_WAIT_B;
                end if;

            when S_WAIT_B =>
                if l_pulse = '1' then
                    op_prev <= '1';
                elsif r_pulse = '1' then
                    op_next <= '1';
                end if;
                if d_pulse = '1' then
                    load_b <= '1';           -- tetap di S_WAIT_B, boleh load ulang
                end if;
                if c_pulse = '1' then
                    div_start  <= '1';       -- picu pembagi (diabaikan bila op bukan bagi)
                    next_state <= S_COMPUTE; -- BTNC di sini = hitung
                end if;

            when S_COMPUTE =>
                if op_sel = OP_DIV then
                    -- pembagian butuh 8 siklus: tunggu div8 selesai
                    if div_done = '1' then
                        latch_result <= '1';
                        next_state   <= S_SHOW;
                    end if;
                else
                    latch_result <= '1';     -- tambah/kurang/kali: 1 siklus
                    next_state   <= S_SHOW;
                end if;

            when S_SHOW =>
                if c_pulse = '1' then
                    next_state <= S_WAIT_A;  -- BTNC di sini = reset total
                    do_reset   <= '1';
                end if;
        end case;
    end process;

    -- LED indikator operasi aktif (one-hot), murni fungsi dari op_sel (gaya Moore)
    with op_sel select
        op_led <= "0001" when "00",   -- tambah
                  "0010" when "01",   -- kurang
                  "0100" when "10",   -- kali
                  "1000" when others; -- bagi

    result <= result_reg;

end Behavioral;