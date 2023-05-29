library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD_module is
  Port ( 
    floorID : in std_logic_vector(7 downto 0);  --floor input as 2 digits
    clock: in std_logic;                        --board clock
    reset: in std_logic;
    
    anode: out std_logic_vector(3 downto 0);    --SSD module update bus
    SSD_out : out std_logic_vector(0 to 6);     --digit to be printed (negative logic)
    dp: out std_logic                           --decimal point (negative logic)
  );
end SSD_module;

architecture SSD_Behavioral of SSD_module is

signal refresh_clock: std_logic_vector(18 downto 0);    --frequency divider for updating the ssd anode
signal anodes_activate: std_logic_vector(1 downto 0);   --what anodes to activate
signal output_digit: std_logic_vector(3 downto 0);      --what digit to output in binary

begin
    dp <= '1'; --decimal point is always off
    anodes_activate <= refresh_clock(18 downto 17); --select what ssd to update based on the frequency divider
    
    refresh_rate: process(clock, reset) --frequency divider
        begin
            if reset = '1' then
                refresh_clock <= (others => '0');
            elsif rising_edge(clock) then
                refresh_clock <= refresh_clock + 1;
            end if;
    end process;
    
    select_anode: process(anodes_activate) --generates the anode bus and what digit to display
        begin
            case anodes_activate is
                when "00" => --fourth display
                    anode <= "1110";
                    output_digit <= floorId(3 downto 0); --display the second digit
                when "01" => --third display
                    anode <= "1101";
                    if floorID(7 downto 4) = "0000" then     --if floor < 10
                        output_digit <= "1111";              --don't use third display
                    else                                     --otherwise
                        output_digit <= floorID(7 downto 4); --display the first diigt
                    end if;
                when "10" => --second display (not used)
                    anode <= "1011";
                    output_digit <= "1111"; --clear display
                when others => --first display (not used)
                    anode <= "0111";
                    output_digit <= "1111"; --clear display
            end case;
    end process;
    
    select_floor: process(output_digit) --what we send to the SSD module
        begin
            case output_digit is
                when "0000" => SSD_out <= "0000001"; --0
                when "0001" => SSD_out <= "1001111"; --1
                when "0010" => SSD_out <= "0010010"; --2
                when "0011" => SSD_out <= "0000110"; --3
                when "0100" => SSD_out <= "1001100"; --4
                when "0101" => SSD_out <= "0100100"; --5
                when "0110" => SSD_out <= "0100000"; --6
                when "0111" => SSD_out <= "0001111"; --7
                when "1000" => SSD_out <= "0000000"; --8
                when "1001" => SSD_out <= "0000100"; --9
                when others => SSD_out <= "1111111"; --deactivate display
            end case;
    end process;
    
end SSD_Behavioral;
