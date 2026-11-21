library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Penerima scan code PS/2 (Kode 12.1), dengan pemeriksaan start, parity ganjil dan stop.
entity ps2_receiver is
    Port ( clk        : in  STD_LOGIC;                       -- clock sistem, 100 MHz
           ps2_clk    : in  STD_LOGIC;                       -- dari PIC24 (via port USB HID)
           ps2_data   : in  STD_LOGIC;
           scan_code  : out STD_LOGIC_VECTOR (7 downto 0);
           data_ready : out STD_LOGIC );                     -- pulsa 1 siklus saat scan_code valid
end ps2_receiver;

architecture Behavioral of ps2_receiver is
    -- Synchronizer: ps2_clk 3 tingkat (untuk deteksi tepi turun), ps2_data 2 tingkat
    signal clk_ff1, clk_ff2, clk_ff3 : STD_LOGIC := '1';
    signal data_ff1, data_ff2        : STD_LOGIC := '1';
    signal ps2_fall                  : STD_LOGIC;
    signal shift_reg : STD_LOGIC_VECTOR (10 downto 0) := (others => '1');
    signal bit_cnt   : integer range 0 to 10 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            clk_ff1  <= ps2_clk;  clk_ff2  <= clk_ff1;  clk_ff3 <= clk_ff2;
            data_ff1 <= ps2_data; data_ff2 <= data_ff1;
        end if;
    end process;

    ps2_fall <= clk_ff3 and not clk_ff2;   -- tepi turun ps2_clk

    process(clk)
        variable frame  : STD_LOGIC_VECTOR (10 downto 0);
        variable parity : STD_LOGIC;
    begin
        if rising_edge(clk) then
            data_ready <= '0';
            if ps2_fall = '1' then
                if bit_cnt = 10 then
                    bit_cnt <= 0;
                    -- frame lengkap: (0)=start, (8 downto 1)=data LSB..MSB, (9)=parity, (10)=stop
                    frame := data_ff2 & shift_reg(9 downto 0);
                    parity := '0';
                    for i in 1 to 9 loop
                        parity := parity xor frame(i);
                    end loop;
                    -- start harus '0', stop harus '1', parity ganjil (xor data+parity = '1')
                    if frame(0) = '0' and frame(10) = '1' and parity = '1' then
                        scan_code  <= frame(8 downto 1);
                        data_ready <= '1';
                    end if;
                else
                    shift_reg(bit_cnt) <= data_ff2;
                    bit_cnt <= bit_cnt + 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
