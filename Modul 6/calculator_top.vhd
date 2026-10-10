library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calculator_top is
    Port ( clk  : in  STD_LOGIC;                      -- W5, 100 MHz
           sw   : in  STD_LOGIC_VECTOR (7 downto 0);   -- operand
           btnU : in  STD_LOGIC;                       -- muat A
           btnD : in  STD_LOGIC;                       -- muat B
           btnL : in  STD_LOGIC;                       -- operasi sebelumnya (mundur)
           btnR : in  STD_LOGIC;                       -- operasi berikutnya (maju)
           btnC : in  STD_LOGIC;                       -- hitung (di WAIT_B) / reset (di SHOW)
           led  : out STD_LOGIC_VECTOR (3 downto 0);   -- LED0=tambah, LED1=kurang, LED2=kali, LED3=bagi
           seg  : out STD_LOGIC_VECTOR (6 downto 0);
           dp   : out STD_LOGIC;
           an   : out STD_LOGIC_VECTOR (3 downto 0) );
end calculator_top;

architecture Behavioral of calculator_top is

    signal u_clean, d_clean, l_clean, r_clean, c_clean : STD_LOGIC;
    signal u_pulse, d_pulse, l_pulse, r_pulse, c_pulse  : STD_LOGIC;
    signal result   : STD_LOGIC_VECTOR (15 downto 0);

begin

    DB_U: entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnU, btn_out => u_clean );
    DB_D: entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnD, btn_out => d_clean );
    DB_L: entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnL, btn_out => l_clean );
    DB_R: entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnR, btn_out => r_clean );
    DB_C: entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnC, btn_out => c_clean );

    ED_U: entity work.edge_detect port map ( clk => clk, sig_in => u_clean, pulse => u_pulse );
    ED_D: entity work.edge_detect port map ( clk => clk, sig_in => d_clean, pulse => d_pulse );
    ED_L: entity work.edge_detect port map ( clk => clk, sig_in => l_clean, pulse => l_pulse );
    ED_R: entity work.edge_detect port map ( clk => clk, sig_in => r_clean, pulse => r_pulse );
    ED_C: entity work.edge_detect port map ( clk => clk, sig_in => c_clean, pulse => c_pulse );

    FSM: entity work.calculator_fsm
        port map ( clk => clk, rst => '0', sw => sw,
                   u_pulse => u_pulse, d_pulse => d_pulse,
                   l_pulse => l_pulse, r_pulse => r_pulse, c_pulse => c_pulse,
                   result => result, op_led => led );

    DRV: entity work.seven_seg_driver_hex
        generic map ( DIGITS => 4 )
        port map ( clk => clk, value => result, seg => seg, dp => dp, an => an );

end Behavioral;