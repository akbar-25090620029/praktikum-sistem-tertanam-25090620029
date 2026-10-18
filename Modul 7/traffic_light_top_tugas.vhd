library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level Tugas 1 & 2: tick_1hz + traffic_light_fsm_tugas
entity traffic_light_top_tugas is
    Port ( clk  : in  STD_LOGIC;                      -- 100 MHz
           btnC : in  STD_LOGIC;                      -- reset
           sw   : in  STD_LOGIC_VECTOR (3 downto 0);  -- durasi hijau 5..20 detik
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_top_tugas;

architecture Structural of traffic_light_top_tugas is
    signal tick : std_logic;
begin
    u_tick : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => 100_000_000 )
        port map ( clk => clk, rst => btnC, tick => tick );

    u_fsm : entity work.traffic_light_fsm_tugas
        generic map ( YELLOW_TIME => 3, ALLRED_TIME => 1, GREEN_MIN => 5 )
        port map ( clk => clk, rst => btnC, tick => tick, sw => sw, led => led );
end Structural;
