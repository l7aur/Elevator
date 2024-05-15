library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity floor_to_output is
    Port(
        move_up1: in std_logic;
        move_down1: in std_logic;
        clock_in11: in std_logic;
        board_clock01: in std_logic;
        reset01: in std_logic;
        
        anode1: out std_logic_vector(3 downto 0);    --SSD module update bus
        SSD_out1 : out std_logic_vector(0 to 6);     --digit to be printed (negative logic)
        dp1: out std_logic;                           --decimal point (negative logic)      
        current_floor1 : out std_logic_vector(3 downto 0)  
    );
end floor_to_output;

architecture architBhv of floor_to_output is
component floor_state_rememberer is
    Port(
        move_up: in std_logic;
        move_down: in std_logic;
        clock_in1: in std_logic;
        reset0: in std_logic;
        
        current_floor : out std_logic_vector(3 downto 0)
    );
end component;
component SSD_module is
  Port ( 
    floorID : in std_logic_vector(7 downto 0);  --floor input as 2 digits
    clock: in std_logic;                        --board clock
    reset: in std_logic;
    
    anode: out std_logic_vector(3 downto 0);    --SSD module update bus
    SSD_out : out std_logic_vector(0 to 6);     --digit to be printed (negative logic)
    dp: out std_logic                           --decimal point (negative logic)
  );
end component;
signal k: std_logic_vector(7 downto 0);
signal aux: std_logic_vector(3 downto 0);
    begin
        c0: floor_state_rememberer port map(move_up => move_up1, move_down => move_down1, clock_in1 => clock_in11, reset0 => reset01, current_floor => aux);
        c1: SSD_module port map(floorID => k, clock => board_clock01, reset => reset01, anode => anode1, SSD_out => SSD_out1, dp => dp1);
        c2: current_floor1 <= aux;
        c3: with aux select k <=
            "00000000" when "0000",
            "00000001" when "0001",
            "00000010" when "0010",
            "00000011" when "0011",
            "00000100" when "0100",
            "00000101" when "0101",
            "00000110" when "0110",
            "00000111" when "0111",
            "00001000" when "1000",
            "00001001" when "1001",
            "00010000" when "1010",
            "00010001" when "1011",
            "00010010" when "1100",
            "11111111" when others;
end architecture;