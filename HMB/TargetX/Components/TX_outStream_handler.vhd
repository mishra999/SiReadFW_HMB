library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

Library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

  use ieee.std_logic_unsigned.all;
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

  

package TX_outStream_handler is

  function tx_make_header( row  : std_logic_vector ; column : std_logic_vector ; ASIC_NUM  : std_logic_vector ;   sample :std_logic_vector ) return std_logic_vector;


  function tx_get_ASIC_NUM(dataBuffer : std_logic_vector) return std_logic_vector;
  function tx_get_sample(dataBuffer : std_logic_vector) return std_logic_vector;
  function tx_get_column(dataBuffer : std_logic_vector) return std_logic_vector;
  function tx_get_row(dataBuffer : std_logic_vector) return std_logic_vector;


  function tx_make_data(ShiftRegisterCounter : std_logic_vector; data :std_logic_vector) return  std_logic_vector;
  function tx_get_data(dataBuffer : std_logic_vector) return std_logic_vector ;
  function tx_get_ShiftRegisterCounter(dataBuffer : std_logic_vector) return std_logic_vector;
end package;

package body TX_outStream_handler is

  function tx_make_header( row : std_logic_vector ; column : std_logic_vector ; ASIC_NUM  : std_logic_vector ;   sample :std_logic_vector ) return std_logic_vector is

    variable ret : std_logic_vector(31 downto 0) := (others => '0');
  begin 
    ret := x"ABC" & '0' & row(2 downto 0) & column(5 downto 0)  &'0'&  ASIC_NUM(3 downto 0) &  sample(4 downto 0);
    return ret;
  end function;

  function tx_get_ASIC_NUM(dataBuffer : std_logic_vector) return std_logic_vector is 
    variable ret : std_logic_vector(3 downto 0) := (others => '0');
  begin 
    ret (3 downto 0) := dataBuffer(8 downto 5);
    return ret;

  end function;

  function tx_get_sample(dataBuffer : std_logic_vector) return std_logic_vector is 
  begin 
    return dataBuffer(4 downto 0);
  end function;

  function tx_get_column(dataBuffer : std_logic_vector) return std_logic_vector is 
    variable ret : std_logic_vector(5 downto 0) := (others => '0');
  begin 
    ret(5 downto 0) :=  dataBuffer(15 downto 10);
    return ret;
    
  end function;
  function tx_get_row(dataBuffer : std_logic_vector) return std_logic_vector is
    variable ret : std_logic_vector(2 downto 0) := (others => '0');
  begin
    ret(2 downto 0) := dataBuffer(18 downto 16);
    return ret;
  end function;



  function tx_make_data(ShiftRegisterCounter : std_logic_vector; data :std_logic_vector) return  std_logic_vector is
    variable ret : std_logic_vector(31 downto 0) := (others => '0');
  begin
    ret :=  x"DEF" & ShiftRegisterCounter(3 downto 0 ) & data(15 downto 0);
    return ret;
  end function;

  function tx_get_data(dataBuffer : std_logic_vector) return std_logic_vector is 
    variable ret : std_logic_vector(15 downto 0) := (others => '0');
  begin
    ret(15 downto 0) := dataBuffer(15 downto 0);
    return ret;
  end function;

  function tx_get_ShiftRegisterCounter(dataBuffer : std_logic_vector) return std_logic_vector is 
    variable ret : std_logic_vector(3 downto 0) := (others => '0');
  begin
    ret(3 downto 0) := dataBuffer(19 downto 16);
    return ret;
  end function;

end package body;