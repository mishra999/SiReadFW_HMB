library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.klm_scint_globals.all;
  use work.xgen_SerialDataRout_p.all;
  use work.xgen_axiStream_32.all;

  use work.xgen_axiStream_SerialDataConfig.all;
  use work.xgen_edgeDetection.all;
  use work.xgen_klm_scrod_bus.all;

entity InputBuffer_serialConfigData is
  port (
    globals : globals_t := globals_t_null;
    axConfigIn_m2s  : in axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigIn_s2m  : out axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;
    
    in_deserialize_axConfigIn_m2s  : out axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    in_deserialize_axConfigIn_s2m  : in axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null
    
  );
end entity;

architecture rtl of InputBuffer_serialConfigData is

  
  signal in_serialize_axConfigInFifo_m2s :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal in_serialize_axConfigInFifo_s2m :  axisStream_32_s2m  := axisStream_32_s2m_null;  


  signal inDelay_axConfigInFifobuff_m2s :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal inDelay_axConfigInFifoBuff_s2m :  axisStream_32_s2m  := axisStream_32_s2m_null;  

  signal infifo_axConfigInFifoOut_m2s :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal infifo_axConfigInFifoOut_s2m :  axisStream_32_s2m  := axisStream_32_s2m_null;  
begin
  
  



  in_serialize:  process(globals.clk) is 

    variable configRX : axisStream_serialdataconfig_slave:= axisStream_serialdataconfig_slave_null;
    variable axConfigOut : axisStream_32_master:= axisStream_32_master_null;
    variable buff :serialdataconfig :=SerialDataConfig_null;
    variable buff_slv : std_logic_vector(31 downto 0 ) := (others => '0');
  begin 
    pull(configRX, axConfigIn_m2s  );
    pull(axConfigOut, in_serialize_axConfigInFifo_s2m  );
    if isReceivingData(configRX) and ready_to_send(axConfigOut) then 
      read_data(configRX,buff);
      serialize(buff, buff_slv);
      send_data(axConfigOut, buff_slv);

      Send_end_Of_Stream(axConfigOut, isEndOfStream(configRX));
    end if;

    push(configRX, axConfigIn_s2m  );
    push(axConfigOut,in_serialize_axConfigInFifo_m2s);
  end process;



  inDelay : entity work.axiStreamDelayBuffer 
    generic map(
      Depth => 5
    ) port map (
      globals => globals,

      data_in_m2s  => in_serialize_axConfigInFifo_m2s,
      data_in_s2m  => in_serialize_axConfigInFifo_s2m,

      data_out_m2s =>  inDelay_axConfigInFifobuff_m2s,
      data_out_s2m =>  inDelay_axConfigInFifoBuff_s2m

    );

  infifo : entity work.fifo_cc_axi_32 generic map (
    DEPTH => 10
  ) port map (
    clk      => globals.clk,
    rst      => globals.rst,
    RX_m2s   =>inDelay_axConfigInFifobuff_m2s,
    RX_s2m   =>inDelay_axConfigInFifoBuff_s2m,

    TX_m2s  => infifo_axConfigInFifoOut_m2s,
    TX_s2m  => infifo_axConfigInFifoOut_s2m


  );





  in_deserialize: process(globals.clk) is

    variable  axConfigIn : axisStream_32_slave := axisStream_32_slave_null;
    variable  configTX : axisStream_serialdataconfig_master := axisStream_serialdataconfig_master_null;
    variable  buff :serialdataconfig :=SerialDataConfig_null;
    variable  buff_slv : std_logic_vector(31 downto 0 ) := (others => '0');


  begin 
    if rising_edge(globals.clk)  then 
      pull(axConfigIn, infifo_axConfigInFifoOut_m2s  );
      pull(configTX, in_deserialize_axConfigIn_s2m);
      if isReceivingData(axConfigIn) and  ready_to_send(configTX)  then
        read_data(axConfigIn, buff_slv);
        deserialize(buff, buff_slv);
        send_data(configTX, buff );
        Send_end_Of_Stream(configTX,  isEndOfStream(axConfigIn));
      end if;
      push(configTX, in_deserialize_axConfigIn_m2s);
      push(axConfigIn, infifo_axConfigInFifoOut_s2m  );
    end if;
  end process;
end architecture;