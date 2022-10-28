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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.all;
use work.BMD_definitions.all;  
use work.UtilityPkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
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
   signal QB_RST1 : std_logic_vector(0 downto 0) := (others => '0');

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

    signal regAddr : std_logic_vector(15 downto 0):= (others => '0');
    signal regWrData : std_logic_vector(15 downto 0):= (others => '0');
    signal regReq    : std_logic;
    signal regOp     : std_logic;
    signal DC_RESPONSEb : std_logic_vector (31 downto 0):= (others => '0'); 
    signal RES_VALIDb : std_logic_vector( 0 downto 0):= (others => '0'); 
    -- signal sstX5Clk : std_logic;
    constant N_GPR : integer := 20;--127;
    type GPR is array(N_GPR-1 downto 0) of std_logic_vector(15 downto 0);
    signal CtrlRegister : GPR:= (others => x"0000");
   -- Clock period definitions
   constant DATA_CLK_period : time := 80 ns;
--    constant sst5x_CLK_period : time := 8 ns;
   constant WORD_READ_C      : std_logic_vector(31 downto 0) := x"72656164";
   constant WORD_WRITE_C     : std_logic_vector(31 downto 0) := x"72697465";
 
BEGIN  
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.DC_Comm PORT MAP (
          DATA_CLK => DATA_CLK,
        --   sstX5Clk => sstX5Clk,
          RX => RX,
          TX => TX,
          SYNC => QB_RST,
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
			--  sstX5Clk => sstX5Clk,
             RX     => TX,
             TX => RX,
			 QB_RST => QB_RST1, 
            DC_RESPONSE => DC_RESPONSEb,
            RES_VALID => RES_VALIDb,
            SERIAL_CLK_LCK => serialClkLck1,
            TRIG_LINK_SYNC => trgLinkSync1,
            sync  => QB_RST1,
            regAddr =>regAddr,
            regWrData => regWrData,
            regReq  => regReq,
            regOp => regOp      
			 );
	
   -- Clock process definitions
   DATA_CLK_process :process
   begin
		DATA_CLK <= '0';
		wait for DATA_CLK_period/2;
		DATA_CLK <= '1';
		wait for DATA_CLK_period/2;
   end process;

--    sst5x_CLK_process :process
--    begin
-- 		sstX5Clk <= '0';
-- 		wait for sst5x_CLK_period/2;
-- 		sstX5Clk <= '1';
-- 		wait for sst5x_CLK_period/2;
--    end process;

    -- DC_reset_process : process(DATA_CLK) --unused for now 10/01
    -- ----variable counter : integer range 0 to 2 := 0;
    -- begin 
    --     IF rising_edge(DATA_CLK) THEN
    --     sync1 <= CtrlRegister(2)(0 downto 0);
    --     QB_RST1 <= CtrlRegister(2)(0 downto 0);
    --     --    DC_RESET <= CtrlRegister(2)(NUM_DCs downto 0); --by me
    --     END IF;
    -- end process;


    seqnn : process (DATA_CLK) is
    begin
        if (rising_edge(DATA_CLK)) then
            RES_VALIDb(0) <= '0';
            if QB_RST1 = "1" then
                DC_RESPONSEb  <= (others => '0');
            
            elsif regReq = '1' then
                if regOp = '0' then
                    DC_RESPONSEb(15 downto 0) <= CtrlRegister(to_integer(unsigned(regAddr)));
                    RES_VALIDb(0) <= '1';
                elsif regOp = '1' then
                    CtrlRegister(to_integer(unsigned(regAddr))) <= regWrData; 
                    DC_RESPONSEb(15 downto 0) <= regAddr;
                    RES_VALIDb(0) <= '1';                
                end if;
            end if;
        end if;
    end process; 


   -- Stimulus process
   stim_proc: process
   begin		
	-- 	QB_RST <= "1"; -- "1111";
    --   sync <= "1";

    --   -- hold reset state for 100 ns.
    --   --wait for 100 ns;	
	--   sync1 <= "1";
    --   QB_RST1 <= "1";
    --   wait for DATA_CLK_period*10;
	-- 	QB_RST <= "0"; -- "0000";
    --      sync <= "0";
    -- --wait for DATA_CLK_period*10;
    --   sync1 <= "0";
    --   QB_RST1 <= "0";

        wait for 100 ns;
        wait for DATA_CLK_period*10;
		QB_RST <= "1"; -- "1111";
        QB_RST1 <= "1";
    --     wait for DATA_CLK_period*1;
    --   sync <= "1";
    --   sync1 <= "1";

      -- hold reset state for 100 ns.
      --wait for 100 ns;	
      wait for DATA_CLK_period*10;
		QB_RST <= "0"; -- "0000";
        QB_RST1 <= "0";
    --     wait for DATA_CLK_period*1;
    --      sync <= "0";
    -- --wait for DATA_CLK_period*10;
    --   sync1 <= "0";
      


    -- wait until SERIAL_CLK_LCK(0) = '1' and TRIG_LINK_SYNC(0) = '1';
    wait until serialClkLck1(0) = '1' and trgLinkSync1(0) = '1';
	wait for DATA_CLK_period*2;
	-- SERIAL_CLK_LCK(0) <= '1';
	-- TRIG_LINK_SYNC(0) <= '1';


        wait for DATA_CLK_period*100;
		QB_RST <= "1"; -- "1111";
        QB_RST1 <= "1";
        wait for DATA_CLK_period*1;
      sync <= "1";
      sync1 <= "1";

      -- hold reset state for 100 ns.
      --wait for 100 ns;	
      wait for DATA_CLK_period*10;
		QB_RST <= "0"; -- "0000";
        QB_RST1 <= "0";
        wait for DATA_CLK_period*1;
         sync <= "0";
    --wait for DATA_CLK_period*10;
      sync1 <= "0";



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
    --write
	wait for DATA_CLK_period;
		DC_CMD <= WORD_WRITE_C;
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0';

		-- address 2, val 1 , reset dc qblink
		wait for DATA_CLK_period*1;
		DC_CMD <= x"000D0002";
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0'; 
        RESP_REQ(0) <= '1';     
    --write
	wait for DATA_CLK_period;
		DC_CMD <= WORD_WRITE_C;
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0';

    -- address 2, val 0, reset dc qblink
		wait for DATA_CLK_period*1;
		DC_CMD <= x"00CD0003";
		CMD_VALID(0) <= '1';
		wait for DATA_CLK_period;
		CMD_VALID(0) <= '0'; 
        RESP_REQ(0) <= '1';   
      wait;
   end process;

END;
