

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;
  use work.UtilityPkg.all;

  use work.roling_register_writer_pgk.all;
  use work.roling_register_reader_pgk.all;
  use work.type_conversions_pgk.all;
  use work.Imp_test_bench_pgk.all;

  use work.roling_register_p.all;
  use work.xgen_axistream_registert.all;
  use work.klm_scint_globals.all;
  use work.xgen_klm_scrod_bus.all;

entity roling_register_eth is
  port (
    clk : in std_logic;
--    slowClk : in std_logic;
    TxDataChannel : out  DWORD := (others => '0');
    TxDataValid   : out  sl := '0';
    TxDataLast    : out  sl := '0';
    TxDataReady   : in   sl := '0';
    RxDataChannel : in   DWORD := (others => '0');
    RxDataValid   : in   sl := '0';
    RxDataLast    : in   sl := '0';
    RxDataReady   : out  sl := '0';


    globals :  out globals_t := globals_t_null;
    TX_DAC_control_out : out  TX_DAC_control := TX_DAC_control_null
  );
end entity;

architecture rtl of roling_register_eth is





constant Throttel_max_counter : integer  := 10;
constant Throttel_wait_time : integer := 100000;

-- User Data interfaces



signal  i_TxDataChannels :  DWORD := (others => '0');
signal  i_TxDataValids   :  sl := '0';
signal  i_TxDataLasts    :  sl := '0';
signal  i_TxDataReadys   :  sl := '0';

constant FIFO_DEPTH : integer := 10;
constant COLNum : integer := 5;
signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
signal i_controls_out    : Imp_test_bench_reader_Control_t  := Imp_test_bench_reader_Control_t_null;
signal i_valid      : sl := '0';

constant COLNum_out : integer := 9;
signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));


signal data_in  : roling_register_reader_rec := roling_register_reader_rec_null;
signal data_out : roling_register_writer_rec := roling_register_writer_rec_null;



  
  signal i_globals :  globals_t := globals_t_null;
begin



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
  DUT :  entity work.roling_register port map(
    clk =>clk,
  --  slowClk  => slowClk,
    registerin_m2s =>  data_out.registerin_m2s,
    registerin_s2m =>data_out.registerin_s2m,
    globals  => i_globals --data_out.registersout


  );
  
 regB :  entity work.registerBuffer 
    generic map (
      Depth => 5
    ) port map (
      clk => clk,
      registersIn  => i_globals.reg,
      registersOut   => data_out.registersout
    );

 
  globals<= i_globals;

 TX_DAC_control : entity work.TX_DAC_control_w_regInterface port map(
   globals => i_globals,


   TX_DAC_control_out => TX_DAC_control_out
 );

  sl_to_slv(data_out.registerin_m2s.valid, i_data_out(0) );
  sl_to_slv(data_out.registerin_m2s.last, i_data_out(1) );
  slv_to_slv(data_out.registerin_m2s.data.address, i_data_out(2) );
  slv_to_slv(data_out.registerin_m2s.data.value, i_data_out(3) );
--  sl_to_slv(data_out.registerin_m2s.data.clk, i_data_out(4) );
  sl_to_slv(data_out.registerin_s2m.ready, i_data_out(5) );
  slv_to_slv(data_out.registersout.address, i_data_out(6) );
  slv_to_slv(data_out.registersout.value, i_data_out(7) );
--  sl_to_slv(data_out.registersout.clk, i_data_out(8) );

  --  </data_out_converter>

  -- <data_in_converter> 

  slv_to_sl(i_data(0), data_in.registerin_m2s.valid);
  slv_to_sl(i_data(1), data_in.registerin_m2s.last);
  slv_to_slv(i_data(2), data_in.registerin_m2s.data.address);
  slv_to_slv(i_data(3), data_in.registerin_m2s.data.value);
--  slv_to_sl(i_data(4), data_in.registerin_m2s.data.clk);

  --</data_in_converter>

  -- <connect_input_output>

  data_out.registerin_m2s <= data_in.registerin_m2s;

  -- </connect_input_output>


end architecture;

