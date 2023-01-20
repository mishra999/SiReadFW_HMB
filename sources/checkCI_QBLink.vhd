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
    signal sstX5Clk : std_logic;
    constant N_GPR : integer := 20;--127;
    type GPR is array(N_GPR-1 downto 0) of std_logic_vector(15 downto 0);
    signal CtrlRegister : GPR:= (others => x"0000");
   -- Clock period definitions
   constant DATA_CLK_period : time := 40 ns;
   constant sst5x_CLK_period : time := 8 ns;
--    constant WORD_READ_C      : std_logic_vector(31 downto 0) := x"72656164";
--    constant WORD_WRITE_C     : std_logic_vector(31 downto 0) := x"72697465";


  --CI signals
	constant WORD_HEADER_C    : std_logic_vector(31 downto 0) := x"00BE11E2";
   constant WORD_COMMAND_C   : std_logic_vector(31 downto 0) := x"646F6974";
   constant WORD_PING_C      : std_logic_vector(31 downto 0) := x"70696E67";
	constant WORD_READ_C      : std_logic_vector(31 downto 0) := x"72656164";
   constant WORD_WRITE_C     : std_logic_vector(31 downto 0) := x"72697465";
   constant WORD_WRITE_DAC	: std_logic_vector(31 downto 0) := x"72697445"; 
   constant WORD_ACK_C       : std_logic_vector(31 downto 0) := x"6F6B6179";
   constant WORD_ERR_C       : std_logic_vector(31 downto 0) := x"7768613f";
	constant ERR_BIT_SIZE_C    : std_logic_vector(31 downto 0) := x"00000001";
   constant ERR_BIT_TYPE_C    : std_logic_vector(31 downto 0) := x"00000002";
   constant ERR_BIT_DEST_C    : std_logic_vector(31 downto 0) := x"00000004";
   constant ERR_BIT_COMM_TY_C : std_logic_vector(31 downto 0) := x"00000008";
   constant ERR_BIT_COMM_CS_C : std_logic_vector(31 downto 0) := x"00000010";
   constant ERR_BIT_CS_C      : std_logic_vector(31 downto 0) := x"00000020";
   constant ERR_BIT_TIMEOUT_C : std_logic_vector(31 downto 0) := x"00000040";
	constant QBLINK_FAILURE_C  : std_logic_vector(31 downto 0) := x"00000500"; --link not up yet error
    constant ZERO : std_logic_vector(15 downto 0) := x"0000";

	constant wordDC				: std_logic_vector(23 downto 0) := x"0000DC"; --command target is one or more DC
	constant broadcastDC       : std_logic_vector(7 downto 0)  := x"0A";

	constant WORD_PACKET_SIZE_C : std_logic_vector(31 downto 0) := x"00000006"; -- 6 words
	constant wordDC_01				: std_logic_vector(31 downto 0) := x"0000DC01"; --command target is one or more DC 
	constant WORD_COMMAND_ID_C  : std_logic_vector(31 downto 0) := x"00000012";
	--Packet checksum for SCROD ping x"4542EB6C" ; For scrod reg Write (Wr_reg = 00010002): x"4944F76C"
	-- For SCROD Reg Read (Rd_reg = 00000002) : x"493AD16A"
	-- For DC01 ping : x"4543226D"   --For DC01 Reg 2 write value 1 (Wr_reg = 00010002): x"49452e6D"
	constant PACKET_CHECKSUM	: std_logic_vector(31 downto 0) := x"4543226D";    
	constant wordScrodRevC	: std_logic_vector(31 downto 0) := x"0000A500";
    
   --Inputs
   signal usrClk : std_logic := '0';
   signal dataClk : std_logic := '0';
   signal usrRst : std_logic := '0';
   signal rxData : std_logic_vector(31 downto 0) := (others => '0');
   signal rxDataValid : std_logic := '0';
   signal rxDataLast : std_logic := '0';
   signal txDataReady : std_logic := '0';
   signal serialClkLck : std_logic_vector(0 downto 0) := (others => '0');
   signal trigLinkSync : std_logic_vector(0 downto 0) := (others => '0');
   signal DC_RESP : std_logic_vector(31 downto 0) := (others => '0');
   signal DC_RESP_VALID : std_logic_vector(0 downto 0) := (others => '0');
   signal EVNT_FLAG : std_logic := '0';
   signal regRdData : std_logic_vector(15 downto 0) := (others => '0');
   signal regAck : std_logic := '0';

 	--Outputs
   signal rxDataReady : std_logic;
   signal txData : std_logic_vector(31 downto 0);
   signal txDataValid : std_logic;
   signal txDataLast : std_logic;
