library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.tdc_pkg.all;
package Trigger_bits_buffer is
  

  constant tb_buff_size : integer := 10;
  type trigger_bits_buffer_a is array (tb_buff_size downto 0) of trigger_bits_t;  
  
  type trigger_bits_buffer_t is record
    tb_buffer            : trigger_bits_buffer_a;
    trigger_mask         : std_logic_vector(tb_buff_size downto 0);
  end record;
  
  constant trigger_bits_buffer_t_null : trigger_bits_buffer_t := (
    tb_buffer => (others => (others => '0')),
    trigger_mask => (others => '0')
  );
  procedure push_back(signal self : inout trigger_bits_buffer_t;  data_in : std_logic_vector) ;
  procedure set_trigger_mask(signal self : inout trigger_bits_buffer_t;  trigger_mask: std_logic_vector);
  function get_trigger_bits(self :  trigger_bits_buffer_t) return trigger_bits_t;
  function falling_edge(self : trigger_bits_buffer_t) return boolean;
  function rising_edge(self : trigger_bits_buffer_t) return boolean ;
  
  
  

end package;

package body Trigger_bits_buffer is
  
  function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return STD_LOGIC is
    variable result: STD_LOGIC;
  begin
    result := '0';
    for i in ARG'range loop
      result := result or ARG(i);
    end loop;
    return result;
  end;


  procedure push_back(signal self : inout trigger_bits_buffer_t;  data_in : trigger_bits_t) is 
  begin 

    self.tb_buffer <= data_in & self.tb_buffer(self.tb_buffer'length-1 downto 1);
  end procedure;

procedure set_trigger_mask(signal self : inout trigger_bits_buffer_t;  trigger_mask: std_logic_vector) is 
begin
  self.trigger_mask(self.trigger_mask'length - 1 downto 0) <= trigger_mask(self.trigger_mask'length - 1 downto 0);

end procedure;

  function get_trigger_bits(self :  trigger_bits_buffer_t) return trigger_bits_t is
    variable ret  : trigger_bits_t := (others => '0');
  begin 

    for I in self.tb_buffer'range loop
      if self.trigger_mask(i) = '1' then
        ret := ret or self.tb_buffer(I);
      end if;
    end loop;
    return ret;
  end function;

  function falling_edge(self : trigger_bits_buffer_t) return boolean is
  begin 

    return  OR_REDUCE(self.tb_buffer(self.tb_buffer'length-1)) = '0' and OR_REDUCE(self.tb_buffer(self.tb_buffer'length-2)) = '1';
  end function;


  function rising_edge(self : trigger_bits_buffer_t) return boolean is
  begin
    return  OR_REDUCE(self.tb_buffer(0)) = '0' and OR_REDUCE(self.tb_buffer(1)) = '1';
  end function;

end package body;