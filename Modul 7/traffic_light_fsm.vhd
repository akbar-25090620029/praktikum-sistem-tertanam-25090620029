library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Prosedur praktikum: FSM lampu lalu lintas 4 state, gaya 2-process
-- Hijau = 10 detik, kuning = 3 detik (tanpa all-red, tanpa switch)
--
-- led(2 downto 0) = Utara-Selatan : bit0=hijau, bit1=kuning, bit2=merah
-- led(5 downto 3) = Timur-Barat   : bit3=hijau, bit4=kuning, bit5=merah
entity traffic_light_fsm is
    Generic ( GREEN_TIME  : integer := 10;   -- detik
              YELLOW_TIME : integer := 3 );  -- detik
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;                         -- pulsa 1 detik
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_fsm;
 
architecture Behavioral of traffic_light_fsm is
    type state_t is (NS_GREEN, NS_YELLOW, EW_GREEN, EW_YELLOW);
 
    signal state, next_state : state_t := NS_GREEN;
    signal timer, next_timer : integer range 0 to 31 := GREEN_TIME-1;
begin
 
    ----------------------------------------------------------------
    -- Process 1: register state dan timer
    ----------------------------------------------------------------
    seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= NS_GREEN;
                timer <= GREEN_TIME-1;
            else
                state <= next_state;
                timer <= next_timer;
            end if;
        end if;
    end process;
 
    ----------------------------------------------------------------
    -- Process 2: next-state dan next-timer
    -- Urutan: NS_GREEN -> NS_YELLOW -> EW_GREEN -> EW_YELLOW -> NS_GREEN
    -- Timer dikurangi tiap tick='1'; pindah state saat timer = 0.
    ----------------------------------------------------------------
    comb : process(state, timer, tick)
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
                        next_state <= EW_GREEN;
                        next_timer <= GREEN_TIME-1;
                    when EW_GREEN =>
                        next_state <= EW_YELLOW;
                        next_timer <= YELLOW_TIME-1;
                    when EW_YELLOW =>
                        next_state <= NS_GREEN;
                        next_timer <= GREEN_TIME-1;
                end case;
            else
                next_timer <= timer - 1;
            end if;
        end if;
    end process;
 
    ----------------------------------------------------------------
    -- Decoder keluaran: led = EW[5:3] & NS[2:0]
    -- (hijau = "001", kuning = "010", merah = "100")
    -- Hanya 1 dari 3 LED per arah yang menyala, dan kedua arah
    -- tidak pernah sama-sama hijau.
    ----------------------------------------------------------------
    with state select
        led <= "100" & "001" when NS_GREEN,    -- NS hijau,  EW merah
               "100" & "010" when NS_YELLOW,   -- NS kuning, EW merah
               "001" & "100" when EW_GREEN,    -- NS merah,  EW hijau
               "010" & "100" when EW_YELLOW;   -- NS merah,  EW kuning
 
end Behavioral;