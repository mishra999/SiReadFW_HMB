library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

  use work.roling_register_p.all;

entity registerBuffer is
  generic(
    Depth : integer := gRegisterDelay
  );
  port (
    clk: in  std_logic;
    registersIn    : in registerT;
    registersOut   : out registerT
  );
end entity;

architecture rtl of registerBuffer is
  signal regBuffer :  registerT_a(Depth downto 0) := (others => registerT_null);
begin
  
  regBuffer(0) <= registersIn;
  registersOut <= regBuffer(Depth);
  
--  registersOut.clk <= clk;
  gen_buff : 
  for I in 0 to Depth -1 generate
    process(clk) is 
    begin
      if rising_edge(clk) then 
        regBuffer(I+1)<= regBuffer(I);
        
      end if;


    end process;
  end generate gen_buff;

end architecture;