library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas 1 : fase all-red (1 detik) di antara pergantian arah (6 state)
-- Tugas 2 : durasi hijau diatur sw(3 downto 0) -> 5 + sw = 5..20 detik
--
-- led(2 downto 0) = Utara-Selatan : bit0=hijau, bit1=kuning, bit2=merah
-- led(5 downto 3) = Timur-Barat   : bit3=hijau, bit4=kuning, bit5=merah
entity traffic_light_fsm_tugas is
    Generic ( YELLOW_TIME  : integer := 3;   -- detik
              ALLRED_TIME  : integer := 1;   -- detik
              GREEN_MIN    : integer := 5 ); -- detik (sw = 0000)
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;                         -- pulsa 1 detik
           sw   : in  STD_LOGIC_VECTOR (3 downto 0);     -- pengatur durasi hijau
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_fsm_tugas;

architecture Behavioral of traffic_light_fsm_tugas is
    type state_t is (NS_GREEN, NS_YELLOW, ALL_RED_1,
                     EW_GREEN, EW_YELLOW, ALL_RED_2);

    signal state, next_state : state_t := NS_GREEN;
    signal timer, next_timer : integer range 0 to 31 := GREEN_MIN-1;

    -- durasi hijau (detik) = 5 + sw  ->  5 .. 20
    signal green_time : integer range 0 to 31;
begin

    green_time <= GREEN_MIN + to_integer(unsigned(sw));

    ----------------------------------------------------------------
    -- Process 1: register state dan timer
    ----------------------------------------------------------------
    seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= NS_GREEN;
                timer <= green_time-1;
            else
                state <= next_state;
                timer <= next_timer;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Process 2: next-state dan next-timer
    -- Urutan: NS_GREEN -> NS_YELLOW -> ALL_RED_1 ->
    --         EW_GREEN -> EW_YELLOW -> ALL_RED_2 -> NS_GREEN
    -- Nilai sw dibaca saat timer hijau diisi, jadi perubahan switch
    -- baru berlaku pada fase hijau berikutnya (tidak memotong fase
    -- hijau yang sedang berjalan).
    ----------------------------------------------------------------
    comb : process(state, timer, tick, green_time)
    begin
        next_state <= state;
        next_timer <= timer;

        if tick = '1' then
            if timer = 0 then
                case state is
                    when NS_GREEN =>
                        next_state <= NS_YELLOW;
                        next_timer <= YELLOW_TIME-1;
                    when NS_YELLOW =>
                        next_state <= ALL_RED_1;
                        next_timer <= ALLRED_TIME-1;
                    when ALL_RED_1 =>
                        next_state <= EW_GREEN;
                        next_timer <= green_time-1;
                    when EW_GREEN =>
                        next_state <= EW_YELLOW;
                        next_timer <= YELLOW_TIME-1;
                    when EW_YELLOW =>
                        next_state <= ALL_RED_2;
                        next_timer <= ALLRED_TIME-1;
                    when ALL_RED_2 =>
                        next_state <= NS_GREEN;
                        next_timer <= green_time-1;
                end case;
            else
                next_timer <= timer - 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Decoder keluaran: led = EW[5:3] & NS[2:0]
    -- (hijau = "001", kuning = "010", merah = "100")
    ----------------------------------------------------------------
    with state select
        led <= "100" & "001" when NS_GREEN,
               "100" & "010" when NS_YELLOW,
               "100" & "100" when ALL_RED_1,
               "001" & "100" when EW_GREEN,
               "010" & "100" when EW_YELLOW,
               "100" & "100" when ALL_RED_2;

end Behavioral;
