-- <header>Header; Nr_of_streams; recording TimeStamp; Operation; Number of packets; packateNr; Sending TimeStamp; datanotc_l_k; usrrst; rxdata; rxdatavalid; rxdatalast; rxdataready; txdata; txdatavalid; txdatalast; txdataready; serialclklck; triglinksync; dc_cmd; qb_wren; qb_rden; dc_resp; dc_resp_valid; evnt_flag; regaddr; regwrdata; regrddata; regreq; regop; regack; ldqblink; cmd_int_state; Tail</header>



library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;
  use work.UtilityPkg.all;

  use work.commandinterpreter_really_this_one_IO_pgk.all;
  use work.type_conversions_pgk.all;
  use work.Imp_test_bench_pgk.all;
  use work.xgen_klm_scrod_bus.all;
  use work.klm_scint_globals.all;

entity commandinterpreter_really_this_one_eth is
    generic (
        NUM_DCs : integer := 3
    ); 
  port (
    globals :  in globals_t := globals_t_null;
    
    TxDataChannel : out  DWORD := (others => '0');
    TxDataValid   : out  std_logic := '0';
    TxDataLast    : out  std_logic := '0';
    TxDataReady   : in   std_logic := '0';
    RxDataChannel : in   DWORD := (others => '0');
    RxDataValid   : in   std_logic := '0';
    RxDataLast    : in   std_logic := '0';
    RxDataReady   : out  std_logic := '0';


    RX_DC_P             : in slv(num_DC downto 0);  --SERIAL INPUT FROM DC
    RX_DC_N             : in slv(num_DC  downto 0);  --SERIAL INPUT FROM DC
    DC_CLK_P             : out slv(num_DC downto 0);  --25MHz clock to DC (fact check)--> {confirmed}
    DC_CLK_N            : out slv(num_DC downto 0); 
    TX_DC_N         : out slv(num_DC downto 0);  --Serial output to DC
    TX_DC_P             : out slv(num_DC downto 0);--Serial output to DC 
    SYNC_P             : out slv(num_DC downto 0); -- when '0' DC listens only, '1' DC reads back command
    SYNC_N             : out slv(num_DC downto 0);
    --            DC_RESET        : OUT slv(1 DOWNTO 0);        -- Commented by Shivang on Oct 8, 2020
    --Trigger to PMT SCRODs (mRICH)
    GLOBAL_EVENT_P    : out slv(3 downto 0);
    GLOBAL_EVENT_N    : out slv(3 downto 0)
    
    

    
  );
end entity;

architecture rtl of commandinterpreter_really_this_one_eth is
  
  constant Throttel_max_counter : integer  := 10;
  constant Throttel_wait_time : integer := 100000;

  -- User Data interfaces

  signal clk : std_logic := '0';

  signal  i_TxDataChannels :  DWORD := (others => '0');
  signal  i_TxDataValids   :  std_logic := '0';
  signal  i_TxDataLasts    :  std_logic := '0';
  signal  i_TxDataReadys   :  std_logic := '0';

  constant FIFO_DEPTH : integer := 10;
  constant COLNum : integer := 13;
  signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
  signal i_controls_out    : Imp_test_bench_reader_Control_t  := Imp_test_bench_reader_Control_t_null;
  signal i_valid      : std_logic := '0';
   
  constant COLNum_out : integer := 26;
  signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));
   

  signal data_in  : commandinterpreter_really_this_one_reader_rec := commandinterpreter_really_this_one_reader_rec_null;
  signal data_out : commandinterpreter_really_this_one_writer_rec := commandinterpreter_really_this_one_writer_rec_null;

begin
  
  clk <= globals.clk;
  
  u_reader : entity work.Imp_test_bench_reader
    generic map (
      COLNum => COLNum ,
      FIFO_DEPTH => FIFO_DEPTH
    ) port map (
      Clk          => clk,
      -- Incoming data
      rxData       => RxDataChannel,
      rxDataValid  => RxDataValid,
      rxDataLast   => RxDataLast,
      rxDataReady  => RxDataReady,
      -- outgoing data
      data_out     => i_data,
      valid        => i_valid,
      controls_out => i_controls_out
    );

  u_writer : entity work.Imp_test_bench_writer 
    generic map (
      COLNum => COLNum_out,
      FIFO_DEPTH => FIFO_DEPTH
    ) port map (
      Clk      => clk,
      -- Outgoing  data
      tXData      =>  i_TxDataChannels,
      txDataValid =>  i_TxDataValids,
      txDataLast  =>  i_TxDataLasts,
      txDataReady =>  i_TxDataReadys,
      -- incomming data 
      data_in    => i_data_out,
      controls_in => i_controls_out,
      Valid      => i_valid
    );