--    signal DC_CMD : std_logic_vector(31 downto 0);
--    signal QB_WrEn : std_logic_vector(0 downto 0);
--    signal QB_RdEn : std_logic_vector(0 downto 0);
   signal regAddr1 : std_logic_vector(15 downto 0);
   signal regWrData1 : std_logic_vector(15 downto 0);
   signal regReq1 : std_logic;
   signal regOp1 : std_logic_vector (1 downto 0);
	signal ldqblink : std_logic;
   signal cmd_int_state : std_logic_vector(4 downto 0);

   signal targetx_reg : std_logic :='0';
	-- signal CtrlRegister : GPR := (others => (others => '0'));
   -- Clock period definitions
   constant usrClk_period : time := 8 ns;
--    constant dataClk_period : time := 40 ns;

BEGIN  
	-- Instantiate the Unit Under Test (UUT)
   uut1: entity work.CommandInterpreter PORT MAP (
          usrClk => usrClk,
          dataClk => DATA_CLK,
          usrRst => usrRst,
          rxData => rxData,
          rxDataValid => rxDataValid,
          rxDataLast => rxDataLast,
          rxDataReady => rxDataReady,
          txData => txData,
          txDataValid => txDataValid,
          txDataLast => txDataLast,
          txDataReady => txDataReady,
          serialClkLck => serialClkLck1,
          trigLinkSync => trgLinkSync1,
          DC_CMD => DC_CMD,
          QB_WrEn => CMD_VALID,
          QB_RdEn => RESP_REQ,
          DC_RESP => DC_RESPONSE,
          DC_RESP_VALID => RESP_VALID,
          EVNT_FLAG => EVNT_FLAG,
          regAddr => regAddr,
          regWrData => regWrData,
          regRdData => regRdData,
          regReq => regReq,
          regOp => regOp,
          regAck => regAck,
	      ldqblink => ldqblink,
          cmd_int_state => cmd_int_state
        ); 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.DC_Comm PORT MAP (
          DATA_CLK => DATA_CLK,
          sstX5Clk => sstX5Clk,
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
			 sstX5Clk => sstX5Clk,
             RX     => TX,
             TX => RX,
			 QB_RST => QB_RST1, 
            DC_RESPONSE => DC_RESPONSEb,
            RES_VALID => RES_VALIDb,
            SERIAL_CLK_LCK => serialClkLck1,
            TRIG_LINK_SYNC => trgLinkSync1,
            sync  => QB_RST1,
            regAddr =>regAddr1,
            regWrData => regWrData1,
            regReq  => regReq1,
            regOp => regOp1      
			 );
	
   -- Clock process definitions
   DATA_CLK_process :process
   begin
		DATA_CLK <= '0';
		wait for DATA_CLK_period/2;
		DATA_CLK <= '1';
		wait for DATA_CLK_period/2;
   end process;


   USR_CLK_process :process
   begin
		usrClk <= '0';
		wait for usrClk_period/2;
		usrClk <= '1';
		wait for usrClk_period/2;
   end process;
   
   sst5x_CLK_process :process
   begin
		sstX5Clk <= '0';
		wait for sst5x_CLK_period/2;
		sstX5Clk <= '1';
		wait for sst5x_CLK_period/2;
   end process;

    -- DC_reset_process : process(DATA_CLK) --unused for now 10/01
    -- ----variable counter : integer range 0 to 2 := 0;
    -- begin 
    --     IF rising_edge(DATA_CLK) THEN
    --     sync1 <= CtrlRegister(2)(0 downto 0);
    --     QB_RST1 <= CtrlRegister(2)(0 downto 0);
    --     --    DC_RESET <= CtrlRegister(2)(NUM_DCs downto 0); --by me
    --     END IF;
    -- end process;


    -- seqnn : process (DATA_CLK) is
    -- begin
    --     if (rising_edge(DATA_CLK)) then
    --         RES_VALIDb(0) <= '0';
    --         DC_RESPONSEb  <= (others => '0');
    --         if QB_RST1 = "1" then
    --             DC_RESPONSEb  <= (others => '0');
            
    --         elsif regReq1 = '1' then
    --             if regOp1 = '0' then
    --                 DC_RESPONSEb <= ZERO & CtrlRegister(to_integer(unsigned(regAddr1)));
    --                 RES_VALIDb(0) <= '1';
    --             elsif regOp1 = '1' then
    --                 CtrlRegister(to_integer(unsigned(regAddr1))) <= regWrData1; 
    --                 DC_RESPONSEb <= ZERO & regAddr1;
    --                 RES_VALIDb(0) <= '1';                
    --             end if;
    --         end if;
    --     end if;
    -- end process; 

    seqnn : process (DATA_CLK) is
    begin
        if (rising_edge(DATA_CLK)) then
            RES_VALIDb(0) <= '0';
            DC_RESPONSEb  <= (others => '0');
            targetx_reg <= '0';
            
            if QB_RST1 = "1" then
                DC_RESPONSEb  <= (others => '0');
                -- regAddr  <= (others => '0');
                -- regWrData  <= (others => '0');
            
            elsif regReq1 = '1' then
                if regOp1 = "00" then
                    DC_RESPONSEb <=  ZERO & CtrlRegister(to_integer(unsigned(regAddr1)));
                    RES_VALIDb(0) <= '1';
                elsif regOp1 = "01" then
                    CtrlRegister(to_integer(unsigned(regAddr1))) <= regWrData1; 
                    DC_RESPONSEb <=  ZERO & regAddr1;
                    RES_VALIDb(0) <= '1';  
                elsif regOp1 = "10" then
                    DC_RESPONSEb <=  ZERO & regAddr1;
                    RES_VALIDb(0) <= '1';   
                    targetx_reg <= '1';            
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
        -- CtrlRegister(10)<=x"CABC";
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
      


    wait until TRIG_LINK_SYNC(0) = '1';
    -- wait until serialClkLck1(0) = '1' and trgLinkSync1(0) = '1';
	wait for DATA_CLK_period*2;
	-- SERIAL_CLK_LCK(0) <= '1';
	-- TRIG_LINK_SYNC(0) <= '1';


    --     wait for DATA_CLK_period*100;
	-- 	QB_RST <= "1"; -- "1111";
    --     QB_RST1 <= "1";
    --     wait for DATA_CLK_period*1;
    --   sync <= "1";
    --   sync1 <= "1";

    --   -- hold reset state for 100 ns.
    --   --wait for 100 ns;	
    --   wait for DATA_CLK_period*10;
	-- 	QB_RST <= "0"; -- "0000";
    --     QB_RST1 <= "0";
    --     wait for DATA_CLK_period*1;
    --      sync <= "0";
    -- --wait for DATA_CLK_period*10;
    --   sync1 <= "0";



