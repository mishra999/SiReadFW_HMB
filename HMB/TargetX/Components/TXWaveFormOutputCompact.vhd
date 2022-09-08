library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;
  use work.TXWaveFormPGK.all;

  use work.targetx_WaveFormReadout_t.all;
  use work.targetx_WaveFormReadout_m.all;
  use work.StateMachneBase.all;
  use work.type_conversions_pgk.all;

entity TXWaveFormOutputCompact is
  port (
    clk: in  std_logic;
    rst: in  std_logic;

    
    TX_waveFormM2S            : out targetx_WaveFormReadout_m2s :=targetx_WaveFormReadout_m2s_null;
    TX_waveFormS2M            : in  targetx_WaveFormReadout_s2m :=targetx_WaveFormReadout_s2m_null;

    shift_register_index_out  : out integer := 0;
    sim_out_MemAddress        : out targetx_MemBuffer := targetx_MemBuffer_null;


    Sim_Channel_0             : out STD_LOGIC_VECTOR(11  downto 0)  := (others => '0');   
    ConnectionState : out integer := 0;
    currentTransistionVector : out StateMachineInput_t := (others => '0');
    StateTransistionVector   : out StateMachineInput_t := (others => '0')
  );
end entity;

architecture rtl of TXWaveFormOutputCompact is

  
  type data_dummy_type_array is array ( 16  downto 0 ) of std_logic_vector(31 downto 0);
  signal dataDummy_all :data_dummy_type_array:= (others => (others => '0'));


      
 signal memIndex_sig: std_logic_vector(31 downto 0) := (others => '0');

 signal   RowNumber1                 :  integer := 0;  
begin
  
  

  
  process(clk)
    variable TXWaveForm :  targetx_WaveFormReadout_master := targetx_WaveFormReadout_master_null; 
    variable v_column : integer := 0;
    variable v_row : integer := 0;
    variable v_sampleNR : integer := 0;
    variable dataDummy : std_logic_vector(TX_Channels - 1 downto 0) := (others => '0');


    variable memBuff : targetx_MemBuffer := targetx_MemBuffer_null;
    variable memIndex: std_logic_vector(31 downto 0) := (others =>'0');
    variable memIndex_int: integer := 0;
    
    variable pos_index : integer := 0;
                                 
  begin 
    if (rising_edge(clk)) then 
      pull_targetx_WaveFormReadout_master(TXWaveForm, TX_waveFormS2M);
  
      if (RampRequested(TXWaveForm)) then 
        GetAddress(TXWaveForm , v_row ,v_column);
        memBuff.Column   := std_logic_vector(to_unsigned( v_column , memBuff.Column'length)); 
        memBuff.Row      := std_logic_vector(to_unsigned( v_row ,  memBuff.Row'length)); 
        MemBuffer2slv(memBuff,memIndex);
        memIndex_int := to_integer(signed(memIndex));
        pos_index := 0;
        for I in 0 to 15   loop
            pos_index := pos_index +1;
            dataDummy_all(I) <= std_logic_vector(to_unsigned(  memIndex_int * 16*16*16  + pos_index*16*16, 32));
        end loop;
      end if;
      
      if(SamplingRequested(TXWaveForm)) then 
        GetSampleNumber(TXWaveForm,v_sampleNR);
        memBuff.SampleNr :=std_logic_vector(to_unsigned(  v_sampleNR , memBuff.SampleNr'length));
		  pos_index := 0;       
		  for I in 0 to 15   loop
				pos_index := pos_index +1;
            dataDummy_all(I) <= std_logic_vector(to_unsigned(  memIndex_int * 16*16*16  + pos_index*16*16 +v_sampleNR, 32));
        end loop;
		  
      end if;

      if(IsReadyToSend(TXWaveForm)) then 
        MemBuffer2slv(memBuff,memIndex);
        memIndex_int := to_integer(signed(memIndex));
        for I in 0 to dataDummy'length -1  loop
          dataDummy(I) := dataDummy_all(I)(TXWaveForm.ShiftRegister_index );
			 Sim_Channel_0(TXWaveForm.ShiftRegister_index) <=  dataDummy_all(2)(TXWaveForm.ShiftRegister_index );  
        end loop;
      shift_register_index_out <= TXWaveForm.ShiftRegister_index;  
      SendBit(TXWaveForm ,dataDummy);

      end if;
      --Sim_Channel_0 <= std_logic_vector(to_unsigned( memIndex_int,Sim_Channel_0'length));-- mem(0)(v_sampleNR);
      if is_ShiftDataClockReceived( TXWaveForm.stateMachine ) and TXWaveForm.ShiftRegister_index <12 then 
        
      end if;
      if is_SampleSelectClockDone( TXWaveForm.stateMachine ) then 
        Sim_Channel_0 <= (others => '0');
      end if;
      sim_out_MemAddress<= memBuff;
      


     -- Sim_Channel_0 <= std_logic_vector(to_unsigned( 1546 , Sim_Channel_0'length));
      push_targetx_WaveFormReadout_master(TXWaveForm, TX_waveFormM2S);
      ConnectionState <= StM_state2int( TXWaveForm.stateMachine);
      currentTransistionVector <= TXWaveForm.stateMachine.CurrentStateVector;
      StateTransistionVector   <= TXWaveForm.stateMachine.TransitionVector   and TXWaveForm.stateMachine.TransitionVectorMask;
      

    end if;
  end process;

  
  

end architecture;