library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.tdc_pkg.all;

package optional_trigger_bits_p is

  type optional_trigger_bit_t is record
    trigger_bit        : trigger_bits_t;
    valid              : std_logic;
  end record;
 constant optional_trigger_bit_t_null : optional_trigger_bit_t := (
   trigger_bit => (others => '0'),
   valid => '0'
 );
 type optional_trigger_bit_t_a is array (natural range <>) of optional_trigger_bit_t;
 procedure reset(signal self:out optional_trigger_bit_t);
 procedure set_data(signal self:out optional_trigger_bit_t; triggerBits : in trigger_bits_t);
 function is_valid(self: optional_trigger_bit_t) return boolean;
 function get_data(self: optional_trigger_bit_t) return  trigger_bits_t;
 
end package;

package body optional_trigger_bits_p is
  
  procedure reset(signal self:out optional_trigger_bit_t) is 
  begin 
    self<= optional_trigger_bit_t_null;
  end procedure;
  
  procedure set_data(signal self:out optional_trigger_bit_t; triggerBits : in trigger_bits_t) is
  begin
    self.trigger_bit <= triggerBits;
    self.valid<='1';
  end procedure;
 
  function is_valid(self: optional_trigger_bit_t) return boolean is 
  begin
    return self.valid = '1';
  end function;
 
  function get_data(self: optional_trigger_bit_t) return  trigger_bits_t is
  begin
    assert (is_valid(self) ) report "Optional_t: container is empty" severity failure;
    return self.trigger_bit;
  end function;
    
  
end package body;