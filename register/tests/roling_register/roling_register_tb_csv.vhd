

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.roling_register_writer_pgk.all;
use work.roling_register_reader_pgk.all;
entity roling_register_tb_csv is 
end entity;

architecture behavior of roling_register_tb_csv is 
  signal clk : std_logic := '0';
  signal clk1 : std_logic := '0';
  signal data_in : roling_register_reader_rec := roling_register_reader_rec_null;
  signal data_out : roling_register_writer_rec := roling_register_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.roling_register_reader_et 
    generic map (
        FileName => "./roling_register_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.roling_register_writer_et
    generic map (
        FileName => "./roling_register_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

data_out.registerin_m2s <= data_in.registerin_m2s;

process(clk) is 
  
begin 
  if rising_edge(clk) then 

    clk1 <= not clk1;
  end if;
end process;

DUT :  entity work.roling_register  port map(
    clk => clk,
        slowClk        => clk1,
      registerin_m2s => data_out.registerin_m2s,
  registerin_s2m => data_out.registerin_s2m,
  registersout => data_out.registersout
    );

end behavior;
    