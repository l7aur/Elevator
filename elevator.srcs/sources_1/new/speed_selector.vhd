library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity speed_selector is
    Port(
        speed: in std_logic;
        b_clock0: in std_logic;
        reset0 : in std_logic;
        
        out_speed: out std_logic
    ); 
end speed_selector;

architecture select_speed_archi of speed_selector is

component sec3_clock is
    Port(
        b_clock2: in std_logic;
        reset2: in std_logic;
        
        clock_out2: out std_logic
    );
end component;
component frequencyDividerTo1Hz is
    Port ( board_clock : in STD_LOGIC;
           resett : in std_logic; 
           clk : out STD_LOGIC);
end component;

signal s1, s2 : std_logic;
    begin
    c1: frequencyDividerTo1Hz port map(board_clock => b_clock0, resett => reset0, clk => s1);
    c2: sec3_clock port map(b_clock2 => b_clock0, reset2 => reset0, clock_out2 => s2);
    c3: with speed select out_speed <=
            s1 when '0',
            s2 when others;
end architecture;