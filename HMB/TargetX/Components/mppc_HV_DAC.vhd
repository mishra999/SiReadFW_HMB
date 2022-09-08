library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.klm_scint_globals.all;
  use work.roling_register_p.all;
  use work.xgen_axistream_32.all;

entity mppc_HV_DAC is
  port (
    globals : globals_t := globals_t_null;
    reg_out         : out registerT := registerT_null;  

    -- MPPC HV DAC
    BUSA_SCK_DAC           : out std_logic;
    BUSA_DIN_DAC           : out std_logic;
    BUSB_SCK_DAC           : out std_logic;
    BUSB_DIN_DAC           : out std_logic;
    --
    --target_tb16              : in std_logic_vector(1 to TDC_NUM_CHAN);

    TDC_CS_DAC               : out std_logic_vector(9 downto 0); 

    TDC_AMUX_S               : out std_logic_vector(3 downto 0); -- what the difference between these two?
    TOP_AMUX_S               : out std_logic_vector(3 downto 0); -- TODO: check schematic

    --- MPPC ADC
    SCL_MON                  : out STD_LOGIC;
    SDA_MON                  : inout STD_LOGIC;


    ---

    --TMP                      : out std_logic_vector(31 downto 0);

    TDC_DONE                 : in STD_LOGIC_VECTOR(9 downto 0); -- move to readout signals
    TDC_MON_TIMING           : in STD_LOGIC_VECTOR(9 downto 0)  -- add the ref to the programming of the TX chip


  );
end entity;

architecture rtl of mppc_HV_DAC is
  signal   i_reg           :  registerT:= registerT_null;
  -- MPPC DAC signals
  signal i_hv_sck_dac         : std_logic := '0';
  signal i_hv_din_dac         : std_logic := '0';
  signal i_tdc_cs_dac         : std_logic_vector(9 downto 0) := (others => '0');

  signal i_DAC_NUMBER   : STD_LOGIC_VECTOR(3 downto 0);
  signal i_DAC_ADDR     : STD_LOGIC_VECTOR(3 downto 0);
  signal i_DAC_VALUE    : STD_LOGIC_VECTOR(7 downto 0);

  signal i_WRITE_STROBE : STD_LOGIC;
  signal i_BUSY         : std_logic;


  signal i_sda_mon : std_logic;
  signal i_scl_mon : std_logic;

  signal MppcAdcAsicN               : std_logic_vector(3 downto 0); -- what the difference between these two?
  signal MppcAdcChanN               : std_logic_vector(3 downto 0); -- TODO: check schematic

  signal ADCdebug : std_logic_vector(15 downto 0) := (others => '0');
  signal RunADC : std_logic;
  signal  i_MppcAdcData     :std_logic_vector(11 downto 0);

  signal TX_REG_DATA_m2s     : axisStream_32_m2s := axisStream_32_m2s_null;
  signal TX_REG_DATA_s2m     : axisStream_32_s2m := axisStream_32_s2m_null;

  signal RX_REG_DATA_m2s     : axisStream_32_m2s := axisStream_32_m2s_null;
  signal RX_REG_DATA_s2m     : axisStream_32_s2m := axisStream_32_s2m_null;

  type state_t is (idle, sending, waiting);
  signal i_state : state_t := idle;
