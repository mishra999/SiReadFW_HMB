


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.tx_triggerbitsz_IO_pgk.all;


entity tx_triggerbitsz_reader_et  is
    generic (
        FileName : string := "./tx_triggerbitsz_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out tx_triggerbitsz_reader_rec
    );
end entity;   

architecture Behavioral of tx_triggerbitsz_reader_et is 

  constant  NUM_COL    : integer := 15;
  signal    csv_r_data : c_integer_array(NUM_COL -1 downto 0)  := (others=>0)  ;
begin

  csv_r :entity  work.csv_read_file 
    generic map (
        FileName =>  FileName, 
        NUM_COL => NUM_COL,
        useExternalClk=>true,
        HeaderLines =>  2
    ) port map (
        clk => clk,
        Rows => csv_r_data
    );

  integer_to_sl(csv_r_data(0), data.globals.clk);
  integer_to_sl(csv_r_data(1), data.globals.rst);
  integer_to_slv(csv_r_data(2), data.globals.reg.address);
  integer_to_slv(csv_r_data(3), data.globals.reg.value);
  integer_to_slv(csv_r_data(4), data.target_tb_in(1));
  integer_to_slv(csv_r_data(5), data.target_tb_in(2));
  integer_to_slv(csv_r_data(6), data.target_tb_in(3));
  integer_to_slv(csv_r_data(7), data.target_tb_in(4));
  integer_to_slv(csv_r_data(8), data.target_tb_in(5));
  integer_to_slv(csv_r_data(9), data.target_tb_in(6));
  integer_to_slv(csv_r_data(10), data.target_tb_in(7));
  integer_to_slv(csv_r_data(11), data.target_tb_in(8));
  integer_to_slv(csv_r_data(12), data.target_tb_in(9));
  data.target_tb_in(10) <= (others =>'0');
  integer_to_slv(csv_r_data(13), data.read_out);
  integer_to_sl(csv_r_data(14), data.busa_clr_in);


end Behavioral;
---------------------------------------------------------------------------------------------------
    


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.tx_triggerbitsz_IO_pgk.all;

entity tx_triggerbitsz_writer_et  is
    generic ( 
        FileName : string := "./tx_triggerbitsz_out.csv"
    ); port (
        clk : in std_logic ;
        data : in tx_triggerbitsz_writer_rec
    );
end entity;

architecture Behavioral of tx_triggerbitsz_writer_et is 
  constant  NUM_COL : integer := 25;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "globals_clk; globals_rst; globals_reg_address; globals_reg_value; target_tb_in_1; target_tb_in_2; target_tb_in_3; target_tb_in_4; target_tb_in_5; target_tb_in_6; target_tb_in_7; target_tb_in_8; target_tb_in_9; target_tb_out_1; target_tb_out_2; target_tb_out_3; target_tb_out_4; target_tb_out_5; target_tb_out_6; target_tb_out_7; target_tb_out_8; target_tb_out_9; read_out; busa_clr_in; busa_clr_out",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  sl_to_integer(data.globals.clk, data_int(0) );
  sl_to_integer(data.globals.rst, data_int(1) );
  slv_to_integer(data.globals.reg.address, data_int(2) );
  slv_to_integer(data.globals.reg.value, data_int(3) );
  slv_to_integer(data.target_tb_in(1), data_int(4) );
  slv_to_integer(data.target_tb_in(2), data_int(5) );
  slv_to_integer(data.target_tb_in(3), data_int(6) );
  slv_to_integer(data.target_tb_in(4), data_int(7) );
  slv_to_integer(data.target_tb_in(5), data_int(8) );
  slv_to_integer(data.target_tb_in(6), data_int(9) );
  slv_to_integer(data.target_tb_in(7), data_int(10) );
  slv_to_integer(data.target_tb_in(8), data_int(11) );
  slv_to_integer(data.target_tb_in(9), data_int(12) );
  slv_to_integer(data.target_tb_out(1), data_int(13) );
  slv_to_integer(data.target_tb_out(2), data_int(14) );
  slv_to_integer(data.target_tb_out(3), data_int(15) );
  slv_to_integer(data.target_tb_out(4), data_int(16) );
  slv_to_integer(data.target_tb_out(5), data_int(17) );
  slv_to_integer(data.target_tb_out(6), data_int(18) );
  slv_to_integer(data.target_tb_out(7), data_int(19) );
  slv_to_integer(data.target_tb_out(8), data_int(20) );
  slv_to_integer(data.target_tb_out(9), data_int(21) );
  slv_to_integer(data.read_out, data_int(22) );
  sl_to_integer(data.busa_clr_in, data_int(23) );
  sl_to_integer(data.busa_clr_out, data_int(24) );


end Behavioral;
---------------------------------------------------------------------------------------------------
    

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.tx_triggerbitsz_IO_pgk.all;

entity tx_triggerbitsz_tb_csv is 
end entity;

architecture behavior of tx_triggerbitsz_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : tx_triggerbitsz_reader_rec := tx_triggerbitsz_reader_rec_null;
  signal data_out : tx_triggerbitsz_writer_rec := tx_triggerbitsz_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.tx_triggerbitsz_reader_et 
    generic map (
        FileName => "./tx_triggerbitsz_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.tx_triggerbitsz_writer_et
    generic map (
        FileName => "./tx_triggerbitsz_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

  data_out.globals.clk <=clk;
  data_out.globals.reg <= data_in.globals.reg;
  data_out.globals.rst <= data_in.globals.rst;
  data_out.target_tb_in <= data_in.target_tb_in;
data_out.read_out <= data_in.read_out;
data_out.busa_clr_in <= data_in.busa_clr_in;


DUT :  entity work.tx_triggerbitsz  port map(
globals => data_out.globals,
  target_tb_in => data_out.target_tb_in,
  target_tb_out => data_out.target_tb_out,
  read_out => data_out.read_out,
  busa_clr_in => data_out.busa_clr_in,
  busa_clr_out => data_out.busa_clr_out
    );

end behavior;
---------------------------------------------------------------------------------------------------
    