throttel : entity work.axiStreamThrottle 
    generic map (
        max_counter => Throttel_max_counter,
        wait_time   => Throttel_wait_time
    ) port map (
        clk           => clk,

        rxData         =>  i_TxDataChannels,
        rxDataValid    =>  i_TxDataValids,
        rxDataLast     =>  i_TxDataLasts,
        rxDataReady    =>  i_TxDataReadys,

        tXData          => TxDataChannel,
        txDataValid     => TxDataValid,
        txDataLast      => TxDataLast,
        txDataReady     =>  TxDataReady
    );
-- <DUT>
    DUT :  entity work.CI_test port map(
  clk => globals.clk,
  datanotc_l_k => data_out.datanotc_l_k,
  usrrst => data_out.usrrst,
  rxdata => data_out.rxdata,
  rxdatavalid => data_out.rxdatavalid,
  rxdatalast => data_out.rxdatalast,
  rxdataready => data_out.rxdataready,
  txdata => data_out.txdata,
  txdatavalid => data_out.txdatavalid,
  txdatalast => data_out.txdatalast,
  txdataready => data_out.txdataready,
  serialclklck => data_out.serialclklck,
  triglinksync => data_out.triglinksync,
  dc_cmd => data_out.dc_cmd,
  qb_wren => data_out.qb_wren,
  qb_rden => data_out.qb_rden,
  dc_resp => data_out.dc_resp,
  dc_resp_valid => data_out.dc_resp_valid,
  evnt_flag => data_out.evnt_flag,
  regaddr => data_out.regaddr,
  regwrdata => data_out.regwrdata,
  regrddata => data_out.regrddata,
  regreq => data_out.regreq,
  regop => data_out.regop,
  regack => data_out.regack,
  ldqblink => data_out.ldqblink,
  cmd_int_state => data_out.cmd_int_state, 
  RX_DC_P          => RX_DC_P         ,
  RX_DC_N          => RX_DC_N         ,
  DC_CLK_P         => DC_CLK_P        ,
  DC_CLK_N         => DC_CLK_N        ,
  TX_DC_N          => TX_DC_N         ,
  TX_DC_P          => TX_DC_P         ,
  SYNC_P           => SYNC_P          ,
  SYNC_N           => SYNC_N          ,

  GLOBAL_EVENT_P   => GLOBAL_EVENT_P  ,
  GLOBAL_EVENT_N   => GLOBAL_EVENT_N  
  
);
-- </DUT>


--  <data_out_converter>

sl_to_slv(data_out.datanotc_l_k, i_data_out(0) );
sl_to_slv(data_out.usrrst, i_data_out(1) );
slv_to_slv(data_out.rxdata, i_data_out(2) );
sl_to_slv(data_out.rxdatavalid, i_data_out(3) );
sl_to_slv(data_out.rxdatalast, i_data_out(4) );
sl_to_slv(data_out.rxdataready, i_data_out(5) );
slv_to_slv(data_out.txdata, i_data_out(6) );
sl_to_slv(data_out.txdatavalid, i_data_out(7) );
sl_to_slv(data_out.txdatalast, i_data_out(8) );
sl_to_slv(data_out.txdataready, i_data_out(9) );
--slv_to_slv(data_out.serialclklck, i_data_out(10) );
--slv_to_slv(data_out.triglinksync, i_data_out(11) );
--slv_to_slv(data_out.dc_cmd, i_data_out(12) );
slv_to_slv(data_out.qb_wren, i_data_out(13) );
slv_to_slv(data_out.qb_rden, i_data_out(14) );
--slv_to_slv(data_out.dc_resp, i_data_out(15) );
slv_to_slv(data_out.dc_resp_valid, i_data_out(16) );
sl_to_slv(data_out.evnt_flag, i_data_out(17) );
slv_to_slv(data_out.regaddr, i_data_out(18) );
slv_to_slv(data_out.regwrdata, i_data_out(19) );
slv_to_slv(data_out.regrddata, i_data_out(20) );
sl_to_slv(data_out.regreq, i_data_out(21) );
sl_to_slv(data_out.regop, i_data_out(22) );
sl_to_slv(data_out.regack, i_data_out(23) );
sl_to_slv(data_out.ldqblink, i_data_out(24) );
slv_to_slv(data_out.cmd_int_state, i_data_out(25) );

--  </data_out_converter>

