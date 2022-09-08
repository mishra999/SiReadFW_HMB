library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.roling_register_p.all;

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

entity TX_write_handler is
  port (
    globals : globals_t := globals_t_null;    
    axConfigIn_m2s  : in axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigIn_s2m  : out axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;

    axConfigOut_m2s  : out axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigOut_s2m  : in  axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;

    TX_Write_signals :  out TXWriteSignals_s2m := TXWriteSignals_s2m_null

  );
end entity;

architecture rtl of TX_write_handler is

	type state is (writing, Processing);
	signal i_state : state; 
  signal WR_enable : time_span16 := time_span16_null;

  signal CLR : time_span16 := time_span16_null;


  signal   i_reg           :  registerT:= registerT_null;


  signal wr_always_brake : std_logic_vector(15 downto 0) := x"0000";

  signal wr_soft_trigger : std_logic_vector(15 downto 0) := x"0000";

  signal RolingCounterMax : std_logic_vector(15 downto 0) := x"000F";

begin

  process(globals.clk) is 
    variable cnt : counter_16:=counter_16_null;
    variable ConfigRX : axisStream_serialdataconfig_slave := axisStream_serialdataconfig_slave_null;
    variable ConfigTX : axisStream_serialdataconfig_master := axisStream_serialdataconfig_master_null;
    variable v_configDataIn    : SerialDataConfig := SerialDataConfig_null;
    variable v_configDataInObs    : SerialDataConfig := SerialDataConfig_null; 
    variable write_done :std_logic := '0';
  begin
    if rising_edge(globals.clk) then
      pull(ConfigRX, axConfigIn_m2s);
      pull(ConfigTX,axConfigOut_s2m);
      pull(cnt);


      if isReady(cnt) and   wr_soft_trigger > 0  and isReceivingData(ConfigRX) then 
        StartCountTo(cnt, wr_enable.max  );
      elsif  isReady(cnt)  and wr_soft_trigger = 0 then 
        StartCountTo(cnt, wr_enable.max  );
      end if;



      if isDone(cnt) and not isReceivingData(ConfigRX) then 
        reset(cnt);  
      end if;

      if (isDone(cnt) or wr_always_brake > 0 ) and isReceivingData(ConfigRX) and ready_to_send(ConfigTX) then
        read_data(ConfigRX, v_configDataIn);
        send_data(ConfigTX , v_configDataIn);
        Send_end_Of_Stream(ConfigTX, IsEndOfStream(ConfigRX));
				reset(cnt);
        StartCountFromTo(cnt, wr_enable.max , RolingCounterMax);
      end if;

      if isReceivingData(ConfigRX)  then 
        observe_data(ConfigRX, v_configDataInObs);
        if v_configDataInObs.force_test_pattern = '1' and ready_to_send(ConfigTX) then
          read_data(ConfigRX, v_configDataIn);
          send_data(ConfigTX , v_configDataIn);
          reset(cnt);
        end if;

      end if;


      TX_Write_signals.writeEnable_1 <=  InTimeWindowSlV_r(cnt, WR_enable,"11111");
      TX_Write_signals.writeEnable_2 <=  InTimeWindowSlV_r(cnt, WR_enable, "11111");
      TX_Write_signals.clear         <=  InTimeWindowSl_r(cnt,  CLR);

      push(ConfigTX,axConfigOut_m2s);
      push(ConfigRX, axConfigIn_s2m);
    end if;
  end process;

  process(globals.clk) is

  begin
    if rising_edge(globals.clk) then
      read_data_s( i_reg,  WR_enable.min      , register_val.WR_enable_min         );
      read_data_s( i_reg,  wr_enable.max      , register_val.WR_enable_max         );
      read_data_s( i_reg,  CLR.min            , register_val.WR_ADDRCLR_min       );
      read_data_s( i_reg,  CLR.max            , register_val.WR_ADDRCLR_max       );
      read_data_s( i_reg,  RolingCounterMax   , register_val.WR_RolingCounterMax  );
      read_data_s( i_reg,  wr_always_brake    , register_val.wr_always_brake );
      read_data_s( i_reg, wr_soft_trigger     , register_val.wr_soft_trigger );
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