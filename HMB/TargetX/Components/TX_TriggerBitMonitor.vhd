library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.klm_scint_globals.all;

  use work.tdc_pkg.all;
  use work.xgen_axistream_32.all;
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
    use ieee.std_logic_misc.all;
library work;
   	use work.tdc_pkg.all;
library unisim;
    use unisim.vcomponents.all;
    use work.roling_register_p.all;
    use work.optional_trigger_bits_p.all;
    
entity TX_TriggerBitMonitor is
  port (
    globals : globals_t := globals_t_null;
    TARGET_TB_in        : in tb_vec_type;
    TARGET_TB_out       : out tb_vec_type;
    BUSA_CLR_in         : in std_logic := '0';
    BUSA_CLR_out        : out std_logic := '0'
  );
end entity;

architecture rtl of TX_TriggerBitMonitor is

  signal RX_m2s   : axisStream_32_m2s := axisStream_32_m2s_null;
  signal RX_s2m   : axisStream_32_s2m := axisStream_32_s2m_null;

  signal TX_m2s   : axisStream_32_m2s := axisStream_32_m2s_null;
  signal TX_s2m   : axisStream_32_s2m   := axisStream_32_s2m_null;


  signal tb                   : std_logic_vector(5 downto 1);

  signal tdc_clk              : std_logic;
  
  signal extexn               : tb_ext_type:= (others => (others => '0'));
  signal trigger_mask         : std_logic_vector(extexn'length - 1 downto 0) := (others => '0');
  signal trigger_mask1         : std_logic_vector(15 downto 0) := x"0008";

  signal   i_reg           :  registerT:= registerT_null;
  signal edgedetection_tb_out :   optional_trigger_bit_t := optional_trigger_bit_t_null;


  function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return STD_LOGIC is
    -- pragma subpgm_id 401
    variable result: STD_LOGIC;
  begin
    result := '0';
    for i in ARG'range loop
      result := result or ARG(i);
    end loop;
    return result;
  end;


  procedure push_back(signal self : inout tb_ext_type;  data_in : std_logic_vector) is 
  begin 

    self <= data_in & self(self'length-1 downto 1);
  end procedure;


  function get_trigger_bits(self :  tb_ext_type;  bit_mask : std_logic_vector) return std_logic_vector is
    variable ret  : std_logic_vector(5 downto 1) := (others => '0');
  begin 
    
    for I in self'range loop
      if bit_mask(i) = '1' then
        ret := ret or self(I);
      end if;
    end loop;
    return ret;
  end function;

  function falling_edge(self : tb_ext_type) return boolean is
  begin 

    return  OR_REDUCE(self(self'length-1)) = '0' and OR_REDUCE(self(self'length-2)) = '1';
  end function;


  function rising_edge(self : tb_ext_type) return boolean is
  begin
    return  OR_REDUCE(self(0)) = '0' and OR_REDUCE(self(1)) = '1';
  end function;

  begin
  BUSA_CLR_out  <= BUSA_CLR_in;
  TARGET_TB_out(1 )  <= TARGET_TB_in(1 );

  tb <= TARGET_TB_in(1);

  tdc_clk<=  globals.clk;

  edgedetection : entity work.KLMTrigBitsEdgeDetection port map(
    clk => tdc_clk,
    tb_mask=>  trigger_mask1,
    tb_in  => tb,
    tb_out => edgedetection_tb_out
  );

  tdc_regs_pcs : process(tdc_clk)
begin
    if (tdc_clk'event and tdc_clk = '1') then
      TARGET_TB_out( 5 ) <= (others => '0');
        

      if is_valid(edgedetection_tb_out) then 
          TARGET_TB_out( 5 ) <= get_data(edgedetection_tb_out);
        end if;
    end if;
end process;



  fifo : entity work.fifo_cc_axi_32 port map(
    clk      => globals.clk,
    rst      => globals.rst,
    RX_m2s  => RX_m2s,
    RX_s2m  => RX_s2m,

    TX_m2s  => TX_m2s,
    TX_s2m   => TX_s2m
    
  );



  
  process(globals.clk) is
    variable rx: axisStream_32_slave:= axisStream_32_slave_null;
    variable tx : axisStream_32_master := axisStream_32_master_null;
    variable buff : STD_LOGIC_VECTOR(15 downto 0) := (others  => '0');
    variable index : STD_LOGIC_VECTOR(15 downto 0) := (others  => '0');
    variable rxbuff : STD_LOGIC_VECTOR(31 downto 0) := (others  => '0');
  begin 
    if rising_edge(globals.clk) then 
      pull(rx, RX_m2s);
      pull(tx, tX_s2m);
      
      for I in 1 to TDC_NUM_CHAN loop
        if OR_REDUCE(TARGET_TB_in(I)) ='1' and ready_to_send(tx) then 
          buff(4 downto 0)  := TARGET_TB_in(I)(5 downto 1);
          index := std_logic_vector(to_unsigned(I, index'length));
          send_data(tx , index & buff);
        end if;
      end loop;
      if BUSA_CLR_in = '1' and isReceivingData(rx) then
        read_data(rx, rxbuff);
       -- TARGET_TB_out(TDC_NUM_CHAN)(5 downto 1) <= rxbuff(4 downto 0);
      end if;

      push(rx, RX_s2m);
      push(tx, tX_m2s);      
    end if;
  end process;


  
  process(globals.clk) is 
     
  begin 
    if rising_edge(globals.clk) then

      
      read_data_s( i_reg,  trigger_mask1    , register_val.trigger_mask     );

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