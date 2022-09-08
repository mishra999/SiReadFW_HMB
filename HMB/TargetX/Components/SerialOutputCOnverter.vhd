library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use work.xgen_axiStream_32.all;
  use work.roling_register_p.all;
  use work.UtilityPkg.all;
  use work.roling_register_p.all;
  use work.klm_scint_globals.all;

entity SerialOutputCOnverter is
  port (
    globals : globals_t := globals_t_null;    

    axDataIn_m2s :  in   axisStream_32_m2s := axisStream_32_m2s_null;
    axDataIn_s2m :  out  axisStream_32_s2m  := axisStream_32_s2m_null;

    axDataOut_m2s :  out   axisStream_32_m2s := axisStream_32_m2s_null;
    axDataOut_s2m :  in    axisStream_32_s2m  := axisStream_32_s2m_null

  );
end entity;

architecture rtl of SerialOutputCOnverter is
  signal i_buffer : Word12Array(15 downto 0) := (others => (others => '0'));
  signal i_buffer_rev : Word12Array(15 downto 0) := (others => (others => '0'));

  signal   WordCounter     : integer := 0;
  signal   i_reg           :  registerT:= registerT_null;
  signal i_revers_bit_order : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal NOTMask            : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');


begin

  process(globals.clk) is 
    variable rx: axisStream_32_slave:= axisStream_32_slave_null;
    variable tx : axisStream_32_master := axisStream_32_master_null;
    variable buff : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    variable buffAfterNotMask : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    variable buff_data   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    variable buff_sample : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    variable buff_sample_int : integer :=0;
    variable isSending: boolean := false;
    variable EOS_buffer :  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

  begin
    if rising_edge(globals.clk) then
      pull(rx, axDataIn_m2s);
      pull(tx, axDataOut_s2m);
      if isReceivingData(rx) and not isSending then 
        if WordCounter < 2   then
          if ready_to_send(tx) then 
            WordCounter <= WordCounter +1;
            read_data(rx, buff);
            send_data(tx, buff);

          end if;
        elsif IsEndOfStream(rx) then
          read_data(rx, EOS_buffer);
          isSending :=  true;
          WordCounter <= 0;
        else 
          read_data(rx, buff);
          WordCounter <= WordCounter +1;
          buff_data := buff(15 downto 0);

          if 2 <= WordCounter and  WordCounter < 14  then
            for i in 0 to buff_data'length - 1 loop

              i_buffer(i)(WordCounter-2) <= buff_data(i);
              i_buffer_rev(i)(11 -(WordCounter-2)) <= buff_data(i);
            end loop;  
          end if;
        end if;


      elsif isSending then

        if WordCounter > 15 and ready_to_send(tx) then
          isSending := false;
          send_data(tx, EOS_buffer);
          Send_end_Of_Stream(tx,true);
          WordCounter <= 0;
        elsif ready_to_send(tx) then 
          WordCounter <= WordCounter +1;
          if i_revers_bit_order(0) = '1' then
            buff(11 downto 0) := i_buffer_rev(WordCounter);
          else
            buff(11 downto 0) := i_buffer(WordCounter);
          end if;
          buffAfterNotMask(11 downto 0) := (buff(11 downto 0)  and not NOTMask(11 downto 0) ) or (not buff(11 downto 0)  and NOTMask(11 downto 0) );
          send_data(tx, buffAfterNotMask);
        end if;

      end if;


      push(tx, axDataOut_m2s);
      push (rx, axDataIn_s2m);

    end if;
  end process;

  process(globals.clk) is
  begin
    if rising_edge(globals.clk) then
      read_data_s(i_reg,  i_revers_bit_order, register_val.serielOutConverter_invert_bit_order);
      read_data_s(i_reg,  NOTMask,            register_val.serielOutConverter_notMask);

    end if;
  end process;

  reg_buffer : entity work.registerBuffer generic map (
    Depth =>  5
  ) port map (

    clk => globals.clk,
    registersIn   => globals.reg,
    registersOut  => i_reg
  );
end architecture;