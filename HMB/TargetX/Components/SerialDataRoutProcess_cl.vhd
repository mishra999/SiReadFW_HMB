-- Description:
--  Function: 
--  Modifications:
--

Library work;
  use work.all;

Library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use work.readout_definitions.all;
  use ieee.std_logic_unsigned.all;
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

  use work.roling_register_p.all;
  use work.xgen_SerialDataRout_p.all;
  use work.xgen_axiStream_32.all;

  use work.xgen_axiStream_SerialDataConfig.all;
  use work.xgen_klm_scrod_bus.all;
  use work.klm_scint_globals.all;
  use work.TX_outStream_handler.all;



entity SerialDataRoutProcess_cl is
  generic(
  AsicOffset : integer := 0
  );
  
  port (
    globals         : globals_t := globals_t_null;    
    axConfigIn_m2s  : in axisStream_serialdataconfig_m2s:= axisStream_serialdataconfig_m2s_null;
    axConfigIn_s2m  : out axisStream_serialdataconfig_s2m:= axisStream_serialdataconfig_s2m_null;




    serialdata_in_m2s : in   TXShiftRegisterSignals_m2s := TXShiftRegisterSignals_m2s_null;
    serialdata_in_s2m : out  TXShiftRegisterSignals_s2m := TXShiftRegisterSignals_s2m_null;


    -- fifo interface 

    axDataOut_m2s :  out axisStream_32_m2s := axisStream_32_m2s_null;
    axDataOut_s2m :  in  axisStream_32_s2m  := axisStream_32_s2m_null




  );
end SerialDataRoutProcess_cl;

architecture Behavioral of SerialDataRoutProcess_cl is
type state_t is (
  idle,
  running,
  waitForShiftout
);
  signal i_state : state_t:= idle;


  signal i_configDataIn    : SerialDataConfig := SerialDataConfig_null;
  signal i_next_readout_config   : readOutConfig := readOutConfig_null;
  constant sample_max : std_logic_vector(4 downto 0) := "11111";
  signal   i_reg           :  registerT:= registerT_null;
  ----------------------------------------
begin


  process(globals.clk) is

    variable  serialDataIn: SerialDataRout_s:= SerialDataRout_s_null;
    variable sample: std_logic_vector(4 downto 0) := (others => '0');
    variable dataBuffer : STD_LOGIC_VECTOR(15 downto 0) := (others =>'0');
 --   variable dataOutBuffer : STD_LOGIC_VECTOR(31 downto 0) := (others =>'0');
    variable axDataOut : axisStream_32_master_with_counter := axisStream_32_master_with_counter_null;
    variable ConfigRX : axisStream_serialdataconfig_slave := axisStream_serialdataconfig_slave_null;
    variable v_configDataIn    : SerialDataConfig := SerialDataConfig_null;
  begin 
    if rising_edge(globals.clk) then 
      pull(serialDataIn, serialdata_in_m2s);
      pull(axDataOut ,axDataOut_s2m);
      pull(ConfigRX,axConfigIn_m2s);


      if i_state = idle then

        serialDataIn.RO_Config := i_next_readout_config;

        if isReceivingData(ConfigRX) then
          read_data(ConfigRX, v_configDataIn);
          i_configDataIn <= v_configDataIn;
          i_state <= running;
          sample := v_configDataIn.sample_start;
          
        end if;

      elsif i_state = running then

        if IsReadyToRequestSample(serialDataIn)  then
          if i_configDataIn.force_test_pattern = '1' then
            request_test_Pattern(serialDataIn, i_configDataIn.ASIC_NUM);
            sample := sample_max;
          else 
            request_sample(serialDataIn, sample, i_configDataIn.ASIC_NUM);
          end if;
          if sample = sample_max or sample = i_configDataIn.sample_stop then 
            i_state <= waitForShiftout;
          end if;
          sample := sample + 1;
        end if;


      end if;




      if IsReceiving(serialDataIn) then
        send_data_at(axDataOut,0, tx_make_header(i_configDataIn.row_Select, i_configDataIn.column_select, i_configDataIn.ASIC_NUM ,  sample)   );
        send_data_at(axDataOut,1, tx_make_header(i_configDataIn.row_Select, i_configDataIn.column_select, i_configDataIn.ASIC_NUM ,  sample)   );

        if ready_to_send(axDataOut) then 
          read_data(serialDataIn,dataBuffer);
          
          send_data_begining_at(axDataOut,2, tx_make_data(serialDataIn.sr_counter, dataBuffer ) );
          Send_end_Of_Stream(axDataOut,IsEndOfStream(serialDataIn));
          if i_state = waitForShiftout and IsEndOfStream(serialDataIn) then
            i_state <= idle;
          end if;
        end if;
       
      end if;
      send_data_at(axDataOut, -1, x"FACEFACE");
      
      
      push(ConfigRX, axConfigIn_s2m);
      push(axDataOut, axDataOut_m2s);
      push(serialDataIn, serialdata_in_s2m);
    end if;

  end process;


  process(globals.clk) is
  begin
    if rising_edge(globals.clk) then

      read_data_s(i_reg,  i_next_readout_config.sr_clk_High   ,  register_val.Shift_register_clk_High);
      read_data_s(i_reg,  i_next_readout_config.sr_clk_Period ,  register_val.Shift_register_clk_Period);
      read_data_s(i_reg,  i_next_readout_config.sr_clk_start  ,  register_val.shift_register_clk_start);
      read_data_s(i_reg,  i_next_readout_config.sr_clk_stop   ,  register_val.shift_register_clk_stop);

      read_data_s(i_reg,  i_next_readout_config.sr_select_start  ,  register_val.shift_register_select_start);
      read_data_s(i_reg,  i_next_readout_config.sr_select_stop   ,  register_val.shift_register_select_stop);
      read_data_s(i_reg,  i_next_readout_config.sr_select_done   ,  register_val.shift_register_select_done);

    end if;
  end process;
  
  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  5
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );
  
end Behavioral;
