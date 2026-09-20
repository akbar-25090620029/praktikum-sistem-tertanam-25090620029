library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js03_top is
    Port (
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (4 downto 0)
    );
end js03_top;

architecture Behavioral of js03_top is

    component alu4
        Port (
            a      : in  STD_LOGIC_VECTOR (3 downto 0);
            b      : in  STD_LOGIC_VECTOR (3 downto 0);
            opcode : in  STD_LOGIC;
            result : out STD_LOGIC_VECTOR (3 downto 0);
            carry  : out STD_LOGIC
        );
    end component;

    signal result_signal : STD_LOGIC_VECTOR (3 downto 0);
    signal carry_signal  : STD_LOGIC;

begin

    ALU_INSTANCE : alu4
        port map (
            a      => sw(3 downto 0),
            b      => sw(7 downto 4),
            opcode => sw(15),
            result => result_signal,
            carry  => carry_signal
        );

    led(3 downto 0) <= result_signal;
    led(4)          <= carry_signal;

end Behavioral;