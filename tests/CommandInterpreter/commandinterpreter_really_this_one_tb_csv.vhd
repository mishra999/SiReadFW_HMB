


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.commandinterpreter_really_this_one_IO_pgk.all;


entity commandinterpreter_really_this_one_reader_et  is
    generic (
        FileName : string := "./commandinterpreter_really_this_one_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out commandinterpreter_really_this_one_reader_rec
    );
end entity;   

architecture Behavioral of commandinterpreter_really_this_one_reader_et is 

  constant  NUM_COL    : integer := 14;
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

  --integer_to_sl(csv_r_data(0), data.clk);
  integer_to_sl(csv_r_data(0), data.datanotc_l_k);
  integer_to_sl(csv_r_data(1), data.usrrst);
  integer_to_slv(csv_r_data(2), data.rxdata);
  integer_to_sl(csv_r_data(3), data.rxdatavalid);
  integer_to_sl(csv_r_data(4), data.rxdatalast);
  integer_to_sl(csv_r_data(5), data.txdataready);
  integer_to_slv(csv_r_data(6), data.serialclklck);
  integer_to_slv(csv_r_data(7), data.triglinksync);
  integer_to_slv(csv_r_data(8), data.dc_resp);
  integer_to_slv(csv_r_data(9), data.dc_resp_valid);
  integer_to_sl(csv_r_data(10), data.evnt_flag);
  integer_to_slv(csv_r_data(11), data.regrddata);
  integer_to_sl(csv_r_data(12), data.regack);


end Behavioral;
---------------------------------------------------------------------------------------------------
    


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.commandinterpreter_really_this_one_IO_pgk.all;

entity commandinterpreter_really_this_one_writer_et  is
    generic ( 
        FileName : string := "./commandinterpreter_really_this_one_out.csv"
    ); port (
        clk : in std_logic ;
        data : in commandinterpreter_really_this_one_writer_rec
    );
end entity;

architecture Behavioral of commandinterpreter_really_this_one_writer_et is 
  constant  NUM_COL : integer := 27;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "clk; datanotc_l_k; usrrst; rxdata; rxdatavalid; rxdatalast; rxdataready; txdata; txdatavalid; txdatalast; txdataready; serialclklck; triglinksync; dc_cmd; qb_wren; qb_rden; dc_resp; dc_resp_valid; evnt_flag; regaddr; regwrdata; regrddata; regreq; regop; regack; ldqblink; cmd_int_state",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  sl_to_integer(data.clk, data_int(0) );
  sl_to_integer(data.datanotc_l_k, data_int(1) );
  sl_to_integer(data.usrrst, data_int(2) );
  slv_to_integer(data.rxdata, data_int(3) );
  sl_to_integer(data.rxdatavalid, data_int(4) );
  sl_to_integer(data.rxdatalast, data_int(5) );
  sl_to_integer(data.rxdataready, data_int(6) );
  slv_to_integer(data.txdata, data_int(7) );
  sl_to_integer(data.txdatavalid, data_int(8) );
  sl_to_integer(data.txdatalast, data_int(9) );
  sl_to_integer(data.txdataready, data_int(10) );
  slv_to_integer(data.serialclklck, data_int(11) );
  slv_to_integer(data.triglinksync, data_int(12) );
  slv_to_integer(data.dc_cmd, data_int(13) );
  slv_to_integer(data.qb_wren, data_int(14) );
  slv_to_integer(data.qb_rden, data_int(15) );
  slv_to_integer(data.dc_resp, data_int(16) );
  slv_to_integer(data.dc_resp_valid, data_int(17) );
  sl_to_integer(data.evnt_flag, data_int(18) );
  slv_to_integer(data.regaddr, data_int(19) );
  slv_to_integer(data.regwrdata, data_int(20) );
  slv_to_integer(data.regrddata, data_int(21) );
  sl_to_integer(data.regreq, data_int(22) );
  sl_to_integer(data.regop, data_int(23) );
  sl_to_integer(data.regack, data_int(24) );
  sl_to_integer(data.ldqblink, data_int(25) );
  slv_to_integer(data.cmd_int_state, data_int(26) );


end Behavioral;
---------------------------------------------------------------------------------------------------
    

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.commandinterpreter_really_this_one_IO_pgk.all;

entity commandinterpreter_really_this_one_tb_csv is 
end entity;

architecture behavior of commandinterpreter_really_this_one_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : commandinterpreter_really_this_one_reader_rec := commandinterpreter_really_this_one_reader_rec_null;
  signal data_out : commandinterpreter_really_this_one_writer_rec := commandinterpreter_really_this_one_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.commandinterpreter_really_this_one_reader_et 
    generic map (
        FileName => "./commandinterpreter_really_this_one_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.commandinterpreter_really_this_one_writer_et
    generic map (
        FileName => "./commandinterpreter_really_this_one_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

data_out.datanotc_l_k <= data_in.datanotc_l_k;
data_out.usrrst <= data_in.usrrst;
data_out.rxdata <= data_in.rxdata;
data_out.rxdatavalid <= data_in.rxdatavalid;
data_out.rxdatalast <= data_in.rxdatalast;
data_out.txdataready <= data_in.txdataready;
data_out.serialclklck <= data_in.serialclklck;
data_out.triglinksync <= data_in.triglinksync;
data_out.dc_resp <= data_in.dc_resp;
data_out.dc_resp_valid <= data_in.dc_resp_valid;
data_out.evnt_flag <= data_in.evnt_flag;
data_out.regrddata <= data_in.regrddata;
data_out.regack <= data_in.regack;


DUT :  entity work.CI_test  port map(

  clk => clk,
  datanotc_l_k => data_out.datanotc_l_k,
  usrrst => data_out.usrrst,
  rxdata => data_out.rxdata,
  rxdatavalid => data_out.rxdatavalid,
  rxdatalast => data_out.rxdatalast,
  rxdataready => data_out.rxdataready,
  txdata => data_out.txdata,
  txdatavalid => data_out.txdatavalid,
  txdatalast => data_out.txdatalast,
  txdataready => data_out.txdataready,
  serialclklck => data_out.serialclklck,
  triglinksync => data_out.triglinksync,
  dc_cmd => data_out.dc_cmd,
  qb_wren => data_out.qb_wren,
  qb_rden => data_out.qb_rden,
  dc_resp => data_out.dc_resp,
  dc_resp_valid => data_out.dc_resp_valid,
  evnt_flag => data_out.evnt_flag,
  regaddr => data_out.regaddr,
  regwrdata => data_out.regwrdata,
  regrddata => data_out.regrddata,
  regreq => data_out.regreq,
  regop => data_out.regop,
  regack => data_out.regack,
  ldqblink => data_out.ldqblink,
  cmd_int_state => data_out.cmd_int_state
    );

end behavior;
---------------------------------------------------------------------------------------------------
    