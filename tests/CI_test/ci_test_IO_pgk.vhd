
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.utilitypkg.all;
use work.eth1000basexpkg.all;
use work.gigabitethpkg.all;
use work.bmd_definitions.all;

-- End Include user packages --

package ci_test_IO_pgk is

  constant REG_ADDR_BITS_G : integer := 16;
  constant REG_DATA_BITS_G : integer := 16;
constant num_DC          : integer := 3;

  type ci_test_writer_rec is record
    clk : std_logic;  
    datanotc_l_k : std_logic;  
    usrrst : std_logic;  
    rxdata : std_logic_vector ( 31 downto 0 );  
    rxdatavalid : std_logic;  
    rxdatalast : std_logic;  
    rxdataready : std_logic;  
    txdata : std_logic_vector ( 31 downto 0 );  
    txdatavalid : std_logic;  
    txdatalast : std_logic;  
    txdataready : std_logic;  
    serialclklck : std_logic_vector ( num_dc downto 0 );  
    triglinksync : std_logic_vector ( num_dc downto 0 );  
    dc_cmd : std_logic_vector ( 31 downto 0 );  
    qb_wren : std_logic_vector ( num_dc downto 0 );  
    qb_rden : std_logic_vector ( num_dc downto 0 );  
    dc_resp : std_logic_vector ( 31 downto 0 );  
    dc_resp_valid : std_logic_vector ( num_dc downto 0 );  
    evnt_flag : std_logic;  
    regaddr : std_logic_vector ( reg_addr_bits_g-1 downto 0 );  
    regwrdata : std_logic_vector ( reg_data_bits_g-1 downto 0 );  
    regrddata : std_logic_vector ( reg_data_bits_g-1 downto 0 );  
    regreq : std_logic;  
    regop : std_logic;  
    regack : std_logic;  
    ldqblink : std_logic;  
    cmd_int_state : std_logic_vector ( 4 downto 0 );  

  end record;

  constant ci_test_writer_rec_null : ci_test_writer_rec := ( 
    clk => '0',
    datanotc_l_k => '0',
    usrrst => '0',
    rxdata => (others => '0'),
    rxdatavalid => '0',
    rxdatalast => '0',
    rxdataready => '0',
    txdata => (others => '0'),
    txdatavalid => '0',
    txdatalast => '0',
    txdataready => '0',
    serialclklck => (others => '0'),
    triglinksync => (others => '0'),
    dc_cmd => ( others => '0' ),
    qb_wren => (others => '0'),
    qb_rden => (others => '0'),
    dc_resp => (others => '0'),
    dc_resp_valid => (others => '0'),
    evnt_flag => '0',
    regaddr => (others => '0'),
    regwrdata => (others => '0'),
    regrddata => (others => '0'),
    regreq => '0',
    regop => '0',
    regack => '0',
    ldqblink => '0',
    cmd_int_state => (others => '0')
  );
    


  type ci_test_reader_rec is record
    clk : std_logic;  
    datanotc_l_k : std_logic;  
    usrrst : std_logic;  
    rxdata : std_logic_vector ( 31 downto 0 );  
    rxdatavalid : std_logic;  
    rxdatalast : std_logic;  
    txdataready : std_logic;  
    serialclklck : std_logic_vector ( num_dc downto 0 );  
    triglinksync : std_logic_vector ( num_dc downto 0 );  
    dc_resp : std_logic_vector ( 31 downto 0 );  
    dc_resp_valid : std_logic_vector ( num_dc downto 0 );  
    evnt_flag : std_logic;  

  end record;

  constant ci_test_reader_rec_null : ci_test_reader_rec := ( 
    clk => '0',
    datanotc_l_k => '0',
    usrrst => '0',
    rxdata => (others => '0'),
    rxdatavalid => '0',
    rxdatalast => '0',
    txdataready => '0',
    serialclklck => (others => '0'),
    triglinksync => (others => '0'),
    dc_resp => (others => '0'),
    dc_resp_valid => (others => '0'),
    evnt_flag => '0'
  );
    
end ci_test_IO_pgk;

package body ci_test_IO_pgk is

end package body ci_test_IO_pgk;

    