


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.roling_register_writer_pgk.all;

entity roling_register_writer_et  is
    generic ( 
        FileName : string := "./roling_register_out.csv"
    ); port (
        clk : in std_logic ;
        data : in roling_register_writer_rec
    );
end entity;

architecture Behavioral of roling_register_writer_et is 
  constant  NUM_COL : integer := 9;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "registerin_m2s_valid; registerin_m2s_last; registerin_m2s_data_address; registerin_m2s_data_value; registerin_m2s_data_clk; registerin_s2m_ready; registersout_address; registersout_value; registersout_clk",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  sl_to_integer(data.registerin_m2s.valid, data_int(0) );
  sl_to_integer(data.registerin_m2s.last, data_int(1) );
  slv_to_integer(data.registerin_m2s.data.address, data_int(2) );
  slv_to_integer(data.registerin_m2s.data.value, data_int(3) );
  sl_to_integer(data.registerin_m2s.data.clk, data_int(4) );
  sl_to_integer(data.registerin_s2m.ready, data_int(5) );
  slv_to_integer(data.registersout.address, data_int(6) );
  slv_to_integer(data.registersout.value, data_int(7) );
  sl_to_integer(data.registersout.clk, data_int(8) );


end Behavioral;
    