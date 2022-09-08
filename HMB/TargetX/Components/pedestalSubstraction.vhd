library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.roling_register_p.all;
  use work.xgen_axiStream_32.all;
  use work.xgen_klm_scrod_bus.all;
  use work.klm_scint_globals.all;

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.xgen_axiStream_32.all;
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


Library work;
  use work.all;

Library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

  use ieee.std_logic_unsigned.all;
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

  use work.CSV_UtilityPkg.all;
  use work.xgen_axistream_serialdataconfig.all;
  use work.xgen_serialdatarout_p.all;

  use work.xgen_ramHandler_32_10.all;

  use work.TX_outStream_handler.all;

entity pedestalSubstraction is
  port (
    globals :  in globals_t := globals_t_null;

    configDataIn_m2s :  in axisStream_serialdataconfig_m2s := axisStream_serialdataconfig_m2s_null;
    configDataIn_s2m :  out  axisStream_serialdataconfig_s2m  := axisStream_serialdataconfig_s2m_null;

    dataIn_m2s   :  in  axisStream_32_m2s := axisStream_32_m2s_null;
    dataIn_s2m   :  out axisStream_32_s2m  := axisStream_32_s2m_null;

    dataOut_m2s  : out axisStream_32_m2s := axisStream_32_m2s_null;
    dataOut_s2m  : in  axisStream_32_s2m  := axisStream_32_s2m_null
  );
end entity;

architecture rtl of pedestalSubstraction is


  signal dataBuff_m2s  :  axisStream_32_m2s := axisStream_32_m2s_null;
  signal  dataBuf_s2m  :   axisStream_32_s2m  := axisStream_32_s2m_null;

    signal row : std_logic_vector(15 downto 0) := (others => '0');
    signal row1 : std_logic_vector(15 downto 0) := (others => '0');



  signal ramh_m2s : ram_handle_m2s:= ram_handle_m2s_null;
  signal ramh_s2m : ram_handle_s2m:= ram_handle_s2m_null;

  signal ramh_m_m2s : ram_handle_m2s:= ram_handle_m2s_null;
  signal ramh_m_s2m : ram_handle_s2m:= ram_handle_s2m_null;

  -- an array "array of array" type

  signal useMem : std_logic_vector( 31 downto 0) := (others => '0');


  signal ped : CWord16Array(31 downto 0) := (others => (others => '0'));
  signal   i_reg           :  registerT:= registerT_null;


  type address_cl is record 
    sample : std_logic_vector(4 downto 0); 
    channel: std_logic_vector(7 downto 0); 
    row : std_logic_vector(2 downto 0); 
    column : std_logic_vector (5 downto 0);
    asic : std_logic_vector(3 downto 0);
  end record;

  constant address_cl_null : address_cl:= (
    sample => (others => '0'),
    channel => (others => '0'),
    row => (others => '0'),
    column => (others => '0'),
    asic => (others => '0')
  );




  function get_address_cl(address_in : address_cl) return  std_logic_vector is 
    variable ret : std_logic_vector(7 downto 0) := (others => '0');
  begin 



    ret  :=    address_in.row(2 downto 0) & address_in.sample(4 downto 0) ;

    return ret;
  end ;

  function get_address_from_header(dataBuffheader : std_logic_vector; streamIndex : std_logic_vector  ) return  std_logic_vector is 
    variable ret : std_logic_vector(7 downto 0) := (others => '0');
    variable  addr :  address_cl := address_cl_null;
  begin 

    addr.sample :=  tx_get_sample(dataBuffheader);  
    addr.row :=   tx_get_row(dataBuffheader);
    addr.column :=   tx_get_column(dataBuffheader);
    addr.asic :=    tx_get_ASIC_NUM(dataBuffheader);
    addr.channel := streamIndex;

    ret  := get_address_cl(addr);

    return ret;
  end ;


  function get_error_code(next_dataconfig: serialdataconfig; dataBuffer : std_logic_vector) return std_logic_vector is
    variable dataBuffError: std_logic_vector(31 downto 0);
  begin
    dataBuffError := dataBuffer;

    if next_dataconfig.ASIC_NUM /= tx_get_ASIC_NUM(dataBuffer) then 
      dataBuffError := x"0a000" & next_dataconfig.ASIC_NUM & X"0" &  tx_get_ASIC_NUM(dataBuffer);

    end if;

    if next_dataconfig.row_Select /= tx_get_row(dataBuffer) then 
      dataBuffError := x"0b000"   & "0" &  next_dataconfig.row_Select  & X"0" & "0" &  tx_get_row(dataBuffer);
    end if;

    if next_dataconfig.column_select /= tx_get_column(dataBuffer) then 
      dataBuffError := x"0c0" & "00" &   next_dataconfig.column_select & x"0" & "00" &  tx_get_column(dataBuffer);
    end if;
    return dataBuffError;
  end function;

