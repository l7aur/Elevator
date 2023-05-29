library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity or_gate_13 is
    Port(
        data_bus : in std_logic_vector(0 to 12);
    
        q: out std_logic
    );
end entity;

architecture aha of or_gate_13 is
    begin
        q <= data_bus(0) or data_bus(1) or data_bus(2) or data_bus(3) or data_bus(4) or 
             data_bus(5) or data_bus(6) or data_bus(7) or data_bus(8) or data_bus(9) or 
             data_bus(10) or data_bus(11) or data_bus(12);
end architecture;