-- <data_in_converter> 

slv_to_sl(i_data(0), data_in.datanotc_l_k);
slv_to_sl(i_data(1), data_in.usrrst);
slv_to_slv(i_data(2), data_in.rxdata);
slv_to_sl(i_data(3), data_in.rxdatavalid);
slv_to_sl(i_data(4), data_in.rxdatalast);
slv_to_sl(i_data(5), data_in.txdataready);
slv_to_slv(i_data(6), data_in.serialclklck);
slv_to_slv(i_data(7), data_in.triglinksync);
slv_to_slv(i_data(8), data_in.dc_resp);
slv_to_slv(i_data(9), data_in.dc_resp_valid);
slv_to_sl(i_data(10), data_in.evnt_flag);
slv_to_slv(i_data(11), data_in.regrddata);
slv_to_sl(i_data(12), data_in.regack);

--</data_in_converter>

-- <connect_input_output>

data_out.datanotc_l_k <= data_in.datanotc_l_k;
data_out.usrrst <= data_in.usrrst;
data_out.rxdata <= data_in.rxdata;
data_out.rxdatavalid <= data_in.rxdatavalid;
data_out.rxdatalast <= data_in.rxdatalast;
data_out.txdataready <= data_in.txdataready;
data_out.serialclklck <= data_in.serialclklck;







-- </connect_input_output>


end architecture;



library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;

  use work.UtilityPkg.all;
  use work.Eth1000BaseXPkg.all;
  use work.GigabitEthPkg.all;
  use work.BMD_definitions.all;
 
  use work.commandinterpreter_really_this_one_IO_pgk.all;
  use work.type_conversions_pgk.all;
  use work.Imp_test_bench_pgk.all;
  
  use work.UtilityPkg.all;
  use work.Eth1000BaseXPkg.all;
  use work.GigabitEthPkg.all;
  use work.xgen_klm_scrod_bus.all;
  use work.klm_scint_globals.all;
  use work.tdc_pkg.all;

  
entity commandinterpreter_really_this_one_top is
    generic (
        NUM_DCs : integer := 3
    ); 
   port (
    -- Direct GT connections
    gtTxP        : out sl;
    gtTxN        : out sl;
    gtRxP        :  in sl;
    gtRxN        :  in sl;
    gtClkP       :  in sl;
    gtClkN       :  in sl;
    -- Alternative clock input
    fabClkP      :  in sl;
    fabClkN      :  in sl;
    -- SFP transceiver disable pin
    txDisable    : out sl;

    RX_DC_P             : in slv(NUM_DCs downto 0);  --SERIAL INPUT FROM DC
    RX_DC_N             : in slv(NUM_DCs  downto 0);  --SERIAL INPUT FROM DC
    DC_CLK_P             : out slv(NUM_DCs downto 0);  --25MHz clock to DC (fact check)--> {confirmed}
    DC_CLK_N            : out slv(NUM_DCs downto 0); 
    TX_DC_N         : out slv(NUM_DCs downto 0);  --Serial output to DC
    TX_DC_P             : out slv(NUM_DCs downto 0);--Serial output to DC 
    SYNC_P             : out slv(NUM_DCs downto 0); -- when '0' DC listens only, '1' DC reads back command
    SYNC_N             : out slv(NUM_DCs downto 0);
    --            DC_RESET        : OUT slv(1 DOWNTO 0);        -- Commented by Shivang on Oct 8, 2020
    --Trigger to PMT SCRODs (mRICH)
    GLOBAL_EVENT_P    : out slv(3 downto 0);
    GLOBAL_EVENT_N    : out slv(3 downto 0)

  );
end entity;

architecture rtl of commandinterpreter_really_this_one_top is



  signal fabClk       : sl := '0';
  -- User Data interfaces




  signal globals :   globals_t := globals_t_null;
  signal TX_DAC_control_out :   TX_DAC_control := TX_DAC_control_null;

  constant NUM_IP_G        : integer := 2;
     

  
  signal ethClk125    : sl;
  --signal ethClk62    : sl;



  signal ethCoreMacAddr : MacAddrType := MAC_ADDR_DEFAULT_C;
     
  signal userRst     : sl;
  signal ethCoreIpAddr  : IpAddrType  := IP_ADDR_DEFAULT_C;
  constant ethCoreIpAddr1 : IpAddrType  := (3 => x"C0", 2 => x"A8", 1 => x"01", 0 => x"21");
  constant udpPort        :  std_logic_vector(15 downto 0):=  x"07D1" ;  -- 0x7d1

     
  signal will_clk: std_logic := '0';
  signal SST_clk_proto: std_logic := '0';
  signal SST_clk      : std_logic := '0';
     
     
  -- User Data interfaces
  signal userTxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
  signal userTxDataValids   : std_logic_vector(NUM_IP_G-1 downto 0);
  signal userTxDataLasts    : std_logic_vector(NUM_IP_G-1 downto 0);
  signal userTxDataReadys   : std_logic_vector(NUM_IP_G-1 downto 0);
  signal userRxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
  signal userRxDataValids   : std_logic_vector(NUM_IP_G-1 downto 0);
  signal userRxDataLasts    : std_logic_vector(NUM_IP_G-1 downto 0);
  signal userRxDataReadys   : std_logic_vector(NUM_IP_G-1 downto 0);
  


    
