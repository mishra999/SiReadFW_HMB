library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.targetx_WaveFormReadout_t.all;
  use work.TXWaveFormPGK.all;
  use work.StateMachneBase.all;

entity TXWaveFormConnection is
  port (
    clk                          : in  std_logic;
    rst                          : in  std_logic;
    Sim_Channel_in               : in  TX_Channel_t := TX_Channel_t_null;
    Sim_Channel_0                : out STD_LOGIC_VECTOR(11  downto 0);
    sim_ReadSelect               : in  targetx_MemBuffer := targetx_MemBuffer_null;
    TX_waveFormM2S               : out targetx_WaveFormReadout_m2s :=targetx_WaveFormReadout_m2s_null;
    TX_waveFormS2M               : Out targetx_WaveFormReadout_s2m :=targetx_WaveFormReadout_s2m_null;
    shift_register_index_out     : out integer := 0; 
    req_ReadSelect               : in  targetx_MemBuffer := targetx_MemBuffer_null;
    req_valid                    : in STD_LOGIC := '0';
    Data_out                     : out STD_LOGIC_VECTOR(TX_BufferDepts - 1 downto 0)  := (others => '0');
    data_valid                   : out STD_LOGIC := '0';
    ChannelNr                    : out integer := 0;
    sim_out_MemAddress           : out targetx_MemBuffer := targetx_MemBuffer_null;
    
    
    OutputStorageState           : out integer := 0;
    currentTransistionVector     : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    StateTransistionVector       : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0')
  );
end entity;

architecture rtl of TXWaveFormConnection is
  



  signal TXm2s : targetx_WaveFormReadout_m2s;
  signal TXs2m:  targetx_WaveFormReadout_s2m ;
  
begin
  
  TX_waveFormS2M <= TXs2m;
  TX_waveFormM2S  <= TXm2s;

  sim_DUT : entity work.TXWaveFormOutputStorage port  map(
    clk                      =>    clk,
    rst                      =>    rst,
    Sim_StorageAddress       =>    sim_ReadSelect,
    Sim_Channel_0            =>    Sim_Channel_0,
    Sim_Channel_in           =>    Sim_Channel_in,
    TX_waveFormM2S           =>    TXm2s,
    TX_waveFormS2M           =>    TXs2m,
    ConnectionState          =>    open,
    currentTransistionVector =>    open,
    StateTransistionVector   =>    open, 
    shift_register_index_out =>    shift_register_index_out,
    sim_out_MemAddress       =>    sim_out_MemAddress
    
  );
     
  
  sim_out : entity work.TXWaveFormReadout port map(
    clk => clk,
    rst => rst,


    TX_waveFormM2S     =>  TXm2s,
    TX_waveFormS2M     =>  TXs2m,

    req_ReadSelect     =>  req_ReadSelect,
    req_valid          =>  req_valid,
    Data_out           =>  Data_out,  
    valid              =>  data_valid,            
    ChannelNr          =>  ChannelNr ,
    State              =>  OutputStorageState,
    currentTransistionVector =>    currentTransistionVector,
    StateTransistionVector   =>    StateTransistionVector
  );

end architecture;