--	



    wait for usrClk_period*10;
	
		rxDataValid <= '1';
		rxDataLast <= '0';
		rxData <= WORD_HEADER_C;  
		
		
      wait until rxDataReady = '1';
		wait for usrClk_period;

		rxData <= WORD_PACKET_SIZE_C;

		wait for usrClk_period;

		rxData <= WORD_COMMAND_C;
		wait for usrClk_period;

		rxData <= wordDC_01;     --wordDC_01;          --wordScrodRevC;
		
		wait for usrClk_period;
		
		rxData <= WORD_COMMAND_ID_C;
		wait for usrClk_period;
		--WORD_PING_C | WORD_WRITE_C | WORD_READ_C depending upon type of command
		rxData <= WORD_WRITE_DAC;  --WORD_WRITE_C;  --WORD_PING_C
--- only for Reg Wr/Rd command--	
-- first 4 MSBs are Reg Value, last 4 [LSBs] are Reg Addr
-- For Reg Read command, Reg Value [4 MSBs] = 0000 by default, give address in last 4.
      wait for usrClk_period;
      rxData <= x"0006000A";  -- x"0006000A";         
-----------------------------		
	  wait for usrClk_period;
 
	-- Command Checksum: for ping x"70696e79" -- for write (Reg 2 value 1: 00010002)=>x"726A7479"	
	-- for Read (Reg 2: 00000002) => x"72656178"
		rxData <= x"726f7461";  --x"726f7481";  x"726f7461";
        -- rxDataLast <= '1';       
		txDataReady <= '1';

        -- rxDataValid <= '0';
		

		wait for usrClk_period;

		-- rxData <= PACKET_CHECKSUM;
        -- wait for usrClk_period;
        rxDataLast <= '1';
        wait for usrClk_period;
        rxDataLast <= '0';
        rxDataValid <= '0';
        -- txDataReady <= '0';
      wait for usrClk_period*10;
    --   txDataReady <= '0';
      wait for usrClk_period*10;
      wait until txdatalast='1';
      txDataReady <= '0';



