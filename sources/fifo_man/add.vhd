library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TwoTARGETCs_AddressDecoder is
 port(
     address: 	in	std_logic_vector(4 downto 0);
     rd_en:		in	std_logic;
     decode:	out std_logic_vector(31 downto 0)
  );
end TwoTARGETCs_AddressDecoder;

architecture bhv of TwoTARGETCs_AddressDecoder is
begin

	decode(0)	<= '1' when rd_en = '1' and address = "00000" else '0';
	decode(1)	<= '1' when rd_en = '1' and address = "00001" else '0';
	decode(2)	<= '1' when rd_en = '1' and address = "00010" else '0';
	decode(3)	<= '1' when rd_en = '1' and address = "00011" else '0';
	
	decode(4)	<= '1' when rd_en = '1' and address = "00100" else '0';
	decode(5)	<= '1' when rd_en = '1' and address = "00101" else '0';
	decode(6)	<= '1' when rd_en = '1' and address = "00110" else '0';
	decode(7)	<= '1' when rd_en = '1' and address = "00111" else '0';
	
	decode(8)	<= '1' when rd_en = '1' and address = "01000" else '0';
	decode(9)	<= '1' when rd_en = '1' and address = "01001" else '0';
	decode(10)	<= '1' when rd_en = '1' and address = "01010" else '0';
	decode(11)	<= '1' when rd_en = '1' and address = "01011" else '0';
	
	decode(12)	<= '1' when rd_en = '1' and address = "01100" else '0';
	decode(13)	<= '1' when rd_en = '1' and address = "01101" else '0';
	decode(14)	<= '1' when rd_en = '1' and address = "01110" else '0';
	decode(15)	<= '1' when rd_en = '1' and address = "01111" else '0';
	
	decode(16)	<= '1' when rd_en = '1' and address = "10000" else '0';
	decode(17)	<= '1' when rd_en = '1' and address = "10001" else '0';
	decode(18)	<= '1' when rd_en = '1' and address = "10010" else '0';
	decode(19)	<= '1' when rd_en = '1' and address = "10011" else '0';
	
	decode(20)	<= '1' when rd_en = '1' and address = "10100" else '0';
	decode(21)	<= '1' when rd_en = '1' and address = "10101" else '0';
	decode(22)	<= '1' when rd_en = '1' and address = "10110" else '0';
	decode(23)	<= '1' when rd_en = '1' and address = "10111" else '0';
	
	decode(24)	<= '1' when rd_en = '1' and address = "11000" else '0';
	decode(25)	<= '1' when rd_en = '1' and address = "11001" else '0';
	decode(26)	<= '1' when rd_en = '1' and address = "11010" else '0';
	decode(27)	<= '1' when rd_en = '1' and address = "11011" else '0';
	
	decode(28)	<= '1' when rd_en = '1' and address = "11100" else '0';
	decode(29)	<= '1' when rd_en = '1' and address = "11101" else '0';
	decode(30)	<= '1' when rd_en = '1' and address = "11110" else '0';
	decode(31)	<= '1' when rd_en = '1' and address = "11111" else '0';
	
end bhv;
