----------------------------------------------------------------------------------
-- Jobsheet 8 - Prosedur 3
-- i2c_master.vhd : kerangka FSM I2C master (Standard mode 100 kHz dari clock 100 MHz)
--
-- Satu transaksi (dipicu pulsa 'start'):
--   START | ADDR+W | ACK | REG_ADDR | ACK | Repeated START | ADDR+R | ACK | DATA(8 bit) | NACK | STOP
--
-- Setiap bit SCL dibagi menjadi 4 fase (quarter period):
--   fase 0 : SCL low, SDA diatur
--   fase 1 : SCL dilepas (high)
--   fase 2 : SCL high, SDA stabil (di sini SDA disampel untuk ACK / data baca)
--   fase 3 : SCL low
-- SCL/SDA bersifat open-drain: hanya mengirim '0' atau 'Z' (butuh pull-up eksternal).
-- Clock stretching oleh slave tidak didukung (disederhanakan).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    generic ( CLK_DIV : positive := 1000 );   -- jumlah clock sistem per 1 periode SCL
                                              -- 100 MHz / 100 kHz = 1000
    Port ( clk        : in    STD_LOGIC;
           rst        : in    STD_LOGIC;
           start      : in    STD_LOGIC;                       -- pulsa: mulai transaksi
           slave_addr : in    STD_LOGIC_VECTOR (6 downto 0);   -- alamat slave 7-bit
           reg_addr   : in    STD_LOGIC_VECTOR (7 downto 0);   -- register yang dibaca
           data_out   : out   STD_LOGIC_VECTOR (7 downto 0);   -- hasil baca 1 byte
           busy       : out   STD_LOGIC;
           done       : out   STD_LOGIC;                       -- pulsa 1 clock saat selesai
           ack_error  : out   STD_LOGIC;                       -- '1' jika slave tidak ACK
           scl        : out   STD_LOGIC;                       -- open-drain
           sda        : inout STD_LOGIC );                     -- open-drain
end i2c_master;

architecture Behavioral of i2c_master is

    type i2c_state is (S_IDLE, S_START, S_ADDR, S_ADDR_ACK,
                       S_DATA, S_DATA_ACK, S_STOP);
    signal state : i2c_state := S_IDLE;

    constant QTR : positive := CLK_DIV / 4;           -- clock per seperempat periode SCL

    signal tick_cnt  : integer range 0 to QTR-1 := 0;
    signal tick      : STD_LOGIC := '0';              -- 1 pulsa tiap seperempat periode SCL
    signal phase     : unsigned(1 downto 0) := "00";
    signal bit_cnt   : integer range 0 to 7 := 0;
    signal step      : integer range 0 to 2 := 0;    -- 0: ADDR+W, 1: REG_ADDR, 2: ADDR+R
    signal shreg     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal start_req : STD_LOGIC := '0';
    signal ack_err_i : STD_LOGIC := '0';

    signal scl_low   : STD_LOGIC := '0';              -- '1' = tarik SCL ke 0
    signal sda_low   : STD_LOGIC := '0';              -- '1' = tarik SDA ke 0
    signal sda_in    : STD_LOGIC;
