library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Top-level prosedur: tick_1hz + traffic_light_fsm
entity traffic_light_top is
    Port ( clk  : in  STD_LOGIC;                      -- 100 MHz
           btnC : in  STD_LOGIC;                      -- reset
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_top;
 
architecture Structural of traffic_light_top is
    signal tick : std_logic;
begin
    u_tick : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => 100_000_000 )
        port map ( clk => clk, rst => btnC, tick => tick );
 
    u_fsm : entity work.traffic_light_fsm
        generic map ( GREEN_TIME => 10, YELLOW_TIME => 3 )
        port map ( clk => clk, rst => btnC, tick => tick, led => led );
end Structural;