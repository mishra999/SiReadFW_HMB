library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
  use work.Trigger_bits_buffer.all;
  use work.tdc_pkg.all;
  use work.optional_trigger_bits_p.all;

entity KLMTrigBitsEdgeDetection is
  port (
    clk: in  std_logic:='0';
    rst: in  std_logic:='0';
    tb_mask: std_logic_vector(15 downto 0) :=x"0008";
    tb_in  : in trigger_bits_t := (others =>'0');
    tb_out : out optional_trigger_bit_t := optional_trigger_bit_t_null
  );
end entity;

architecture rtl of KLMTrigBitsEdgeDetection is

  signal tb_buffer : trigger_bits_buffer_t := trigger_bits_buffer_t_null;
  
begin
  
  tdc_regs_pcs : process(clk)
  begin
    if rising_edge(clk) then

      
      reset(tb_out);
      push_back(tb_buffer, tb_in);
      set_trigger_mask(tb_buffer, tb_mask );
      if rising_edge(tb_buffer) then
        set_data(tb_out, get_trigger_bits(tb_buffer));
      end if;
    end if;
  end process;
end architecture;