begin

    -- Open-drain: tidak pernah mengirim '1', hanya '0' atau 'Z'
    scl <= '0' when scl_low = '1' else 'Z';
    sda <= '0' when sda_low = '1' else 'Z';
    sda_in <= '1' when (sda = '1' or sda = 'H') else '0';

    ack_error <= ack_err_i;

    ----------------------------------------------------------------------
    -- Pembangkit tick (4x frekuensi SCL)
    ----------------------------------------------------------------------
    tick_gen : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tick_cnt <= 0;
                tick     <= '0';
            elsif tick_cnt = QTR-1 then
                tick_cnt <= 0;
                tick     <= '1';
            else
                tick_cnt <= tick_cnt + 1;
                tick     <= '0';
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- FSM utama
    ----------------------------------------------------------------------
    fsm : process(clk)
    begin
        if rising_edge(clk) then
            done <= '0';
            if start = '1' then
                start_req <= '1';                     -- tangkap pulsa start
            end if;

            if rst = '1' then
                state     <= S_IDLE;
                phase     <= "00";
                bit_cnt   <= 0;
                step      <= 0;
                start_req <= '0';
                ack_err_i <= '0';
                scl_low   <= '0';
                sda_low   <= '0';
                busy      <= '0';
                data_out  <= (others => '0');

            elsif tick = '1' then
                phase <= phase + 1;                   -- default: maju satu fase

                case state is

                    ------------------------------------------------------
                    when S_IDLE =>
                        phase   <= "00";
                        scl_low <= '0';
                        sda_low <= '0';
                        busy    <= '0';
                        if start_req = '1' then
                            start_req <= '0';
                            busy      <= '1';
                            ack_err_i <= '0';
                            step      <= 0;
                            bit_cnt   <= 0;
                            shreg     <= slave_addr & '0';   -- ADDR + W
                            state     <= S_START;
                        end if;

                    ------------------------------------------------------
                    -- START / Repeated START : SDA turun saat SCL tinggi
                    when S_START =>
                        case phase is
                            when "00"   => sda_low <= '0';         -- lepas SDA
                            when "01"   => scl_low <= '0';         -- lepas SCL (high)
                            when "10"   => sda_low <= '1';         -- SDA turun saat SCL high = START
                            when others => scl_low <= '1';         -- SCL low
                                           bit_cnt <= 0;
                                           state   <= S_ADDR;
                        end case;

                    ------------------------------------------------------
                    -- Kirim 1 byte (MSB dulu): alamat slave+R/W atau alamat register
                    when S_ADDR =>
                        case phase is
                            when "00"   => scl_low <= '1';
                                           sda_low <= not shreg(7);  -- bit '0' -> tarik SDA low
                            when "01"   => scl_low <= '0';
                            when "10"   => null;
                            when others => scl_low <= '1';
                                           shreg   <= shreg(6 downto 0) & '0';
                                           if bit_cnt = 7 then
                                               bit_cnt <= 0;
                                               state   <= S_ADDR_ACK;
                                           else
                                               bit_cnt <= bit_cnt + 1;
                                           end if;
                        end case;

                    ------------------------------------------------------
                    -- Baca bit ACK dari slave (SDA low = ACK)
                    when S_ADDR_ACK =>
                        case phase is
                            when "00"   => scl_low <= '1';
                                           sda_low <= '0';           -- lepas SDA untuk slave
                            when "01"   => scl_low <= '0';
                            when "10"   => if sda_in = '1' then      -- NACK
                                               ack_err_i <= '1';
                                           end if;
                            when others => scl_low <= '1';
                                           if ack_err_i = '1' then
                                               state <= S_STOP;
                                           else
                                               case step is
                                                   when 0 =>          -- lanjut kirim alamat register
                                                       shreg <= reg_addr;
                                                       step  <= 1;
                                                       state <= S_ADDR;
                                                   when 1 =>          -- Repeated START + ADDR+R
                                                       shreg <= slave_addr & '1';
                                                       step  <= 2;
                                                       state <= S_START;
                                                   when others =>     -- ADDR+R di-ACK: baca data
                                                       state <= S_DATA;
                                               end case;
                                           end if;
                        end case;

                    ------------------------------------------------------
                    -- Baca 1 byte dari slave
                    when S_DATA =>
                        case phase is
                            when "00"   => scl_low <= '1';
                                           sda_low <= '0';           -- lepas SDA
                            when "01"   => scl_low <= '0';
                            when "10"   => shreg <= shreg(6 downto 0) & sda_in;  -- sampel bit
                            when others => scl_low <= '1';
                                           if bit_cnt = 7 then
                                               bit_cnt  <= 0;
                                               data_out <= shreg;
                                               state    <= S_DATA_ACK;
                                           else
                                               bit_cnt <= bit_cnt + 1;
                                           end if;
                        end case;

                    ------------------------------------------------------
                    -- Master mengirim NACK (SDA tetap high) karena hanya baca 1 byte
                    when S_DATA_ACK =>
                        case phase is
                            when "00"   => scl_low <= '1';
                                           sda_low <= '0';           -- SDA high = NACK
                            when "01"   => scl_low <= '0';
                            when "10"   => null;
                            when others => scl_low <= '1';
                                           state   <= S_STOP;
                        end case;

                    ------------------------------------------------------
                    -- STOP : SDA naik saat SCL tinggi
                    when S_STOP =>
                        case phase is
                            when "00"   => scl_low <= '1';
                                           sda_low <= '1';           -- SDA low, SCL low
                            when "01"   => scl_low <= '0';           -- SCL high
                            when "10"   => sda_low <= '0';           -- SDA naik saat SCL high = STOP
                            when others => state <= S_IDLE;
                                           done  <= '1';
                        end case;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
