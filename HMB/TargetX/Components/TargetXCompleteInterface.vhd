library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

  use work.tdc_pkg.all;

entity TargetXCompleteInterface is
  generic(
    IS_SIM : string:= "NO";
    NUM_GTS                  : integer := 1;
    DAQ_IFACE            : string :="KEKDAQ"; --the readout interface is KEK DAQ system
    B2TT_SIM_SPEEDUP         : std_logic                     := '0';
    VERSION                  : std_logic_vector(15 downto 0) := X"0019"
  );
  port (
    clk                      : in STD_LOGIC;
    BOARD_CLOCKP             : out  STD_LOGIC;
    BOARD_CLOCKN             : out  STD_LOGIC;
    --LEDS                     : inout STD_LOGIC_VECTOR(12 downto 3);



    --MB Specific Signals
    EX_TRIGGER_MB         : in std_logic;
    EX_TRIGGER_SCROD        : in STD_LOGIC;

    --Global Bus Signals

    ----- ASIC related ports ------
    BUS_REGCLR               : in std_logic;
    --BUS A Specific Signals
    BUSA_WR_ADDRCLR          : in std_logic;
    BUSA_RD_ENA              : in std_logic;
    BUSA_RD_ROWSEL_S         : in std_logic_vector(2 downto 0);
    BUSA_RD_COLSEL_S         : in std_logic_vector(5 downto 0);
    BUSA_CLR                 : in std_logic;
    BUSA_RAMP                : in std_logic;
    BUSA_SAMPLESEL_S         : in std_logic_vector(4 downto 0);
    BUSA_SR_CLEAR            : in std_logic;
    BUSA_SR_SEL              : in std_logic;
    BUSA_DO                  : out  std_logic_vector(15 downto 0);

    --Bus B Specific Signals
    BUSB_WR_ADDRCLR          : in std_logic;
    BUSB_RD_ENA              : in std_logic;
    BUSB_RD_ROWSEL_S         : in std_logic_vector(2 downto 0);
    BUSB_RD_COLSEL_S         : in std_logic_vector(5 downto 0);
    BUSB_CLR                 : in std_logic;
    BUSB_RAMP                : in std_logic;
    BUSB_SAMPLESEL_S         : in std_logic_vector(4 downto 0);
    BUSB_SR_CLEAR            : in std_logic;
    BUSB_SR_SEL              : in std_logic;
    BUSB_DO                  : out  std_logic_vector(15 downto 0);

    --ASIC DAC Update Signals
    SIN                      : in std_logic_vector(9 downto 0);
    PCLK                     : in std_logic_vector(9 downto 0);
    SHOUT                    : out  std_logic_vector(9 downto 0); 
    SCLK                     : in std_logic_vector(9 downto 0);

    --Digitization and sampling signals
    WL_CLK                 : in std_logic_vector(9 downto 0); 
    
    WR1_ENA                  : in std_logic_vector(9 downto 0);
    WR2_ENA                  : in std_logic_vector(9 downto 0);

    SSTIN                  : in std_logic_vector(9 downto 0);
    

    --Serial Readout Signals
    SR_CLOCK                 : in std_logic_vector(9 downto 0);
    SAMPLESEL_ANY            : in std_logic_vector(9 downto 0);
    -------------------------------

    -- MPPC HV DAC
    BUSA_SCK_DAC           : in std_logic;
    BUSA_DIN_DAC           : in std_logic;
    BUSB_SCK_DAC           : in std_logic;
    BUSB_DIN_DAC           : in std_logic;
    --


    -- TRIGGER SIGNALS
    TARGET_TB                : out tb_vec_type;
    --target_tb16              : out std_logic_vector(1 to TDC_NUM_CHAN);

    TDC_CS_DAC               : in std_logic_vector(9 downto 0); 

    TDC_AMUX_S               : in std_logic_vector(3 downto 0); -- what the difference between these two?
    TOP_AMUX_S               : in std_logic_vector(3 downto 0); -- TODO: check schematic


    --New Stuff for TargetX:
    --RAM:
    RAM_A                    : in std_logic_vector(21 downto 0);  -- RAM address line
    --RAM_IO                   : inout std_logic_vector(7 downto 0); -- RAM IO data line     
    RAM_CE1n                 : in std_logic := '1';                                         
    RAM_CE2                  : in std_logic := '0';                           
    RAM_OEn                  : in std_logic := '1';                       
    RAM_WEn                 : in std_logic := '1';                         

    --- MPPC ADC
    --SCL_MON                  : in STD_LOGIC;
    --SDA_MON                  : inout STD_LOGIC;
    ---

    --TMP                      : in std_logic_vector(31 downto 0);

    TDC_DONE                 : out STD_LOGIC_VECTOR(9 downto 0); -- move to readout signals
    TDC_MON_TIMING           : out STD_LOGIC_VECTOR(9 downto 0)  -- add the ref to the programming of the TX chip

  );
end entity;

architecture rtl of TargetXCompleteInterface is
begin
end architecture;