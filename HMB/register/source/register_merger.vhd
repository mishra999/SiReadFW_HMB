library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.roling_register_p.all;

entity register_merger is
  generic(
    Num_of_inputs:integer;
    index_counter_max : integer := 997 -- prime number
  );
  port (
    clk: in  std_logic;


    reg_in : in registerT_a(0 to Num_of_inputs - 1) := (others => registerT_null);
    reg_out : out registerT :=  registerT_null
  );
end entity;

architecture rtl of register_merger is
  signal index : integer := 0;
  signal index_counter : integer := 0;
begin


  process(clk) is 
  begin 
    if rising_edge(clk) then 
      reg_out <= reg_in(index);
      
      
      index_counter <= index_counter +1;
      if index_counter >= index_counter_max then 
        index_counter <= 0;
        index <= index +1;
        if index = Num_of_inputs - 1 then 
          index <= 0;
        end if;
      end if;
      
      
    end if;
  end process;


end architecture;