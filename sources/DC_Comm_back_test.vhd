--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:17:29 04/18/2019
-- Design Name:   
-- Module Name:   C:/Users/Kevin/Desktop/HMB/EIC-Beamtest-FW/SCROD_A5_RJ45/SCROD_Rev1/DC_Comm_QBLinkTB.vhd
-- Project Name:  HMB_SCROD
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DC_Comm
--  
-- Dependencies:
--   
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--   
-- Notes:   
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;  
  
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DC_Comm_QBLinkTB IS
END DC_Comm_QBLinkTB;
 
ARCHITECTURE behavior OF DC_Comm_QBLinkTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
   
    
      

   --Inputs
   signal DATA_CLK : std_logic := '0';
   signal RX : std_logic_vector(0 downto 0) := (others => '0');
   signal DC_CMD : std_logic_vector(31 downto 0) := (others => '0');
   signal CMD_VALID : std_logic_vector(0 downto 0) := (others => '0');
   signal RESP_REQ : std_logic_vector(0 downto 0) := (others => '0');
   signal QB_RST : std_logic_vector(0 downto 0) := (others => '0');
	signal TrigLogicRst : std_logic := '0';

 	--Outputs
   signal TX : std_logic_vector(0 downto 0) := (others => '0');
   signal SYNC : std_logic_vector(0 downto 0) := (others => '0');
   signal DC_RESPONSE : std_logic_vector(31 downto 0);
   signal RESP_VALID : std_logic_vector(0 downto 0) := (others => '0');
   signal SERIAL_CLK_LCK : std_logic_vector(0 downto 0) := (others => '0');
   signal TRIG_LINK_SYNC : std_logic_vector(0 downto 0) := (others => '0');
	 
	--training partner signals
	-- signal sendBackWd : std_logic_vector(31 downto 0);
	-- signal respond : std_logic := '0';
	-- signal cmd_incoming : std_logic;
	-- signal ImListening : std_logic := '0';
	signal trgLinkSync1 : std_logic_vector(0 downto 0) := (others => '0');
	signal serialClkLck1 : std_logic_vector(0 downto 0) := (others => '0');
    signal sync1 : std_logic_vector(0 downto 0) := (others => '0');
   -- Clock period definitions
   constant DATA_CLK_period : time := 40 ns;
   constant WORD_READ_C      : std_logic_vector(31 downto 0) := x"72656164";
   constant WORD_WRITE_C     : std_logic_vector(31 downto 0) := x"72697465";
 
BEGIN  
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.DC_Comm PORT MAP (
          DATA_CLK => DATA_CLK,
          RX => RX,
          TX => TX,
          SYNC => SYNC,
          DC_CMD => DC_CMD,
          CMD_VALID => CMD_VALID,
          RESP_REQ => RESP_REQ,
          DC_RESPONSE => DC_RESPONSE,
          RESP_VALID => RESP_VALID,
          QB_RST => QB_RST,
			--  TrigLogicRst => TrigLogicRst,
          SERIAL_CLK_LCK => SERIAL_CLK_LCK,
          TRIG_LINK_SYNC => TRIG_LINK_SYNC
        );
	--QBLink Partner on the DC side
	Scrod_comm: entity work.DC_Comm_back
	PORT MAP (
			 DATA_CLK => DATA_CLK,
             RX     => TX,
             TX => RX,
			 QB_RST => QB_RST,
            SERIAL_CLK_LCK => serialClkLck1,
            TRIG_LINK_SYNC => trgLinkSync1,
            sync  => sync1
			 );
	
   -- Clock process definitions
   DATA_CLK_process :process
   begin
		DATA_CLK <= '0';
		wait for DATA_CLK_period/2;
		DATA_CLK <= '1';
		wait for DATA_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		QB_RST <= "1"; -- "1111";
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
      wait for DATA_CLK_period*10;
		QB_RST <= "0"; -- "0000";
      wait until SERIAL_CLK_LCK(0) = '1' and TRIG_LINK_SYNC(0) = '1';
	wait for DATA_CLK_period*2;
	-- SERIAL_CLK_LCK(0) <= '1';
	-- TRIG_LINK_SYNC(0) <= '1';
--	
	wait for DATA_CLK_period*2;
		DC_CMD <= WORD_READ_C;
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0';

		
		wait for DATA_CLK_period*1;
		DC_CMD <= x"00000002";
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0'; 
        RESP_REQ(0) <= '1';    

	wait for DATA_CLK_period;
		DC_CMD <= WORD_WRITE_C;
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0';

		
		wait for DATA_CLK_period*1;
		DC_CMD <= x"0AA00002";
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0'; 
        RESP_REQ(0) <= '1';     
      wait;
   end process;

END;
