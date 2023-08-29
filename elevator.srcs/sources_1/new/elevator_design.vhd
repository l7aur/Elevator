library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity elevator_design is
    Port(
            door_sens: in std_logic;
            weight_sens: in std_logic;
            up_request: in std_logic;
            down_request: in std_logic;
            pmod_rows: in std_logic_vector(1 to 4);
            pmod_columns: buffer std_logic_vector(1 to 4);
            clock_100: in std_logic;
            reset_100: in std_logic;
            speed_selector: in std_logic;
            
            openDoors: out std_logic;
            anode_display: out std_logic_vector(3 downto 0);
            SSDout : out std_logic_vector(0 to 6);
            decimal_point: out std_logic;
            led_up : out std_logic;
            led_down : out std_logic
        );
end elevator_design;

architecture minune of elevator_design is
COMPONENT pmod_keypad IS
  PORT(
    clk      :  IN     STD_LOGIC;                           --system clock
    reset_n  :  IN     STD_LOGIC;                           --asynchornous active-low reset
    rows     :  IN     STD_LOGIC_VECTOR(1 TO 4);            --row connections to keypad
    columns  :  BUFFER STD_LOGIC_VECTOR(1 TO 4);            --column connections to keypad
    floor_out:  OUT    STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END COMPONENT;
component floor_to_output_and_speed is
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
end component;
component RAM_module is
  Port ( 
    resume: in std_logic;
    up_button: in std_logic;
    down_button: in std_logic;
    address1 : in std_logic_vector(3 downto 0);     --1 if button converted to address1 is pressed
    address2 : in std_logic_vector(3 downto 0);     --we update the request from a floor to 0 if we stop there
    direction: in std_logic;                          --1 if we fulfilled a reaquest
    g_max: in std_logic;
    in_between_doors: in std_logic;
    clock: in std_logic; 
    reset: in std_logic;
    
    stop: out std_logic;                              --1 if the current floor is called
    yes_up, yes_down: out std_logic;
    any_request: out std_logic;                       --1 if any request is made, 0 if we go to idle
    change_dir: out std_logic
  );
end component;
component T_flip_flop is
    Port ( T : in STD_LOGIC;
           clkk : in STD_LOGIC;
           MR: in STD_LOGIC;
           Q : out STD_LOGIC);
end component;
component sec10 is
    Port(
        b_clock1: in std_logic;
        startt: in std_logic;
        reset1: in std_logic;
        
        endc: out std_logic --active low
    );
end component;

signal dir: std_logic;
signal update_dir: std_logic;
signal go_up, go_down: std_logic;
signal floor_connection_in: std_logic_vector(3 downto 0);
signal elevator_requested: std_logic;
signal stall_interm: std_logic;
signal stall: std_logic;
signal resume_1: std_logic;
signal THEFLOOR: std_logic_vector(3 downto 0);
signal refr: std_logic_vector(5 downto 0);
signal freq_div: std_logic;

    begin
    freq_div_board_clock: process(clock_100, reset_100) --frequency divider
        begin
            if reset_100 = '1' then
                refr <= (others => '0');
            elsif rising_edge(clock_100) then
                refr <= refr + 1;
            end if;
    end process;
    freq_div <= refr(5);
    
        c1: pmod_keypad port map(clk => clock_100, reset_n => reset_100, rows => pmod_rows, columns => pmod_columns, 
                                 floor_out => floor_connection_in);
                                 
        c2: floor_to_output_and_speed port map(move_up2 => go_up, move_down2 => go_down, b_clock_1 => clock_100,
                                               reset02 => reset_100, speed_select_in => speed_selector, anode2 => anode_display, 
                                               SSD_out2 => SSDout, dp2 => decimal_point, current_floor3 => THEFLOOR);
                                               
        c3: RAM_module port map(resume => resume_1, up_button => up_request, down_button => down_request, address1 => floor_connection_in, 
                                address2 => THEFLOOR, direction => dir, g_max => weight_sens, in_between_doors => door_sens, clock => clock_100, reset => reset_100,
                                stop => stall_interm, yes_up => go_up, yes_down => go_down, any_request => elevator_requested, change_dir => update_dir);
        c_3_1: stall <= (stall_interm or weight_sens or door_sens);
        c4: T_flip_flop port map(T => update_dir, MR => reset_100, clkk => freq_div, Q => dir); 
        c5: sec10 port map(b_clock1 => clock_100, startt => stall, reset1 => reset_100, endc => resume_1);
        c6: openDoors <= ((not resume_1) or ((not elevator_requested) and (not THEFLOOR(0)) and (not THEFLOOR(1)) 
                                                                      and (not THEFLOOR(2)) and (not THEFLOOR(3))));
        led_up <= not dir;
        led_down <= dir;
        
end minune;