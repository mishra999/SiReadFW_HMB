

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;

  use work.UtilityPkg.all;
  use work.Eth1000BaseXPkg.all;
  use work.GigabitEthPkg.all;


  use work.type_conversions_pgk.all;
  use work.Imp_test_bench_pgk.all;
  
entity roling_register_top is
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
    txDisable    : out sl
  );
end entity;

architecture rtl of roling_register_top is


  signal fabClk       : sl := '0';
  -- User Data interfaces

  signal  TxDataChannel :  DWORD := (others => '0');
  signal  TxDataValid   :  sl := '0';
  signal  TxDataLast    :  sl := '0';
  signal  TxDataReady   :  sl := '0';
  signal  RxDataChannel :  DWORD := (others => '0');
  signal  RxDataValid   :  sl := '0';
  signal  RxDataLast    :  sl := '0';
  signal  RxDataReady   :  sl := '0';


  constant NUM_IP_G        : integer := 2;
     

  
  signal ethClk125    : sl;
  --signal ethClk62    : sl;
     
  signal ethCoreMacAddr : MacAddrType := MAC_ADDR_DEFAULT_C;
     
  signal userRst     : sl;
  signal ethCoreIpAddr  : IpAddrType  := IP_ADDR_DEFAULT_C;
  constant ethCoreIpAddr1 : IpAddrType  := (3 => x"C0", 2 => x"A8", 1 => x"01", 0 => x"21");
  constant udpPort        :  slv(15 downto 0):=  x"07D1" ;  -- 0x7d1
  signal tpData      : slv(31 downto 0);
  signal tpDataValid : sl;
  signal tpDataLast  : sl;
  signal tpDataReady : sl;
     
  -- Test registers
  -- Default is to send 1000 counter words once per second.
  signal waitCyclesHigh : slv(15 downto 0) := x"0773";
  signal waitCyclesLow  : slv(15 downto 0) := x"5940";
  signal numWords       : slv(15 downto 0) := x"02E9";
     
     
  -- User Data interfaces
  signal userTxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
  signal userTxDataValids   : slv(NUM_IP_G-1 downto 0);
  signal userTxDataLasts    : slv(NUM_IP_G-1 downto 0);
  signal userTxDataReadys   : slv(NUM_IP_G-1 downto 0);
  signal userRxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
  signal userRxDataValids   : slv(NUM_IP_G-1 downto 0);
  signal userRxDataLasts    : slv(NUM_IP_G-1 downto 0);
  signal userRxDataReadys   : slv(NUM_IP_G-1 downto 0);
    
begin
  
  U_IBUFGDS : IBUFGDS port map ( I => fabClkP, IB => fabClkN, O => fabClk);

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
  
  userTxDataChannels(0) <= tpData;
  userTxDataValids(0)   <= tpDataValid;
  userTxDataLasts(0)    <= tpDataLast;
  tpDataReady           <= userTxDataReadys(0);
  -- Note that the Channel 0 RX channels are unused here
  --userRxDataChannels;
  --userRxDataValids;
  --userRxDataLasts;
  userRxDataReadys(0) <= '1';
  
  
  U_TpGenTx : entity work.TpGenTx
    port map (
      -- User clock and reset
      userClk         => ethClk125,
      userRst         => userRst,
      -- Configuration
      waitCycles      => waitCyclesHigh & waitCyclesLow,
      numWords        => x"0000" & numWords,
      -- Connection to user logic
      userTxData      => tpData,
      userTxDataValid => tpDataValid,
      userTxDataLast  => tpDataLast,
      userTxDataReady => tpDataReady
    );
  
  userTxDataChannels(1) <=  TxDataChannel ;
  userTxDataValids(1)   <=  TxDataValid;
  userTxDataLasts(1)    <=  TxDataLast;
  TxDataReady           <=  userTxDataReadys(1);
  
  RxDataChannel        <=  userRxDataChannels(1);
  RxDataValid          <=  userRxDataValids(1);
  RxDataLast           <=  userRxDataLasts(1);
  userRxDataReadys(1)   <=  RxDataReady;     
  
  
  
  u_dut  : entity work.roling_register_eth
    port map (
      Clk       => ethClk125,
      -- Incoming data
      RxDataChannel => RxDataChannel,
      rxDataValid   => RxDataValid,
      rxDataLast    => RxDataLast,
      rxDataReady   => RxDataReady,
      -- outgoing data  
      TxDataChannel   => TxDataChannel,
      TxDataValid     => TxDataValid,
      txDataLast      => TxDataLast,
      TxDataReady     =>  TxDataReady
    );

end architecture;

