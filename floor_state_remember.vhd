library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity floor_state_rememberer is
    Port(
        move_up: in std_logic;
        move_down: in std_logic;
        clock_in1: in std_logic;
        reset0: in std_logic;
        
        current_floor : out std_logic_vector(3 downto 0)
    );
end floor_state_rememberer;

architecture behav_floor_state of floor_state_rememberer is
    begin
        c1: process(clock_in1, reset0)
            variable  aux : std_logic_vector(3 downto 0);
            begin
                if(reset0 = '1') then
                    aux := "0000";
                elsif rising_edge(clock_in1) then
                    if(move_up = '1') then
                        aux := aux + 1;
                    elsif(move_down = '1') then
                        aux := aux - 1;
                    end if;
                end if;
                current_floor <= aux;
        end process;
end architecture;