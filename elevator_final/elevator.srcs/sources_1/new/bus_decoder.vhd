LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY decoder IS
  PORT (
  busIn		: IN std_logic_vector(12 downto 0);

  code		: OUT std_logic_vector(3 downto 0)
    );
END decoder;



ARCHITECTURE TypeArchitecture OF decoder IS

BEGIN
	with busIN select code <= 
	   "0000" when "0000000000001",
	   "0001" when "0000000000010",
	   "0010" when "0000000000100",
	   "0011" when "0000000001000",
	   "0100" when "0000000010000",
	   "0101" when "0000000100000",
	   "0110" when "0000001000000",
	   "0111" when "0000010000000",
	   "1000" when "0000100000000",
	   "1001" when "0001000000000",
	   "1010" when "0010000000000",
	   "1011" when "0100000000000",
	   "1100" when "1000000000000",
	   "1111" when others;
END TypeArchitecture;