begin



  process(globals.clk) is 
    variable TX : axisStream_32_master:= axisStream_32_master_null;
    variable counter: std_logic_vector(15 downto 0) := (others => '0');
    variable buff : std_logic_vector(31 downto 0) := (others => '0');
  begin 
    if rising_edge(globals.clk) then
      pull(TX, TX_REG_DATA_s2m);
      counter := counter +1;
      RunADC <= '0';

      if i_reg.address(15 downto 8) =  x"C0" then 
        if ready_to_send(TX) then
			    buff(31 downto 16) :=i_reg.address;
		    	buff(15 downto 0) :=i_reg.value;
          send_data(TX, buff);
        end if;
      end if;

      read_data_s( i_reg,  MppcAdcAsicN   , register_val.MppcAdcAsicN );
      read_data_s( i_reg,  MppcAdcChanN   , register_val.MppcAdcChanN );
      read_data_s( i_reg,  ADCdebug ,       register_val.ADCdebug);
      if counter > 1000000 then
        RunADC <= '1';
        counter := (others => '0');
      end if;

      push(TX, TX_REG_DATA_m2s);
    end if;
  end process;

  reg_fifo : entity work.fifo_cc_axi_32 generic map (
    DATA_WIDTH => 32,
    DEPTH => 8
  ) port map (
    clk      =>   globals.clk,
    rst      =>   globals.rst,
    RX_m2s   => TX_REG_DATA_m2s ,
    RX_s2m   =>  TX_REG_DATA_s2m,

    TX_m2s  => RX_REG_DATA_m2s,
    TX_s2m  => RX_REG_DATA_s2m 


  );
  
  process(globals.clk) is 
    variable rx : axisStream_32_slave:= axisStream_32_slave_null;
    variable buff : STD_LOGIC_VECTOR(31 downto 0) := (others =>'0');
    variable mppc_word       : std_logic_vector(15 downto 0);
  begin 
    if rising_edge(globals.clk) then
      pull(rx, RX_REG_DATA_m2s);
      i_WRITE_STROBE <= '0';       
      case i_state is 
        when idle =>
          if isReceivingData(rx) then
            read_data(rx, buff);
            mppc_word := buff(23 downto 16) & buff(7 downto 0); 
            i_DAC_NUMBER  <= mppc_word(15 downto 12);  
            i_DAC_ADDR    <= mppc_word(11 downto 8);   
            i_DAC_VALUE   <= mppc_word(7 downto  0);   
            i_WRITE_STROBE <= '1';       
            i_state <= sending;
          end if;

        when sending => 
          if i_BUSY = '1' then
            i_state <= waiting;
          end if;
        when waiting =>
          if i_BUSY = '0' then
            i_state <= idle;
          end if;
        when others =>
          i_state <= idle;
      end case;
      push(rx, RX_REG_DATA_s2m);
    end if;
  end process;
  ---------------------------------------------------------------
  -- MPPC HV DACs
  ---------------------------------------------------------------
  mppc_dac_i : entity work.mppc_dacs_wrapper_dac088s085
    port map(
      ------------CLOCK-----------------
      clk           => globals.clk, 
      ------------DAC PARAMETERS--------
      DAC_NUMBER    => i_DAC_NUMBER,
      DAC_ADDR      => i_DAC_ADDR,
      DAC_VALUE     => i_DAC_VALUE,

      WRITE_STROBE  => i_WRITE_STROBE,
      busy          => i_BUSY,
      ------------HW INTERFACE----------
      SCK_DAC       => i_hv_sck_dac,
      DIN_DAC       => i_hv_din_dac,
      CS_DAC        => i_tdc_cs_dac,

      dbg1           => open,
      dbg2           => open
    );


  TDC_CS_DAC <= i_tdc_cs_dac;


  BUSA_SCK_DAC <= i_hv_sck_dac;
  BUSB_SCK_DAC <= i_hv_sck_dac;
  BUSA_DIN_DAC <= i_hv_din_dac;
  BUSB_DIN_DAC <= i_hv_din_dac;

  -------------------------------------------------------------------

  process(globals.clk)
  begin
    if rising_edge(globals.clk) then
      TDC_AMUX_S <= MppcAdcAsicN;   -- channel within daugter card
      TOP_AMUX_S <= MppcAdcChanN;    -- daughter number    FIXME: AsicN and ChanN are mixed up
    end if;
  end process;

  -----------------------------------------------------------------
  ---- MPPC Current measurement ADC: MPC3221
  -----------------------------------------------------------------
  mpc_adc_i: entity work.Module_ADC_MCP3221_I2C_new
    port map(
      clock         => globals.clk, -- i_CLOCK_MPPC_DAC,--i_CLOCK_FPGA_LOGIC,
      reset       => globals.rst,

      debugmode    => ADCdebug,

      sda          => i_sda_mon,
      scl          => i_scl_mon,

      runADC      => RunADC, --REG(63)(8)
      ADCOutput   => i_MppcAdcData  

    );
  reg_out.value <= "0000"&i_MppcAdcData;
  reg_out.address <= x"aba1";
  SDA_MON <= i_sda_mon ;
  SCL_MON <= i_scl_mon;
  ---------------------------------------------------------------
  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  10
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );


end architecture;