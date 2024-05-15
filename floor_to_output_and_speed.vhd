library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity floor_to_output_and_speed is
    Port(
        move_up2: in std_logic;
        move_down2: in std_logic;
        b_clock_1: in std_logic;
        reset02: in std_logic;
        speed_select_in: in std_logic; --elevator input
        
        anode2: out std_logic_vector(3 downto 0);    --SSD module update bus
        SSD_out2 : out std_logic_vector(0 to 6);     --digit to be printed (negative logic)
        dp2: out std_logic;                           --decimal point (negative logic)  
        current_floor3: out std_logic_vector(3 downto 0)
        );
end floor_to_output_and_speed;

architecture Bex of floor_to_output_and_speed is
component floor_to_output is
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
end component;
component speed_selector is
    Port(
        speed: in std_logic;
        b_clock0: in std_logic;
        reset0 : in std_logic;
        
        out_speed: out std_logic
    ); 
end component;
signal intermediar_clock: std_logic;
    begin
        c1: speed_selector port map(speed => speed_select_in, b_clock0 => b_clock_1, reset0 => reset02, out_speed => intermediar_clock);
        c2: floor_to_output port map(move_up1 => move_up2, move_down1 => move_down2, clock_in11 => intermediar_clock, board_clock01 => b_clock_1, reset01 => reset02, anode1 => anode2, 
                                     SSD_out1 => SSD_out2, dp1 => dp2, current_floor1 => current_floor3);
end architecture;