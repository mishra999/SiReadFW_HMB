library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use ieee.std_logic_unsigned.all;

  use work.roling_register_p.all;

  use work.xgen_edgeDetection.all;
  use work.xgen_axistream_32.all;
  use work.klm_scint_globals.all;
  use work.xgen_klm_scrod_bus.all;

entity TX_DAC_control_w_regInterface is
  generic ( 
    asicNumber : integer := 0
  );
  port (
    globals :  in globals_t := globals_t_null;


    TX_DAC_control_out : out  TX_DAC_control := TX_DAC_control_null
    
  );
end entity;

architecture rtl of TX_DAC_control_w_regInterface is

  
  
  
  signal  reg_data_m2s : axisStream_32_m2s := axisStream_32_m2s_null;  
  signal  reg_data_s2m : axisStream_32_s2m := axisStream_32_s2m_null;  





  signal   i_reg           :  registerT:= registerT_null;


begin

  DUT :  entity work.tx_dac_control_axi port map(
    clk => globals.clk,
    regin => globals.reg,
    reg_data_m2s => reg_data_m2s,
    reg_data_s2m => reg_data_s2m,
    sin  => TX_DAC_control_out.SIN,
    sclk => TX_DAC_control_out.SCLK,
    pclk => TX_DAC_control_out.PCLK
  );


  process(globals.clk) is
    variable regTX : axisStream_32_master := axisStream_32_master_null;
    variable REG_DATA :  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    variable TargetAsic : integer := 0;
  begin
    if rising_edge(globals.clk) then 
      pull(regTx, reg_data_s2m);
			  TargetAsic :=  to_integer(unsigned(i_reg.address(15 downto 7)));
        if (TargetAsic = asicNumber + 1 or TargetAsic = 0) and i_reg.new_value = '1' Then 
            REG_DATA := (others => '0');
            REG_DATA(18 downto 12) := i_reg.address(6 downto 0);
            REG_DATA(11 downto 0)  := i_reg.value(11 downto 0);
            send_data(regTX, REG_DATA);

        end if;
      push(regTx,reg_data_m2s);
    end if;
  end process;


  



  
  
  reg_buffer : entity work.registerBuffer generic map (
        Depth =>  10
  ) port map (
    
    clk =>globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );
end architecture;