begin


  process(globals.clk) is 

    variable rx_config:  axisStream_serialdataconfig_slave := axisStream_serialdataconfig_slave_null;
    variable configdata : serialdataconfig; 
    ---------------------------------------------------------
    variable  addr :  address_cl := address_cl_null;
    variable ramh : ram_handle_master := ram_handle_master_null;
    variable rx : axisStream_32_slave:= axisStream_32_slave_null;
    variable dataBuffer: std_logic_vector(31 downto 0);
    variable tx  : axisStream_32_master  := axisStream_32_master_null;
    variable streamIndex  : std_logic_vector(7 downto 0) := (others => '0');
    variable sample : integer := 0;
    variable dataBuffError: std_logic_vector(31 downto 0);
    variable dataBuffheader: std_logic_vector(31 downto 0);

    variable ped_Buff: std_logic_vector(15 downto 0);

    variable request_address : std_logic_vector(7 downto 0) := (others => '0');

    variable useMem1 : std_logic_vector( 31 downto 0) := (others => '0');
    ----------------------------------------------


    --variable  channel_old : std_logic_vector(15 downto 0) := (others => '0');
    --variable  row_old : std_logic_vector(15 downto 0) := (others => '0');
    --variable  column_old : std_logic_vector(15 downto 0) := (others => '0');
    --variable  asic_old : std_logic_vector(15 downto 0) := (others => '0');

    --variable  counter : integer := 0;



  begin 
    if rising_edge(globals.clk) then 
      pull(rx, dataIn_m2s);
      pull(tx, dataBuf_s2m);

  --    if useMem1 /=  x"00000004" then
        pull(ramh ,ramh_s2m);
    --  end if;
      pull(rx_config, configDataIn_m2s);

      if isReceivingData(rx_config) then 
        read_data(rx_config, configdata);
      end if;

      ----------------------------------------------------------------------------------------------------

      if isReceivingData(rx) and ready_to_send(tx) then


        observe_data(rx, dataBuffer);

        if streamIndex = x"00" then 
          --------------------------------
          --  Header 1--------------------
          read_data(rx, dataBuffheader);
          sample :=  to_integer(unsigned( tx_get_sample(dataBuffheader))); 
          dataBuffError := get_error_code(configdata,  dataBuffheader);

          request_address :=get_address_from_header(dataBuffheader,streamIndex);
          request_Data(ramh, request_address);
          send_data(tx ,streamIndex & x"11" & dataBuffheader(15 downto 0));
          streamIndex := streamIndex +1;
        elsif streamIndex  = x"01" then
          --------------------------------
          --  Header 2 -------------------
          read_data(rx, dataBuffer);
          dataBuffer := dataBuffError;
          useMem1:= useMem;
          send_data(tx , streamIndex & x"22" & useMem1(15 downto 0));
          streamIndex := streamIndex +1;
        elsif streamIndex > x"01" and not IsEndOfStream(rx) then 
          --------------------------------
          --  data    --------------------
          if useMem1 = x"00000000" then
            request_address :=get_address_from_header(dataBuffheader,streamIndex);
            request_Data(ramh, request_address);
            if isReady2Load(ramh, request_address) then 
              read_data(rx, dataBuffer);
              read_Data(ramh, request_address, ped_Buff);
              dataBuffer(15 downto 0) := dataBuffer(15 downto 0) - ped_Buff;
              send_data(tx ,streamIndex& x"33" & dataBuffer(15 downto 0));
              streamIndex := streamIndex +1;
            end if;
          elsif useMem1 = x"00000001" then
            read_data(rx, dataBuffer);
            dataBuffer := std_logic_vector(to_unsigned(sample, dataBuffer'length));
            send_data(tx ,streamIndex & x"44" & dataBuffer(15 downto 0));
            streamIndex := streamIndex +1;
          elsif useMem1 = x"00000002" then
            request_address :=get_address_from_header(dataBuffheader,streamIndex);
            request_Data(ramh, request_address);
            if isReady2Load(ramh, request_address) then 
              read_data(rx, dataBuffer);
              read_Data(ramh, request_address, ped_Buff);
              --dataBuffer(15 downto 0) := ped_Buff;
              send_data(tx ,streamIndex& x"55" & ped_Buff(15 downto 0));
              streamIndex := streamIndex +1;
            end if;
          elsif useMem1 = x"00000003" then
            -- skip pedestal substraction 
            read_data(rx, dataBuffer);
            send_data(tx ,dataBuffer);
            streamIndex := streamIndex +1;

          elsif useMem1 = x"00000004" then
            read_data(rx, dataBuffer);
            ramh_m2s.readAddress <=get_address_from_header(dataBuffheader,streamIndex);
            send_data(tx ,streamIndex & x"88" & ramh_s2m.readData);
          else 
            read_data(rx, dataBuffer);
            -- dataBuffer := dataBuffer - ped(sample );
            request_address :=get_address_from_header(dataBuffheader,streamIndex);
            request_Data(ramh, request_address);
            dataBuffer:= (others => '0');
            dataBuffer(7 downto 0) := ramh.txrx.readAddress;
            send_data(tx ,streamIndex & x"66" & dataBuffer(15 downto 0));
            streamIndex := streamIndex +1;
          end if;
        elsif IsEndOfStream(rx) then 
          --------------------------------
          --  tail    --------------------
          read_data(rx, dataBuffer);
          send_data(tx ,streamIndex & x"77" & dataBuffer(15 downto 0));
          streamIndex := (others => '0');
        end if;
        Send_end_Of_Stream(tx, IsEndOfStream(rx));
      end if;
      -------------------------------------------------------------------------------------------------------------------------------------------------------





 

      push(rx_config, configDataIn_s2m);


--      if useMem1 /=  x"00000004" then
        push(ramh , ramh_m2s);
  --    end if;

      push(tx, dataBuff_m2s);
      push (rx, dataIn_s2m);
    end if;
  end process;

  
 outDelay : entity work.axiStreamDelayBuffer 
    generic map(
      Depth => 5
    ) port map (
      globals => globals,

      data_in_m2s  => dataBuff_m2s,
      data_in_s2m  => dataBuf_s2m,

      data_out_m2s =>    dataOut_m2s,  
      data_out_s2m =>    dataOut_s2m  

    );
  
  
  process(globals.clk) is 
    variable ramh_m : ram_handle_master := ram_handle_master_null;
    variable  addr :  address_cl := address_cl_null;
  


   
  begin

    if rising_edge(globals.clk) then
      
      pull(ramh_m ,ramh_m_s2m);

      read_data_s(i_reg, useMem, register_val.pedestal_useMem);
    --  read_data(i_reg, addr.channel, register_val.pedestal_channel);
      read_data_s(i_reg, row, register_val.pedestal_row);
   --   read_data(i_reg, addr.column, register_val.pedestal_column);
   ---read_data(i_reg, addr.asic, register_val.pedestal_asic);
    
      row1 <= row;
      for i in 0 to 31 loop
        read_data_s(i_reg,  ped(i), register_val.pedestal_start + i);
      end loop;
      if isReady2Store(ramh_m) then


        addr.row := row1(2 downto 0);

        Store_Data(ramh_m,  get_address_cl(addr),  ped(  to_integer(unsigned(addr.sample)) ) );

        if addr.sample  < 31 then 
          addr.sample  := addr.sample  + 1;
        else 
          addr.sample  := (others => '0');
        end if;

      end if;

      push(ramh_m , ramh_m_m2s);
    end if;
  end process;

  ram : entity work.bram_sdp_cc  generic map (
    DATA     => 16,
    ADDR     => 8
  ) port map (
      -- Port A
    clk   => globals.clk,
    wea    => ramh_m_m2s.writeEnable,
    addra  => ramh_m_m2s.writeAddress,
    dina   => ramh_m_m2s.writeData,
    -- Port B
    addrb  => ramh_m2s.readAddress,
    doutb  => ramh_s2m.readData
    );




  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  10
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );
end architecture;