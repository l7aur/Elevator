LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY pmod_keypad IS
  GENERIC(
    clk_freq    : INTEGER := 50_000_000;  --system clock frequency in Hz
    stable_time : INTEGER := 10);         --time pressed key must remain stable in ms
  PORT(
    clk      :  IN     STD_LOGIC;                           --system clock
    reset_n  :  IN     STD_LOGIC;                           --asynchornous active-low reset
    rows     :  IN     STD_LOGIC_VECTOR(1 TO 4);            --row connections to keypad
    columns  :  BUFFER STD_LOGIC_VECTOR(1 TO 4) := "1111";  --column connections to keypad
    floor_out:  OUT    STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END pmod_keypad;

ARCHITECTURE logic OF pmod_keypad IS
  SIGNAL rows_int    : STD_LOGIC_VECTOR(1 TO 4);                      --synchronizer flip-flops for row inputs
  SIGNAL keys_int    : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --stores key presses except multiples in the same row
  SIGNAL keys_double : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --stores multiple key presses in the same row
  SIGNAL keys_stored : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --final key press values before debounce
  SIGNAL keys        : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --resultant key presses
  
  --declare debouncer component
  COMPONENT debounce IS
    GENERIC(
      clk_freq    : INTEGER;   --system clock frequency in Hz
      stable_time : INTEGER);  --time button must remain stable in ms
    PORT(
      clk     : IN  STD_LOGIC;   --input clock
      reset_n : IN  STD_LOGIC;   --asynchornous active-low reset
      button  : IN  STD_LOGIC;   --input signal to be debounced
      result  : OUT STD_LOGIC);  --debounced signal
  END COMPONENT;
  
BEGIN
  c1: with keys select floor_out <=
            "0000" when "1000000000000000",
            "0001" when "0100000000000000",
            "0010" when "0010000000000000",
            "0011" when "0001000000000000",
            "0100" when "0000100000000000",
            "0101" when "0000010000000000",
            "0110" when "0000001000000000",
            "0111" when "0000000100000000",
            "1000" when "0000000010000000",
            "1001" when "0000000001000000",
            "1010" when "0000000000100000",
            "1011" when "0000000000010000",
            "1100" when "0000000000001000",
            "1111" when others;
  --synchronizer flip-flops
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT AND clk = '1') THEN  --rising edge of system clock
      rows_int <= rows;                 --synchronize the row inputs to the system clock
    END IF;
  END PROCESS;
  
  PROCESS(clk, reset_n)
    VARIABLE count   : INTEGER RANGE 0 TO clk_freq/3_300_000 := 0;  --counter between key press readings
    VARIABLE presses : INTEGER RANGE 0 TO 16 := 0;                  --count simultaneous detected key presses
  BEGIN
    IF(reset_n = '1') THEN                  --reset
      columns <= (OTHERS => '1');             --release column outputs
      keys_int <= (OTHERS => '0');            --clear key press buffer
      keys_double <= (OTHERS => '0');         --clear key press buffer
    ELSIF(clk'EVENT AND clk = '1') THEN     --rising edge of system clock
      IF(count < clk_freq/3_300_000) THEN     --time for polling change not reached (<300ns)
        count := count + 1;                     --increment counter
      ELSE                                    --time for polling change reached (=300ns)
        count := 0;                             --reset counter

        --cycle through columns to poll for key presses
        CASE columns IS
        
          --pause polling and process results of last cycle of polls
          WHEN "1111" =>
            presses := 0;                                         --reset keypress counter
            press_count: FOR i IN 0 TO 15 LOOP                    --count how many keys were detected as pressed
              IF(keys_int(i) = '1' OR keys_double(i) = '1') THEN        
                presses := presses + 1;
              END IF;
            END LOOP press_count;
            IF(presses < 3) THEN                                  --2 or fewer keys pressed
              keys_stored <= keys_int OR keys_double;               --store results for debounce
            ELSE                                                  --more than 2 keys pressed
              keys_stored <= (OTHERS => '0');                       --discard unreliable results
            END IF;
            keys_int <= (OTHERS => '0');                          --clear key press buffer for next polling
            keys_double <= (OTHERS => '0');                       --clear key press buffer for next polling
            columns <= "0111";
            
          --check 1st column single presses per row
          WHEN "0111" =>
            keys_int(1) <= NOT rows_int(1);
            keys_int(4) <= NOT rows_int(2);
            keys_int(7) <= NOT rows_int(3);
            keys_int(0) <= NOT rows_int(4);            
            columns <= "1011";
            
          --check 2nd column single presses per row
          WHEN "1011" =>
            keys_int(2) <= NOT rows_int(1);
            keys_int(5) <= NOT rows_int(2);
            keys_int(8) <= NOT rows_int(3);
            keys_int(15) <= NOT rows_int(4);
            columns <= "1101";
          
          --check 3rd column single presses per row
          WHEN "1101" =>
            keys_int(3) <= NOT rows_int(1);
            keys_int(6) <= NOT rows_int(2);
            keys_int(9) <= NOT rows_int(3);
            keys_int(14) <= NOT rows_int(4);
            columns <= "1110";
          
          --check 4th column single presses per row
          WHEN "1110" =>
            keys_int(10) <= NOT rows_int(1);
            keys_int(11) <= NOT rows_int(2);
            keys_int(12) <= NOT rows_int(3);
            keys_int(13) <= NOT rows_int(4);
            columns <= "0011";  
          WHEN OTHERS =>
            columns <= "1111";
        END CASE;
      END IF;  
    END IF;
  END PROCESS;

  --debounce key press results
  row_debounce: FOR i IN 0 TO 15 GENERATE
    debounce_keys: debounce
      GENERIC MAP(clk_freq => clk_freq, stable_time => stable_time)
      PORT MAP(clk => clk, reset_n => reset_n, button => keys_stored(i), result => keys(i));
  END GENERATE;
  
END logic;