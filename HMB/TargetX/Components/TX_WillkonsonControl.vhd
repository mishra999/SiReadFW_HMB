Library work;
  use work.all;

Library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  
  use ieee.std_logic_unsigned.all;
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;
  use work.roling_register_p.all;
  use work.xgen_SerialDataRout_p.all;
  use work.xgen_Counter.all;  
  use work.xgen_klm_scrod_bus.all;
  use work.xgen_axiStream_SerialDataConfig.all;
  use work.klm_scint_globals.all;

entity TX_WillkonsonControl is
  port (
    
    globals : globals_t := globals_t_null;    

    axConfigIn_m2s  : in axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigIn_s2m  : out axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;
    
    axConfigOut_m2s  : out axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigOut_s2m  : in  axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;

    --BUS A Specific Signals
    TX_samplingSignals : out TXSamplingSignals_s2m := TXSamplingSignals_s2m_null
  );
end entity;

architecture rtl of TX_WillkonsonControl is

  
  signal RolingCounterMax : std_logic_vector(15 downto 0) := x"AFFF";

  signal i_skipWillk : std_logic :='0'; 
  
  signal smapling_clear : time_span16 := time_span16_null;
  

  signal RD_ENA : time_span16 := time_span16_null;


  signal RD_ROWSEL_S : time_span16 := time_span16_null;

  signal RD_COLSEL_S : time_span16 := time_span16_null;
  

  
  
  signal RAMP : time_span16 := time_span16_null;

  

  
  signal  i_RD_ROWSEL_IN         : std_logic_vector(2 downto 0);
  signal i_RD_COLSEL_IN         : std_logic_vector(5 downto 0);

  signal   i_reg           :  registerT:= registerT_null;
  
  signal skipWillk : std_logic_vector(0 downto 0):= (others => '0');
begin
  
  
  process(globals.clk) is 
    variable cnt : counter_16:=counter_16_null;
    variable ConfigRX : axisStream_serialdataconfig_slave := axisStream_serialdataconfig_slave_null;
    variable ConfigTX : axisStream_serialdataconfig_master := axisStream_serialdataconfig_master_null;
    variable v_configDataIn    : SerialDataConfig := SerialDataConfig_null;
    variable endOfStream: boolean:=false;
  begin 
    if rising_edge(globals.clk) then
      pull(ConfigRX, axConfigIn_m2s);
      pull(ConfigTX,axConfigOut_s2m);
      
      pull(cnt);


      
      if isReceivingData(ConfigRX) and isReady(cnt) then 
        read_data(ConfigRX, v_configDataIn);
        endOfStream := IsEndOfStream(ConfigRX);
        if v_configDataIn.force_test_pattern = '0' and  i_skipWillk = '0'  then 
          StartCountTo(cnt,RolingCounterMax);
        else
          StartCountTo(cnt, x"0000" );
        end if;
        
        i_RD_ROWSEL_IN <= v_configDataIn.row_Select;
        i_RD_COLSEL_IN <= v_configDataIn.column_select;
     
      end if;

       if isDone(cnt) and ready_to_send(ConfigTX) then 
         send_data(ConfigTX , v_configDataIn);
         Send_end_Of_Stream(ConfigTX,endOfStream);
         reset(cnt);
       end if;

        TX_samplingSignals.clr                  <= InTimeWindowSl_r(cnt,  smapling_clear);
        TX_samplingSignals.read_enable          <= InTimeWindowSl_r(cnt,  RD_ENA);
        TX_samplingSignals.ramp                 <= InTimeWindowSl_r(cnt,  RAMP);
        
        TX_samplingSignals.read_row_select_s    <= InTimeWindowSLV_r(cnt , RD_ROWSEL_S, i_RD_ROWSEL_IN);
        TX_samplingSignals.read_column_select_s <= InTimeWindowSLV_r( cnt , RD_COLSEL_S,  i_RD_COLSEL_IN);



      push(ConfigTX,axConfigOut_m2s);
      push(ConfigRX, axConfigIn_s2m);
    end if;
  end process;
  
  


  
  process(globals.clk) is 
     
  begin 
    if rising_edge(globals.clk) then

      
      read_data_s( i_reg,  smapling_clear.min     , register_val.CLR_min     );
      read_data_s( i_reg,  smapling_clear.max     , register_val.CLR_max     );
      read_data_s( i_reg,  RD_ENA.min         , register_val.RD_ENA_min         );
      read_data_s( i_reg,  RD_ENA.max         , register_val.RD_ENA_max         );
      read_data_s( i_reg,  RD_ROWSEL_S.min    , register_val.RD_ROWSEL_S_min    );
      read_data_s( i_reg,  RD_ROWSEL_S.max    , register_val.RD_ROWSEL_S_max    );
      read_data_s( i_reg,  RD_COLSEL_S.min    , register_val.RD_COLSEL_S_min    );
      read_data_s( i_reg,  RD_COLSEL_S.max    , register_val.RD_COLSEL_S_max    );
 
      read_data_s( i_reg,  RAMP.min           , register_val.RAMP_min           );
      read_data_s( i_reg,  RAMP.max           , register_val.RAMP_max           );
      read_data_s( i_reg,  RolingCounterMax   , register_val.RolingCounterMax   );
      read_data_s(i_reg,  skipWillk, register_val.willkSkip);
      i_skipWillk<=skipWillk(0);
    end if;
  end process;
  

  
  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  5
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );
end architecture;