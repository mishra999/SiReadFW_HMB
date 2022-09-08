Library work;
  use work.all;

Library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

  use ieee.std_logic_unsigned.all;
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
  use UNISIM.VComponents.all;

  use work.xgen_axistream_32.all;
  use work.roling_register_p.all;

entity tx_dac_control_axi is
  port (
    clk : in std_logic:='0';


    regIn  :  registerT := registerT_null;

    -- <Axi data in>
    REG_DATA_m2s     : in   axisStream_32_m2s := axisStream_32_m2s_null;
    REG_DATA_s2m     : out  axisStream_32_s2m := axisStream_32_s2m_null;
    -- </Axi data in>

    -- <TX_data_out>
    SIN              : out STD_LOGIC;
    SCLK             : out STD_LOGIC;
    PCLK             : out STD_LOGIC
    -- </TX_data_out>
  ) ;
end entity;

architecture rtl of tx_dac_control_axi is

  type state_t is (
    idle,
    starting,
    running,
    waiting
  );
  signal state : state_t := idle;


  signal  LOAD_PERIOD  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal  LATCH_PERIOD : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal counter_max :  STD_LOGIC_VECTOR(15 downto 0) := x"1000";
  signal  REG_DATA     : STD_LOGIC_VECTOR(18 downto 0) := (others => '0');

  signal  UPDATE       : STD_LOGIC;
  signal  busy		 : std_logic;

  signal REG_DATA_m2s1     : axisStream_32_m2s := axisStream_32_m2s_null;
  signal REG_DATA_s2m1     : axisStream_32_s2m := axisStream_32_s2m_null;
begin

    reg_fifo : entity work.fifo_cc_axi_32 generic map (
    DATA_WIDTH => 19,
    DEPTH => 8
  ) port map (
    clk      =>  clk,
    rst      =>  '0',
    RX_m2s   =>  REG_DATA_m2s,
    RX_s2m   =>  REG_DATA_s2m,

    TX_m2s  => REG_DATA_m2s1,
    TX_s2m  => REG_DATA_s2m1


  );
    



  TX_dac_control : entity work.TARGETX_DAC_CONTROL port map( 
    CLK          => clk,
    LOAD_PERIOD  => LOAD_PERIOD,
    LATCH_PERIOD => LATCH_PERIOD,
    UPDATE       => UPDATE,
    REG_DATA     => REG_DATA,
    busy		 => busy, 

    SIN          => SIN,
    SCLK         => SCLK,
    PCLK         => PCLK

  );

  process(clk) is 
    variable vREG_DATA : axisStream_32_slave := axisStream_32_slave_null;
    variable REG_DATA_buffer :std_logic_vector(31 downto 0):= (others => '0');
    variable counter     :  STD_LOGIC_VECTOR(15 downto 0) := x"0000" ;
 
  begin
    if rising_edge(clk) then 

      pull(vREG_DATA    , REG_DATA_m2s1);
      UPDATE <= '0';
      case state is
        when IDLE => 

          if busy = '0' then 
            counter := x"0000";
            read_data_s(regIn, LOAD_PERIOD,  register_val.DAC_LOAD_PERIOD);
            read_data_s(regIn, LATCH_PERIOD, register_val.DAC_LATCH_PERIOD_PERIOD );
            read_data_s(regIn, counter_max,  register_val.DAC_Wait );

            if isReceivingData(vREG_DATA) then 
              read_data(vREG_DATA, REG_DATA_buffer);
              REG_DATA <= REG_DATA_buffer(REG_DATA'length -1 downto 0 );
              UPDATE <= '1';
              state <= starting;
            end if;

          end if;
        when starting => 
          if busy = '1' then
            state <= running;
          end if;
        when running => 
          if busy = '0' then
            state <= waiting;
            counter := (others => '0');
          end if;
        when waiting => 

          counter := counter +1;
          if counter >= counter_max then
            state <= idle;
            counter := x"0000";
          end if;

      end case;

      push(vREG_DATA  , REG_DATA_s2m1);
    end if;
  end process;

end rtl ; -- rtl