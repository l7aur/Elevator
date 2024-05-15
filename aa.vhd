library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sec5_clock is
    Port(
        b_clock1: in std_logic;
        reset1: in std_logic;
        
        clock_out1: out std_logic
    );
end sec5_clock;

architecture arh1 of sec5_clock is

component frequencyDividerTo1Hz is
    Port ( board_clock : in STD_LOGIC;
           resett : in std_logic; 
           clk : out STD_LOGIC);
end component;
signal clock_1Hz: std_logic;

    begin
        c1: frequencyDividerTo1Hz port map(board_clock => b_clock1, resett => reset1, clk => clock_1Hz);
        c2: process(clock_1Hz)
            variable aux : std_logic_vector(2 downto 0) := "000";
            begin
                if rising_edge(clock_1Hz) then
                    if reset1 = '1'  then 
                        aux := "000";
                    elsif aux = "101" then
                        aux := "000";
                    else
                        aux := aux + 1;
                    end if;
                end if;
                clock_out1 <= aux(2) and aux(0);
        end process;
end architecture;