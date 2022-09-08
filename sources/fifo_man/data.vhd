library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TwoTC_DataDecoder is
 port(
     address: 	in	std_logic_vector(4 downto 0);
     dataOut :		out std_logic_vector(31 downto 0);
     
     dataIN_0 :		in std_logic_vector(31 downto 0);
     dataIN_1 :		in std_logic_vector(31 downto 0);
     dataIN_2 :		in std_logic_vector(31 downto 0);
     dataIN_3 :		in std_logic_vector(31 downto 0);
     dataIN_4 :		in std_logic_vector(31 downto 0);
     dataIN_5 :		in std_logic_vector(31 downto 0);
     dataIN_6 :		in std_logic_vector(31 downto 0);
     dataIN_7 :		in std_logic_vector(31 downto 0);
     dataIN_8 :		in std_logic_vector(31 downto 0);
     dataIN_9 :		in std_logic_vector(31 downto 0);
     dataIN_10 :		in std_logic_vector(31 downto 0);
     dataIN_11 :		in std_logic_vector(31 downto 0);
     dataIN_12 :		in std_logic_vector(31 downto 0);
     dataIN_13 :		in std_logic_vector(31 downto 0);
     dataIN_14 :		in std_logic_vector(31 downto 0);
     dataIN_15 :		in std_logic_vector(31 downto 0);
     dataIN_16 :		in std_logic_vector(31 downto 0);
     dataIN_17 :		in std_logic_vector(31 downto 0);
     dataIN_18 :		in std_logic_vector(31 downto 0);
     dataIN_19 :		in std_logic_vector(31 downto 0);
     dataIN_20 :		in std_logic_vector(31 downto 0);
     dataIN_21 :		in std_logic_vector(31 downto 0);
     dataIN_22 :		in std_logic_vector(31 downto 0);
     dataIN_23 :		in std_logic_vector(31 downto 0);
     dataIN_24 :		in std_logic_vector(31 downto 0);
     dataIN_25 :		in std_logic_vector(31 downto 0);
     dataIN_26 :		in std_logic_vector(31 downto 0);
     dataIN_27 :		in std_logic_vector(31 downto 0);
     dataIN_28 :		in std_logic_vector(31 downto 0);
     dataIN_29 :		in std_logic_vector(31 downto 0);
     dataIN_30 :		in std_logic_vector(31 downto 0);
     dataIN_31 :		in std_logic_vector(31 downto 0)
     
     
     
    
  );
end TwoTC_DataDecoder;

architecture bhv of TwoTC_DataDecoder is
begin

dataOut <=  dataIN_0   when address = "00000" else
	        dataIN_1   when address = "00001" else
	        dataIN_2   when address = "00010" else
	        dataIN_3   when address = "00011" else
	        dataIN_4   when address = "00100" else
	        dataIN_5   when address = "00101" else
	        dataIN_6   when address = "00110" else
	        dataIN_7   when address = "00111" else
	        dataIN_8   when address = "01000" else
	        dataIN_9   when address = "01001" else
	        dataIN_10  when address = "01010" else
	        dataIN_11  when address = "01011" else
	        dataIN_12  when address = "01100" else
	        dataIN_13  when address = "01101" else
	        dataIN_14  when address = "01110" else
	        dataIN_15  when address = "01111" else
			dataIN_16   when address = "10000" else
			dataIN_17   when address = "10001" else
			dataIN_18   when address = "10010" else
			dataIN_19   when address = "10011" else
			dataIN_20   when address = "10100" else
			dataIN_21   when address = "10101" else
			dataIN_22   when address = "10110" else
			dataIN_23  when address = "10111" else
			dataIN_24   when address = "11000" else
			dataIN_25   when address = "11001" else
			dataIN_26  when address = "11010" else
			dataIN_27  when address = "11011" else
			dataIN_28  when address = "11100" else
			dataIN_29  when address = "11101" else
			dataIN_30  when address = "11110" else
			dataIN_31  when address = "11111" else
			(others => '0');

	
	
	
	
		
end bhv;