--read it back
    wait for usrClk_period*10;
    wait for 1600 ns;
	
		rxDataValid <= '1';
		rxDataLast <= '0';
		rxData <= WORD_HEADER_C;  
		
		
      wait until rxDataReady = '1';
		wait for usrClk_period;

		rxData <= WORD_PACKET_SIZE_C;

		wait for usrClk_period;

		rxData <= WORD_COMMAND_C;
		wait for usrClk_period;

		rxData <= wordDC_01;     --wordDC_01;          --wordScrodRevC;
		
		wait for usrClk_period;
		
		rxData <= WORD_COMMAND_ID_C;
		wait for usrClk_period;
		--WORD_PING_C | WORD_WRITE_C | WORD_READ_C depending upon type of command
		rxData <= WORD_READ_C;  --WORD_PING_C
--- only for Reg Wr/Rd command--	
-- first 4 MSBs are Reg Value, last 4 [LSBs] are Reg Addr
-- For Reg Read command, Reg Value [4 MSBs] = 0000 by default, give address in last 4.
      wait for usrClk_period;
      rxData <= x"0000000A";         
-----------------------------		
		wait for usrClk_period;

	-- Command Checksum: for ping x"70696e79" -- for write (Reg 2 value 1: 00010002)=>x"726A7479"	
	-- for Read (Reg 2: 00000002) => x"72656178"
		rxData <= x"72656180";        
		txDataReady <= '1';

        -- rxDataValid <= '0';
		

		wait for usrClk_period;

		-- rxData <= PACKET_CHECKSUM;
        wait for usrClk_period;
        rxDataLast <= '1';
        wait for usrClk_period;
        rxDataLast <= '0';
        rxDataValid <= '0';
        -- txDataReady <= '0';
      wait for usrClk_period*10;
    --   txDataReady <= '0';
      wait for usrClk_period*10;
      wait until txdatalast='1';
      txDataReady <= '0';
      wait;


	-- wait for DATA_CLK_period*2;
	-- 	DC_CMD <= WORD_READ_C;
	-- 	CMD_VALID(0) <= '1';
	-- 	wait for DATA_CLK_period;
	-- 	CMD_VALID(0) <= '0';


	-- 	wait for DATA_CLK_period*1;
	-- 	DC_CMD <= x"00000002";
	-- 	CMD_VALID(0) <= '1';
	-- 	wait for DATA_CLK_period;
	-- 	CMD_VALID(0) <= '0'; 
    --     RESP_REQ(0) <= '1';    
    -- --write
	-- wait for DATA_CLK_period;
	-- 	DC_CMD <= WORD_WRITE_C;
	-- 	CMD_VALID(0) <= '1';
	-- 	wait for DATA_CLK_period;
	-- 	CMD_VALID(0) <= '0';

	-- 	-- address 2, val 1 , reset dc qblink
	-- 	wait for DATA_CLK_period*1;
	-- 	DC_CMD <= x"000D0002";
	-- 	CMD_VALID(0) <= '1';
	-- 	wait for DATA_CLK_period;
	-- 	CMD_VALID(0) <= '0'; 
    --     RESP_REQ(0) <= '1';     
    -- --write
	-- wait for DATA_CLK_period;
	-- 	DC_CMD <= WORD_WRITE_C;
	-- 	CMD_VALID(0) <= '1';
	-- 	wait for DATA_CLK_period;
	-- 	CMD_VALID(0) <= '0';

    -- -- address 2, val 0, reset dc qblink
	-- 	wait for DATA_CLK_period*1;
	-- 	DC_CMD <= x"00CD0003";
	-- 	CMD_VALID(0) <= '1';
	-- 	wait for DATA_CLK_period;
	-- 	CMD_VALID(0) <= '0'; 
    --     RESP_REQ(0) <= '1';   
    --   wait;
   end process;

END;
