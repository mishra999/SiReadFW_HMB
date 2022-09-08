library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.roling_register_p.all;

entity roling_register_cdc is
  port (
    clk: in  std_logic;
    registersIn   : in registerT := registerT_null;
    registersOut  : out registerT := registerT_null
  );
end entity;

architecture rtl of roling_register_cdc is
  
  
  signal I_slowClk1 : std_logic := '0';
  signal i_registersOut  :  registerT;
begin
  
  --process(clk) is
  --begin
  --if rising_edge(clk) then
  --  I_slowClk1 <= registersIn.clk;

  --  if  I_slowClk1 = '1' then
  --    registersOut.value  <= i_registersOut.value;
		--registersOut.address  <= i_registersOut.address;
  --  end if;
  --end if;
  --end process;
  
  registersOut.value  <= i_registersOut.value;
  registersOut.address  <= i_registersOut.address;



  i_registersOut.clk <= '0';
  gen_value : 
  for I in 0 to 15 generate
    sync_isValid : entity work.SyncBit port map( 
      -- Clock and reset
      clk      => clk,
      rst      => '0',
      -- Incoming bit, asynchronous
      asyncBit  => registersIn.value(I),
      -- Outgoing bit, synced to clk
      syncBit   => i_registersOut.value(I)
    ); 
  end generate gen_value;
  
  

  gen_address : 
  for I in 0 to 15 generate
    sync_isValid : entity work.SyncBit port map( 
      -- Clock and reset
      clk      => clk,
      rst      => '0',
      -- Incoming bit, asynchronous
      asyncBit  => registersIn.address(I),
      -- Outgoing bit, synced to clk
      syncBit   => i_registersOut.address(I)
    ); 
  end generate gen_address;

  
  
  registersOut.clk <= clk;
end architecture;