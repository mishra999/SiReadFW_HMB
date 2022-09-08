library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.xgen_klm_scrod_bus.all;

entity TX_Singal2Obj is
  port (

    TXBus_m2s : out  DataBus_m2s :=  DataBus_m2s_null;
    TXBus_s2m : in DataBus_s2m:= DataBus_s2m_null;
    
    
    -- Input signals 
    BUS_CLR            : out std_logic := '0';
    BUS_RAMP           : out std_logic := '0';
    BUS_WR_ADDRCLR     : out std_logic := '0'; 
    BUS_DO             : in std_logic_vector(15 downto 0) := (others =>'0');
    BUS_RD_COLSEL_S    : out std_logic_vector(5 downto 0) := (others =>'0');
    BUS_RD_ENA         : out std_logic := '0';
    BUS_RD_ROWSEL_S    : out std_logic_vector(2 downto 0) := (others =>'0');
    BUS_SAMPLESEL_S    : out std_logic_vector(4 downto 0) := (others =>'0');
    BUS_SR_CLEAR       : out std_logic := '0';
    BUS_SR_SEL         : out std_logic := '0';
    
    SAMPLESEL_ANY   : out std_logic_vector(4 downto 0)  := (others => '0') ;
    SR_CLOCK        : out std_logic_vector(4 downto 0)  := (others => '0') ; 
    WR1_ENA         : out std_logic_vector(4 downto 0)  := (others => '0')  ;
    WR2_ENA         : out std_logic_vector(4 downto 0)  := (others => '0')  
    
  );
end entity;

architecture rtl of TX_Singal2Obj is
begin
  
  
  TXBus_m2s.ShiftRegister.data_out  <= BUS_DO;

  BUS_WR_ADDRCLR                <= TXBus_s2m.WriteSignals.clear;  
  WR1_ENA                       <= TXBus_s2m.WriteSignals.writeEnable_1;  
  WR2_ENA                       <= TXBus_s2m.WriteSignals.writeEnable_2;  

  BUS_CLR                      <= TXBus_s2m.SamplingSignals.clr; 
  BUS_RAMP                     <= TXBus_s2m.SamplingSignals.ramp;
  BUS_RD_COLSEL_S              <= TXBus_s2m.SamplingSignals.read_column_select_s;  
  BUS_RD_ENA                   <= TXBus_s2m.SamplingSignals.read_enable;
  BUS_RD_ROWSEL_S              <= TXBus_s2m.SamplingSignals.read_row_select_s; 

  BUS_SAMPLESEL_S              <= TXBus_s2m.ShiftRegister.SampleSelect;
  BUS_SR_CLEAR                 <= TXBus_s2m.ShiftRegister.sr_clear;
  BUS_SR_SEL                   <= TXBus_s2m.ShiftRegister.sr_select ;
  SAMPLESEL_ANY                <= TXBus_s2m.ShiftRegister.SampleSelectAny;
  SR_CLOCK                     <= TXBus_s2m.ShiftRegister.sr_Clock;
end architecture;