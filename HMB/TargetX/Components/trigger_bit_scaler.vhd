library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.roling_register_p.all;
  use work.optional_trigger_bits_p.all;
  use work.klm_scint_globals.all;
  use ieee.std_logic_unsigned.all;


entity trigger_bit_scaler is
  generic (
    asic_number : integer 
  );
  port (
    globals : globals_t   := globals_t_null;
    reg_out         : out registerT := registerT_null;
    edgedetection_tb_out :  in optional_trigger_bit_t := optional_trigger_bit_t_null
  );
end entity;

architecture rtl of trigger_bit_scaler is
  type scaler_buffer_t is array (natural range <>) of STD_LOGIC_VECTOR(15 downto 0);
  signal scaller_buffer : scaler_buffer_t(0 to 32) := (others => (others => '0'));
  signal scaller_buffer_out : scaler_buffer_t(0 to 32) := (others => (others => '0'));
  
  signal scaler_index : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
  
  signal scaler_counter : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
  signal scaler_counter_max : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
  constant header : STD_LOGIC_VECTOR(3 downto 0) := x"f";
  signal   i_reg           :  registerT:= registerT_null;
begin
  
  process(globals.clk) is
    variable index : integer := 0;
  begin
    if rising_edge(globals.clk) then 
      scaler_counter <= scaler_counter +1;
      if is_valid(edgedetection_tb_out) then 
        index := conv_integer(get_data(edgedetection_tb_out));
        scaller_buffer(index) <= scaller_buffer(index)  +1;
      end if;
      
      if scaler_counter >= scaler_counter_max then
        scaller_buffer_out <= scaller_buffer;
        scaller_buffer <= (others => (others => '0'));
		    scaler_counter <= (others => '0');
      end if;
      
      
      reg_out.address <= reg_addr_to_slv(
                            reg_addr_ctr(
                              channel => scaler_index, 
                              asic   =>  std_logic_vector(to_unsigned(asic_number,8)) , 
                              header => header
                            ));
      reg_out.value <= scaller_buffer_out(conv_integer(scaler_index));
      scaler_index <= scaler_index +1;

      
      read_data_s( i_reg,  scaler_counter_max   , register_val.scaler_max_counter );
    end if;
  end process;
  
  
  
  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  10
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );


end architecture;