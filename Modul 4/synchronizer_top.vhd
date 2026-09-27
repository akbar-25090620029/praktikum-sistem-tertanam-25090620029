library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer_top is
    Port ( clk  : in  STD_LOGIC;                      -- pin W5, 100 MHz
           btnC : in  STD_LOGIC;                       -- sumber sinyal asinkron
           led  : out STD_LOGIC_VECTOR (0 downto 0) ); -- led(0) di-toggle
end synchronizer_top;

architecture Behavioral of synchronizer_top is
    component synchronizer_2ff
        Port ( clk      : in STD_LOGIC;
               async_in : in STD_LOGIC;
               sync_out : out STD_LOGIC );
    end component;

    signal sync_s    : STD_LOGIC;
    signal sync_prev : STD_LOGIC := '0';
    signal led_reg   : STD_LOGIC := '0';
begin
    U1: synchronizer_2ff
        port map ( clk => clk, async_in => btnC, sync_out => sync_s );

    process(clk)
    begin
        if rising_edge(clk) then
            sync_prev <= sync_s;
            if sync_prev = '0' and sync_s = '1' then -- deteksi transisi naik (0->1)
                led_reg <= not led_reg;               -- toggle
            end if;
        end if;
    end process;

    led(0) <= led_reg;
end Behavioral;
