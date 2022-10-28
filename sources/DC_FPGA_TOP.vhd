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

        -- SYSCLK_P       	 :  IN sl;
        -- SYSCLK_N       	 :  IN sl;
        DATA_CLK_P        : IN sl;
        DATA_CLK_N        : IN sl;
        RX_DC_P			 : IN slv(NUM_DCs downto 0);  --SERIAL INPUT FROM DC
        RX_DC_N			 : IN slv(NUM_DCs  downto 0);  --SERIAL INPUT FROM DC
        TX_DC_N         : OUT slv(NUM_DCs downto 0);  --Serial output to DC
        TX_DC_P			 : OUT slv(NUM_DCs downto 0)--Serial output to DC 
        -- SYNC_P			 : OUT slv(NUM_DCs downto 0); -- when '0' DC listens only, '1' DC reads back command
        -- SYNC_N			 : OUT slv(NUM_DCs downto 0);
        

        -- DC_RESET        : in slv(NUM_DCs DOWNTO 0)		-- Commented by Shivang on Oct 8, 2020
  );
end entity;


architecture rtl of DC_FPGA_TOP is
    -- signal i_clk              : std_logic;
  	signal tx_dc		 : slv(NUM_DCs downto 0); --transmitted serial data bit 
	signal rx_dc		 : slv(NUM_DCs downto 0); --recieved serial data bit
    signal QB_RST :  slv(NUM_DCs downto 0) := (others => '0');
    signal DATA_CLK        : sl;
    signal SERIAL_CLK_LCK :  slv(NUM_DCs downto 0);
    signal TRIG_LINK_SYNC :  slv(NUM_DCs downto 0);

    signal SYNC :  STD_LOGIC_VECTOR (NUM_DCs downto 0); --Universal sync signal
    signal regAddr : std_logic_vector(15 downto 0);
    signal regWrData : std_logic_vector(15 downto 0);
    signal regReq    : sl;
    signal regOp     : sl;
    signal DC_RESPONSE : slv (31 downto 0); 
    signal RES_VALID : slv( NUM_DCs downto 0); 
	-- signal  GLOB_EVNT_P :  STD_LOGIC_VECTOR(3 downto 0);
    -- signal GLOB_EVNT_N :  STD_LOGIC_VECTOR(3 downto 0);
    -- signal  GLOB_EVNT :  STD_LOGIC_VECTOR(3 downto 0);
    constant N_GPR : integer := 20;--127;
    type GPR is array(N_GPR-1 downto 0) of std_logic_vector(15 downto 0);   
    signal CtrlRegister : GPR:= (others => x"9987");

begin


DC_IO_BUFF : entity work.IO_Buffers_new
generic map (num_DC => NUM_DCs)
PORT MAP(
	RX_P => RX_DC_P,
	RX_N => RX_DC_N,
	TX => tx_dc,
    DATA_CLK_P => DATA_CLK_P,
    DATA_CLK_N => DATA_CLK_N,
    DATA_CLK => DATA_CLK, --by me
	-- GLOB_EVNT => GLOB_EVNT,
	-- SYNC => sync,   
	TX_P => TX_DC_P,
	TX_N => TX_DC_N,
	-- GLOB_EVNT_P => GLOB_EVNT_P,
	-- GLOB_EVNT_N => GLOB_EVNT_N,
	RX => rx_dc
	-- SYNC_P => SYNC_P,
	-- SYNC_N => SYNC_N
	);

u_dc_receiver : entity work.DC_Comm_back port map(
    DATA_CLK => DATA_CLK,
    RX => rx_dc,
    TX =>tx_dc,
    QB_RST => QB_RST,
    DC_RESPONSE => DC_RESPONSE,
    RES_VALID => RES_VALID,            
    SERIAL_CLK_LCK => SERIAL_CLK_LCK,
    TRIG_LINK_SYNC => TRIG_LINK_SYNC,
    regAddr =>regAddr,
    regWrData => regWrData,
    regReq  => regReq,
    regOp => regOp,       
    sync => sync
);

    DC_reset_process : process(DATA_CLK) --unused for now 10/01
    ----variable counter : integer range 0 to 2 := 0;
    begin 
        IF rising_edge(DATA_CLK) THEN
        sync <= CtrlRegister(2)(NUM_DCs downto 0);
        QB_RST <= CtrlRegister(2)(NUM_DCs downto 0);
        --    DC_RESET <= CtrlRegister(2)(NUM_DCs downto 0); --by me
        END IF;
    end process;


    seqnn : process (DATA_CLK) is
    begin
        if (rising_edge(DATA_CLK)) then
            RES_VALID(0) <= '0';
            if QB_RST = '1' then
                DC_RESPONSE  <= (others => '0');
            
            elsif regReq = '1' then
                if regOp = '0' then
                    DC_RESPONSE(31 downto 0) <= "0000" + CtrlRegister(to_integer(unsigned(regAddr)));
                    RES_VALID(0) <= '1';
                elsif regOp = '1' then
                    CtrlRegister(to_integer(unsigned(regAddr))) <= regWrData; 
                    DC_RESPONSE(31 downto 0) <= "0000" + regAddr;
                    RES_VALID(0) <= '1';                
                end if;
            end if;
        end if;
    end process;

end architecture;