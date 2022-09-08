
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.klm_scint_globals.all;
use work.tdc_pkg.all;
use work.xgen_axistream_32.all;
use work.roling_register_p.all;
use work.optional_trigger_bits_p.all;

-- End Include user packages --

package tx_triggerbitsz_IO_pgk is


  type tx_triggerbitsz_writer_rec is record
    globals : globals_t;  
    target_tb_in : tb_vec_type;  
    target_tb_out : tb_vec_type;  
    read_out : std_logic_vector(31 downto 0);
    busa_clr_in : std_logic;  
    busa_clr_out : std_logic;  

  end record;

  constant tx_triggerbitsz_writer_rec_null : tx_triggerbitsz_writer_rec := ( 
    globals => globals_t_null,
    target_tb_in => (others => (others => '0')),
    target_tb_out => (others => (others => '0')),
    read_out =>  (others => '0'),
    busa_clr_in => '0',
    busa_clr_out => '0'
  );
    


  type tx_triggerbitsz_reader_rec is record
    globals : globals_t;  
    target_tb_in : tb_vec_type;  
    read_out : std_logic_vector(31 downto 0);  
    busa_clr_in : std_logic;  

  end record;

  constant tx_triggerbitsz_reader_rec_null : tx_triggerbitsz_reader_rec := ( 
    globals => globals_t_null,
    target_tb_in => (others => (others => '0')),
    read_out => (others => '0'),
    busa_clr_in => '0'
  );
    
end tx_triggerbitsz_IO_pgk;

package body tx_triggerbitsz_IO_pgk is

end package body tx_triggerbitsz_IO_pgk;

    