library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity frequencyDividerTo1Hz is
    Port ( board_clock : in STD_LOGIC;
           resett : in std_logic; 
           clk : out STD_LOGIC);
end frequencyDividerTo1Hz;

architecture Behavioral1Hz of frequencyDividerTo1Hz is

begin
   process_1: process(board_clock, resett)
        variable var : std_logic_vector(0 to 25) := (others => '0');
        begin
            if resett = '1' then
                var := (others => '0');
            elsif rising_edge(board_clock) then
                var := var + 1;
            end if;
            clk <= var(0);
    end process;

end Behavioral1Hz;
