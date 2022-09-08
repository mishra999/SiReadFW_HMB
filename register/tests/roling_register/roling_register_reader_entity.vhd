


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.roling_register_reader_pgk.all;


entity roling_register_reader_et  is
    generic (
        FileName : string := "./roling_register_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out roling_register_reader_rec
    );
end entity;   

architecture Behavioral of roling_register_reader_et is 

  constant  NUM_COL    : integer := 5;
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

  integer_to_sl(csv_r_data(0), data.registerin_m2s.valid);
  integer_to_sl(csv_r_data(1), data.registerin_m2s.last);
  integer_to_slv(csv_r_data(2), data.registerin_m2s.data.address);
  integer_to_slv(csv_r_data(3), data.registerin_m2s.data.value);
  integer_to_sl(csv_r_data(4), data.registerin_m2s.data.clk);


end Behavioral;
    