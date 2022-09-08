
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.xgen_serialdatarout_p.all;
use work.xgen_axistream_registert.all;
use work.roling_register_p.all;

-- End Include user packages --

package roling_register_reader_pgk is

  type roling_register_reader_rec is record
    registerin_m2s : axisstream_registert_m2s;  

  end record;

  constant roling_register_reader_rec_null : roling_register_reader_rec := ( 
    registerin_m2s => axisstream_registert_m2s_null
  );

end roling_register_reader_pgk;

package body roling_register_reader_pgk is

end package body roling_register_reader_pgk;

    