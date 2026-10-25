----------------------------------------------------------------------------------
-- Jobsheet 8 - Prosedur 4
-- tb_i2c_master.vhd : memicu 1 transaksi (tulis alamat register + baca 1 byte)
-- Slave dimodelkan secara perilaku (alamat 0x48, seperti ADT7420 / Pmod TMP2)
-- dan mengembalikan byte 0x19. Amati SCL/SDA pada waveform.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_i2c_master is
end tb_i2c_master;

architecture Behavioral of tb_i2c_master is
    component i2c_master
        generic ( CLK_DIV : positive := 1000 );
        Port ( clk        : in    STD_LOGIC;
               rst        : in    STD_LOGIC;
               start      : in    STD_LOGIC;
               slave_addr : in    STD_LOGIC_VECTOR (6 downto 0);
               reg_addr   : in    STD_LOGIC_VECTOR (7 downto 0);
               data_out   : out   STD_LOGIC_VECTOR (7 downto 0);
               busy       : out   STD_LOGIC;
               done       : out   STD_LOGIC;
               ack_error  : out   STD_LOGIC;
               scl        : out   STD_LOGIC;
               sda        : inout STD_LOGIC );
    end component;

    constant CLK_PERIOD : time := 10 ns;              -- 100 MHz
    constant SLAVE_ADDR : STD_LOGIC_VECTOR(6 downto 0) := "1001000";  -- 0x48
    constant REG_ADDR   : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    constant SLAVE_DATA : STD_LOGIC_VECTOR(7 downto 0) := x"19";

    signal clk, rst, start : STD_LOGIC := '0';
    signal data_out  : STD_LOGIC_VECTOR(7 downto 0);
    signal busy, done, ack_error : STD_LOGIC;
    signal scl, sda  : STD_LOGIC;
    signal sim_done  : boolean := false;
begin
    -- Resistor pull-up pada bus
    scl <= 'H';
    sda <= 'H';

    uut : i2c_master
        generic map ( CLK_DIV => 1000 )
        port map ( clk => clk, rst => rst, start => start,
                   slave_addr => SLAVE_ADDR, reg_addr => REG_ADDR,
                   data_out => data_out, busy => busy, done => done,
                   ack_error => ack_error, scl => scl, sda => sda );

    clk_proc : process
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    ----------------------------------------------------------------------
    -- Model slave I2C sederhana
    ----------------------------------------------------------------------
    slave_proc : process
        variable b : STD_LOGIC_VECTOR(7 downto 0);

        procedure recv_byte(variable rx : out STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            for i in 7 downto 0 loop
                wait until rising_edge(scl);
                rx(i) := to_x01(sda);
            end loop;
            wait until falling_edge(scl);
            sda <= '0';                                -- ACK
            wait until falling_edge(scl);
            sda <= 'Z';                                -- lepas SDA
        end procedure;
    begin
        sda <= 'Z';

        -- START
        wait until falling_edge(sda) and to_x01(scl) = '1';
        recv_byte(b);
        assert b = (SLAVE_ADDR & '0')
            report "Slave: ADDR+W salah" severity error;
        recv_byte(b);
        assert b = REG_ADDR
            report "Slave: alamat register salah" severity error;

        -- Repeated START
        wait until falling_edge(sda) and to_x01(scl) = '1';
        recv_byte(b);
        assert b = (SLAVE_ADDR & '1')
            report "Slave: ADDR+R salah" severity error;

        -- Kirim 1 byte data ke master
        for i in 7 downto 0 loop
            if SLAVE_DATA(i) = '0' then sda <= '0'; else sda <= 'Z'; end if;
            wait until falling_edge(scl);
        end loop;
        sda <= 'Z';

        -- NACK dari master, lalu STOP
        wait until rising_edge(sda) and to_x01(scl) = '1';
        report "Slave: kondisi STOP terdeteksi" severity note;
        wait;
    end process;

    ----------------------------------------------------------------------
    -- Stimulus
    ----------------------------------------------------------------------
    stim_proc : process
    begin
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        wait for 20 * CLK_PERIOD;

        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';

        wait until done = '1' for 2 ms;
        assert done = '1' report "TIMEOUT: transaksi tidak selesai" severity failure;

        wait for 10 * CLK_PERIOD;
        assert ack_error = '0' report "ack_error = 1 (slave tidak ACK)" severity error;
        assert data_out = SLAVE_DATA
            report "Data baca salah: " & integer'image(to_integer(unsigned(data_out)))
            severity error;
        report "tb_i2c_master SELESAI - data_out = " &
               integer'image(to_integer(unsigned(data_out))) & " (harapan 25 = 0x19)" severity note;

        wait for 50 us;
        sim_done <= true;
        wait;
    end process;
end Behavioral;
