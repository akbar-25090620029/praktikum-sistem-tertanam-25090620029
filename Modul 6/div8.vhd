library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Pembagi 8-bit tanpa tanda, metode restoring (shift-subtract), 8 siklus clock.
--  start='1' (1 siklus) -> mulai; done='1' saat quotient valid (tertahan sampai start berikutnya).
-- Pembagian dengan nol ditangani di luar modul (calculator_fsm).
entity div8 is
    Port ( clk      : in  STD_LOGIC;
           start    : in  STD_LOGIC;
           a        : in  STD_LOGIC_VECTOR (7 downto 0);  -- dibagi
           b        : in  STD_LOGIC_VECTOR (7 downto 0);  -- pembagi
           done     : out STD_LOGIC;
           quotient : out STD_LOGIC_VECTOR (7 downto 0);
           remainder: out STD_LOGIC_VECTOR (7 downto 0) );
end div8;

architecture Behavioral of div8 is
    signal rem_r   : unsigned(8 downto 0) := (others => '0');
    signal q_r     : unsigned(7 downto 0) := (others => '0');
    signal cnt     : integer range 0 to 8 := 0;
    signal running : STD_LOGIC := '0';
    signal done_r  : STD_LOGIC := '0';
begin
    process(clk)
        variable r_next : unsigned(8 downto 0);
    begin
        if rising_edge(clk) then
            if start = '1' then
                rem_r   <= (others => '0');
                q_r     <= unsigned(a);
                cnt     <= 8;
                running <= '1';
                done_r  <= '0';
            elsif running = '1' then
                -- geser {rem,q} satu bit ke kiri
                r_next := rem_r(7 downto 0) & q_r(7 downto 7);
                if r_next >= ('0' & unsigned(b)) then
                    rem_r <= r_next - ('0' & unsigned(b));
                    q_r   <= q_r(6 downto 0) & '1';
                else
                    rem_r <= r_next;
                    q_r   <= q_r(6 downto 0) & '0';
                end if;

                if cnt = 1 then
                    running <= '0';
                    done_r  <= '1';
                end if;
                cnt <= cnt - 1;
            end if;
        end if;
    end process;

    done      <= done_r;
    quotient  <= STD_LOGIC_VECTOR(q_r);
    remainder <= STD_LOGIC_VECTOR(rem_r(7 downto 0));
end Behavioral;
