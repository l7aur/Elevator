library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sec3_clock is
    Port(
        b_clock2: in std_logic;
        reset2: in std_logic;
        
        clock_out2: out std_logic
    );
end sec3_clock;

architecture arh1 of sec3_clock is

    begin
        c2: process(b_clock2)
            variable aux : std_logic_vector(28 downto 0) := (others => '0');
            begin
                if rising_edge(b_clock2) then
                    if reset2 = '1'  then 
                        aux := (others => '0');
                    else
                        aux := aux + 1;
                    end if;
                end if;
                clock_out2 <= aux(28);
        end process;
end architecture;