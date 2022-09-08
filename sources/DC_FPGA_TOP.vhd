Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

use work.all;
use work.Eth1000BaseXPkg.all;
use work.GigabitEthPkg.all;
use work.BMD_definitions.all; --need to include BMD_definitions in addition to work.all
use work.UtilityPkg.all;

entity DC_FPGA_TOP is	
    generic (
        NUM_DCs : integer := 0 
    );
  port (
        clk              : in std_logic;


        RX_DC_P			 : IN slv(NUM_DCs downto 0);  --SERIAL INPUT FROM DC
        RX_DC_N			 : IN slv(NUM_DCs  downto 0);  --SERIAL INPUT FROM DC
        DC_CLK_P			 : OUT slv(NUM_DCs downto 0);  --25MHz clock to DC (fact check)--> {confirmed}
        DC_CLK_N		    : OUT slv(NUM_DCs downto 0); 
        TX_DC_N         : OUT slv(NUM_DCs downto 0);  --Serial output to DC
        TX_DC_P			 : OUT slv(NUM_DCs downto 0);--Serial output to DC 
        SYNC_P			 : OUT slv(NUM_DCs downto 0); -- when '0' DC listens only, '1' DC reads back command
        SYNC_N			 : OUT slv(NUM_DCs downto 0);

        DC_RESET        : in slv(NUM_DCs DOWNTO 0)		-- Commented by Shivang on Oct 8, 2020
  );
end entity;


architecture rtl of DC_FPGA_TOP is
    signal i_clk              : std_logic;
  	signal tx_dc		 : slv(NUM_DCs downto 0); --transmitted serial data bit 
	signal rx_dc		 : slv(NUM_DCs downto 0); --recieved serial data bit
    signal QB_RST :  slv(NUM_DCs downto 0) := (others => '0');

    signal SERIAL_CLK_LCK :  slv(NUM_DCs downto 0);
    signal TRIG_LINK_SYNC :  slv(NUM_DCs downto 0);

    signal SYNC :  STD_LOGIC_VECTOR (NUM_DCs downto 0); --Universal sync signal

	signal  GLOB_EVNT_P :  STD_LOGIC_VECTOR(3 downto 0);
    signal GLOB_EVNT_N :  STD_LOGIC_VECTOR(3 downto 0);
    signal  GLOB_EVNT :  STD_LOGIC_VECTOR(3 downto 0);
begin

DC_IO_BUFF : entity work.IO_Buffers
generic map (num_DC => NUM_DCs)
PORT MAP(
	RX_P => RX_DC_P,
	RX_N => RX_DC_N,
	TX => tx_dc,
	GLOB_EVNT => GLOB_EVNT,
	SYNC => sync,   
	TX_P => TX_DC_P,
	TX_N => TX_DC_N,
	DC_CLK_P => DC_CLK_P,
	DC_CLK_N => DC_CLK_N,
 	DATA_CLK => i_clk, 
	GLOB_EVNT_P => GLOB_EVNT_P,
	GLOB_EVNT_N => GLOB_EVNT_N,
	RX => rx_dc,
	SYNC_P => SYNC_P,
	SYNC_N => SYNC_N
	);

u_dc_receiver : entity work.DC_Comm_back port map(
    DATA_CLK => i_clk,
    RX => rx_dc,
    TX =>tx_dc,
    QB_RST => QB_RST,
            
    SERIAL_CLK_LCK => SERIAL_CLK_LCK,
    TRIG_LINK_SYNC => TRIG_LINK_SYNC,
            
    sync => sync
);
end architecture;