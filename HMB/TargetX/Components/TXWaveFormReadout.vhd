library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.targetx_WaveFormReadout_t.all;
  use work.targetx_WaveFormReadout_s.all;

  use work.TXWaveFormPGK.all;
  use work.StateMachneBase.all;
  use work.roling_register_p.all;
  use work.xgen_SerialDataRout_p.all;
  use work.xgen_axiStream_32.all;

  use work.xgen_axiStream_SerialDataConfig.all;
  use work.xgen_edgeDetection.all;
  use work.xgen_klm_scrod_bus.all;

  use work.klm_scint_globals.all;

entity TXWaveFormReadout is

  port (
    globals : globals_t := globals_t_null;

    axConfigIn_m2s  : in axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigIn_s2m  : out axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;


    TXBus_m2s : in   DataBus_m2s := DataBus_m2s_null;
    TXBus_s2m : out  DataBus_s2m := DataBus_s2m_null;

    TX_streamData     : out std_logic_vector(15 downto 0);


    axDataOut_m2s :  out axisStream_32_m2s := axisStream_32_m2s_null;
    axDataOut_s2m :  in  axisStream_32_s2m  := axisStream_32_s2m_null
  );
end entity;

architecture rtl of TXWaveFormReadout is

  signal input_delay_axConfigIn_m2s  : axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
  signal input_delay_axConfigIn_s2m  : axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;
  
  signal splitter_axConfigIn_m2s  : axisStream_serialdataconfig_m2s_a(1 downto 0):= (others => axisStream_serialdataconfig_m2s_null);
  signal splitter_axConfigIn_s2m  : axisStream_serialdataconfig_s2m_a(1 downto 0):= (others => axisStream_serialdataconfig_s2m_null);


  signal we_handler_axConfigIn_m2s  : axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
  signal we_handler_axConfigIn_s2m  : axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;

  signal outConverter_axDataOut_m2s :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal outConverter_axDataOut_s2m :  axisStream_32_s2m  := axisStream_32_s2m_null;



  signal pedestalSubstration_axDataOut_m2s :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal pedestalSubstration_axDataOut_s2m :  axisStream_32_s2m  := axisStream_32_s2m_null;

  
  signal sro_axDatainternal_m2s :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal sro_axDatainternal_s2m :  axisStream_32_s2m  := axisStream_32_s2m_null;






  signal  TX_sampling_axConfigOut_m2s  : axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
  signal  TX_sampling_axConfigOut_s2m  : axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;


begin






  TX_streamData <= TXBus_m2s.ShiftRegister.data_out;




 input_delay:  entity  work.InputBuffer_serialConfigData port map(
       globals => globals,
      axConfigIn_m2s  =>  axConfigIn_m2s ,
      axConfigIn_s2m  =>  axConfigIn_s2m ,

      in_deserialize_axConfigIn_m2s => input_delay_axConfigIn_m2s,
      in_deserialize_axConfigIn_s2m => input_delay_axConfigIn_s2m

    );
 
 splitter : entity work.axiStreamDeMUX_CONFIG 
   generic map (
     NumOfStreams => 2
   )
   port map(
     clk => globals.clk,
     rst => globals.rst,




     axDataIn_m2s => input_delay_axConfigIn_m2s,
     axDataIn_s2m => input_delay_axConfigIn_s2m,


     axDataOut_m2s => splitter_axConfigIn_m2s,
     axDataOut_s2m => splitter_axConfigIn_s2m
 );
  

  we_handler : entity work.TX_write_handler port map (
    globals => globals,

    axConfigIn_m2s => splitter_axConfigIn_m2s(0),
    axConfigIn_s2m => splitter_axConfigIn_s2m(0),

    axConfigOut_m2s  => we_handler_axConfigIn_m2s,
    axConfigOut_s2m  => we_handler_axConfigIn_s2m,

    TX_Write_signals => TXBus_s2m.WriteSignals

  );

  TX_sampling : entity work.TX_WillkonsonControl port map(
    globals => globals,

    axConfigIn_m2s  => we_handler_axConfigIn_m2s,
    axConfigIn_s2m  => we_handler_axConfigIn_s2m,

    axConfigOut_m2s =>TX_sampling_axConfigOut_m2s,
    axConfigOut_s2m =>TX_sampling_axConfigOut_s2m,


    --BUS A Specific Signals
    TX_samplingSignals => TXBus_s2m.SamplingSignals
  );

  sro :  entity work.SerialDataRoutProcess_cl port map(
    globals => globals,
    axConfigIn_m2s  => TX_sampling_axConfigOut_m2s,
    axConfigIn_s2m  => TX_sampling_axConfigOut_s2m,

    serialdata_in_m2s => TXBus_m2s.ShiftRegister,
    serialdata_in_s2m => TXBus_s2m.ShiftRegister,


    -- fifo interface 

    axDataOut_m2s => sro_axDatainternal_m2s,
    axDataOut_s2m => sro_axDatainternal_s2m

  );
  outConverter:  entity  work.SerialOutputCOnverter port map(
   globals => globals,

    axDataIn_m2s => sro_axDatainternal_m2s,
    axDataIn_s2m => sro_axDatainternal_s2m,

    axDataOut_m2s => outConverter_axDataOut_m2s,
    axDataOut_s2m => outConverter_axDataOut_s2m

  );

  pedSub : entity work.pedestalSubstraction port map(
      globals => globals,
      configDataIn_m2s =>   splitter_axConfigIn_m2s(1),
      configDataIn_s2m =>   splitter_axConfigIn_s2m(1),

      dataIn_m2s  => outConverter_axDataOut_m2s,
      dataIn_s2m  => outConverter_axDataOut_s2m,

      dataOut_m2s  => pedestalSubstration_axDataOut_m2s,
      dataOut_s2m  => pedestalSubstration_axDataOut_s2m
    );


  outfifo : entity work.fifo_cc_axi_32 generic map (
    DEPTH => 10
  ) port map (
    clk      => globals.clk,
    rst      => globals.rst,
    RX_m2s   =>  pedestalSubstration_axDataOut_m2s,
    RX_s2m   =>  pedestalSubstration_axDataOut_s2m,

    TX_m2s  => axDataOut_m2s,
    TX_s2m  => axDataOut_s2m


  );




end architecture;