begin
  
  U_IBUFGDS : IBUFGDS port map ( I => fabClkP, IB => fabClkN, O => fabClk);


  
  

-- <Connecting the BUS to the pseudo class>
  


  
-- </Connecting the BUS to the pseudo class>


  --------------------------------
  -- Gigabit Ethernet Interface --
  --------------------------------
  U_S6EthTop : entity work.S6EthTop
    generic map (
      NUM_IP_G     => NUM_IP_G
    )
    port map (
      -- Direct GT connections
      gtTxP           => gtTxP,
      gtTxN           => gtTxN,
      gtRxP           => gtRxP,
      gtRxN           => gtRxN,
      gtClkP          => gtClkP,
      gtClkN          => gtClkN,
      -- Alternative clock input from fabric
      fabClkIn        => fabClk,
      -- SFP transceiver disable pin
      txDisable       => txDisable,
      -- Clocks out from Ethernet core
      ethUsrClk62     => open,
      ethUsrClk125    => ethClk125,
      -- Status and diagnostics out
      ethSync         => open,
      ethReady        => open,
      led             => open,
      -- Core settings in 
      macAddr         => ethCoreMacAddr,
      ipAddrs         => (0 => ethCoreIpAddr, 1 => ethCoreIpAddr1),
      udpPorts        => (0 => x"07D0",       1 => udpPort), --x7D0 = 2000,
      -- User clock inputs
      userClk         => ethClk125,
      userRstIn       => '0',
      userRstOut      => userRst,
      -- User data interfaces
      userTxData      => userTxDataChannels,
      userTxDataValid => userTxDataValids,
      userTxDataLast  => userTxDataLasts,
      userTxDataReady => userTxDataReadys,
      userRxData      => userRxDataChannels,
      userRxDataValid => userRxDataValids,
      userRxDataLast  => userRxDataLasts,
      userRxDataReady => userRxDataReadys
    );
  
  

    register_handler : entity work.roling_register_eth port map(
    clk => ethClk125,

    TxDataChannel =>   userTxDataChannels(0),
    TxDataValid  =>   userTxDataValids(0),  
    TxDataLast  =>   userTxDataLasts(0) ,
    TxDataReady   => userTxDataReadys(0),
    RxDataChannel =>userRxDataChannels(0),
    RxDataValid  => userRxDataValids(0),
    RxDataLast   => userRxDataLasts(0),
    RxDataReady  => userRxDataReadys(0),


    globals => globals,
    TX_DAC_control_out => TX_DAC_control_out
  );
  
 
  
  
  
  u_dut  : entity work.commandinterpreter_really_this_one_eth
    port map (
      globals => globals,
      -- Incoming data
      RxDataChannel => userRxDataChannels(1),
      rxDataValid   => userRxDataValids(1),
      rxDataLast    => userRxDataLasts(1),
      rxDataReady   =>  userRxDataReadys(1),
      -- outgoing data  
      TxDataChannel   => userTxDataChannels(1),
      TxDataValid     => userTxDataValids(1),
      txDataLast      => userTxDataLasts(1) ,
      TxDataReady     =>  userTxDataReadys(1),

      RX_DC_P          => RX_DC_P         ,
      RX_DC_N          => RX_DC_N         ,
      DC_CLK_P         => DC_CLK_P        ,
      DC_CLK_N         => DC_CLK_N        ,
      TX_DC_N          => TX_DC_N         ,
      TX_DC_P          => TX_DC_P         ,
      SYNC_P           => SYNC_P          ,
      SYNC_N           => SYNC_N          ,
                       
      GLOBAL_EVENT_P   => GLOBAL_EVENT_P  ,
      GLOBAL_EVENT_N   => GLOBAL_EVENT_N  
    );


 

 



end architecture;

