library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_lite_gpio_v1_0 is
  Generic (
    C_S_AXI_ADDR_WIDTH : integer := 4;   -- 4 register -> bit [3:2] pilih register
    C_S_AXI_DATA_WIDTH : integer := 32
  );
  Port (
    S_AXI_ACLK    : in STD_LOGIC;
    S_AXI_ARESETN : in STD_LOGIC;

    -- Write address channel
    S_AXI_AWADDR : in
    STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID : in STD_LOGIC;
    S_AXI_AWREADY : out STD_LOGIC;

    -- Write data channel
    S_AXI_WDATA   : in
    STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WVALID : in STD_LOGIC;
    S_AXI_WREADY : out STD_LOGIC;

    -- Write response channel
    S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
    S_AXI_BVALID : out STD_LOGIC;
    S_AXI_BREADY : in STD_LOGIC;

    -- Read address channel
    S_AXI_ARADDR : in
    STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID : in STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;

    -- Read data channel
    S_AXI_RDATA   : out
    STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
    S_AXI_RVALID : out STD_LOGIC;
    S_AXI_RREADY : in STD_LOGIC;

    -- Sisi luar IP
    gpio_out      : out STD_LOGIC_VECTOR(15 downto 0); -- ke LED
    gpio_in       : in STD_LOGIC_VECTOR(15 downto 0)   -- dari switch (Tugas 1)
  );
end axi_lite_gpio_v1_0;

architecture rtl of axi_lite_gpio_v1_0 is

  -- reg1 TIDAK disimpan: isinya langsung dari gpio_in (read-only)
  signal reg0 : STD_LOGIC_VECTOR(31 downto 0) :=
  (others => '0'); -- LED
  signal reg2 : STD_LOGIC_VECTOR(31 downto 0) :=
  (others => '0');
  signal reg3 : STD_LOGIC_VECTOR(31 downto 0) :=
  (others => '0');

  -- Jalur tulis
  signal aw_done : STD_LOGIC := '0'; -- alamat sudah diterima
  signal w_done   : STD_LOGIC := '0'; -- data sudah diterima
  signal awaddr_q : STD_LOGIC_VECTOR(1 downto 0)
  := (others => '0');
  signal wdata_q : STD_LOGIC_VECTOR(31 downto 0)
  := (others => '0');
  signal bvalid_i : STD_LOGIC := '0';

  -- Jalur baca
  signal rvalid_i : STD_LOGIC := '0';
  signal rdata_i : STD_LOGIC_VECTOR(31 downto 0)
  := (others => '0');

begin

  ------------------------------------------------
  -- JALUR TULIS: tunggu alamat DAN data, baru tulis ke register
  ------------------------------------------------

  S_AXI_AWREADY <= '1' when (aw_done = '0' and bvalid_i = '0') else '0';
  S_AXI_WREADY <= '1' when (w_done = '0' and bvalid_i = '0') else '0';
  S_AXI_BRESP   <= "00";               -- OKAY
  S_AXI_BVALID <= bvalid_i;

  write_proc : process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        reg0 <= (others => '0');
        reg2 <= (others => '0');
        reg3 <= (others => '0');
        aw_done <= '0';
        w_done   <= '0';
        bvalid_i <= '0';
      else

        -- 1) Tangkap alamat (handshake AWVALID & AWREADY)
        if aw_done = '0' and bvalid_i = '0' and S_AXI_AWVALID = '1' then
          aw_done <= '1';
          awaddr_q <= S_AXI_AWADDR(3 downto 2);
        end if;

        -- 2) Tangkap data (handshake WVALID & WREADY)
        if w_done = '0' and bvalid_i = '0' and S_AXI_WVALID = '1' then
          w_done <= '1';
          wdata_q <= S_AXI_WDATA;
        end if;

        -- 3) Alamat & data sudah lengkap -> tulis, lalu beri respons
        if aw_done = '1' and w_done = '1' and bvalid_i = '0' then
          case awaddr_q is
            when "00"   => reg0 <= wdata_q;
            when "10"   => reg2 <= wdata_q;
            when "11"   => reg3 <= wdata_q;
            when others => null;       -- "01" = reg1, read-only
          end case;
          bvalid_i <= '1';
          aw_done   <= '0';
          w_done    <= '0';
        end if;

        -- 4) Respons diterima master
        if bvalid_i = '1' and S_AXI_BREADY = '1' then
          bvalid_i <= '0';
        end if;

      end if;
    end if;
  end process;

  ------------------------------------------------
  -- JALUR BACA
  ------------------------------------------------

  S_AXI_ARREADY <= '1' when rvalid_i = '0' else '0';
  S_AXI_RDATA   <= rdata_i;
  S_AXI_RRESP   <= "00";               -- OKAY
  S_AXI_RVALID <= rvalid_i;

  read_proc : process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        rvalid_i <= '0';
        rdata_i <= (others => '0');
      else
        if rvalid_i = '0' and S_AXI_ARVALID = '1' then
          rvalid_i <= '1';
          case S_AXI_ARADDR(3 downto 2) is
            when "00"   => rdata_i <= reg0;
            when "01"   => rdata_i <= x"0000" & gpio_in;   -- reg1 = switch
            when "10"   => rdata_i <= reg2;
            when others => rdata_i <= reg3;
          end case;
        elsif rvalid_i = '1' and S_AXI_RREADY = '1' then
          rvalid_i <= '0';
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------
  -- Keluaran ke LED: reg0(15:0)
  ------------------------------------------------

  gpio_out <= reg0(15 downto 0);

end rtl;
