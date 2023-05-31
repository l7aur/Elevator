library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM_module is
  Port ( 
    resume : in std_logic;
    up_button: in std_logic;
    down_button: in std_logic;
    address1 : in std_logic_vector(3 downto 0);     --1 if button converted to address1 is pressed
    address2 : in std_logic_vector(3 downto 0);     --we update the request from a floor to 0 if we stop there
    direction: in std_logic;                        --1 if we fulfilled a reaquest
    g_max: in std_logic;
    in_between_doors: in std_logic;
    clock: in std_logic;
    reset: in std_logic;
    
    stop: out std_logic;                            --1 if the current floor is called
    yes_up, yes_down: out std_logic;
    any_request: out std_logic;                     --1 if any request is made, 0 if we go to idle
    change_dir: out std_logic
  );
end RAM_module;

architecture RAM_Behavioral of RAM_module is
--connected to 100MHz clock frequncy
type matrix is array (1 to 3, 0 to 12) of std_logic;
-- 1st row = up
-- 2nd row= down
-- 3rd row = din lift
signal memory_matrix: matrix := (others => (others => '0'));
signal interm1, interm2, interm3, interm_x: std_logic;
signal above, below: std_logic;
signal any_above, any_below: std_logic;
signal interm_memory_matrix1_0: std_logic_vector(0 to 12);
signal interm_memory_matrix2_0: std_logic_vector(0 to 12);
signal interm_memory_matrix3_0: std_logic_vector(0 to 12);
signal we: std_logic;
signal refr: std_logic_vector(4 downto 0);

begin
    we_rate: process(clock, reset) --frequency divider
        begin
            if reset = '1' then
                refr <= (others => '0');
            elsif rising_edge(clock) then
                refr <= refr + 1;
            end if;
    end process;
    we <= refr(4);
    
    c_any_up: with address2 select any_above <=
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 4) or
            memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or memory_matrix(1, 8) or
            memory_matrix(1, 9) or memory_matrix(1, 10) or memory_matrix(1, 11) or 
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or memory_matrix(2, 4) or
            memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or memory_matrix(2, 8) or
            memory_matrix(2, 9) or memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or memory_matrix(3, 4) or
            memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or memory_matrix(3, 8) or
            memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
            when "0000",
            
           (memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 4) or memory_matrix(1, 5) or 
            memory_matrix(1, 6) or memory_matrix(1, 7) or memory_matrix(1, 8) or memory_matrix(1, 9) or 
            memory_matrix(1, 10) or memory_matrix(1, 11) or 
            memory_matrix(2, 2) or memory_matrix(2, 3) or memory_matrix(2, 4) or memory_matrix(2, 5) or 
            memory_matrix(2, 6) or memory_matrix(2, 7) or memory_matrix(2, 8) or memory_matrix(2, 9) or 
            memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 2) or memory_matrix(3, 3) or memory_matrix(3, 4) or memory_matrix(3, 5) or 
            memory_matrix(3, 6) or memory_matrix(3, 7) or memory_matrix(3, 8) or memory_matrix(3, 9) or 
            memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
            when "0001",
            
           (memory_matrix(1, 3) or memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or 
            memory_matrix(1, 7) or memory_matrix(1, 8) or memory_matrix(1, 9) or memory_matrix(1, 10) or
            memory_matrix(1, 11) or
            memory_matrix(2, 3) or memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or 
            memory_matrix(2, 7) or memory_matrix(2, 8) or memory_matrix(2, 9) or memory_matrix(2, 10) or
            memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 3) or memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or 
            memory_matrix(3, 7) or memory_matrix(3, 8) or memory_matrix(3, 9) or memory_matrix(3, 10) or
            memory_matrix(3, 11)  or memory_matrix(3, 12))
            when "0010",
            
           (memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or
            memory_matrix(1, 8) or memory_matrix(1, 9) or memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or
            memory_matrix(2, 8) or memory_matrix(2, 9) or memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or
            memory_matrix(3, 8) or memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
            when "0011",
            
           (memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or memory_matrix(1, 8) or
            memory_matrix(1, 9) or memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or memory_matrix(2, 8) or
            memory_matrix(2, 9) or memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or memory_matrix(3, 8) or
            memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
            when "0100",
            
           (memory_matrix(1, 6) or memory_matrix(1, 7) or memory_matrix(1, 8) or memory_matrix(1, 9) or
            memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 6) or memory_matrix(2, 7) or memory_matrix(2, 8) or memory_matrix(2, 9) or
            memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 6) or memory_matrix(3, 7) or memory_matrix(3, 8) or memory_matrix(3, 9) or
            memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
            when "0101",
            
           (memory_matrix(1, 7) or memory_matrix(1, 8) or memory_matrix(1, 9) or memory_matrix(1, 10) or
            memory_matrix(1, 11) or 
            memory_matrix(2, 7) or memory_matrix(2, 8) or memory_matrix(2, 9) or memory_matrix(2, 10) or
            memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 7) or memory_matrix(3, 8) or memory_matrix(3, 9) or memory_matrix(3, 10) or
            memory_matrix(3, 11)  or memory_matrix(3, 12)) 
            when "0110",
            
           (memory_matrix(1, 8) or memory_matrix(1, 9) or memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 8) or memory_matrix(2, 9) or memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 8) or memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
           when "0111",
            
           (memory_matrix(1, 9) or memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 9) or memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12)) 
           when "1000",
            
           (memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 10) or memory_matrix(2, 11)  or memory_matrix(2, 12) or
            memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 12))
            when "1001",
            
           (memory_matrix(1, 11) or
            memory_matrix(2, 11) or memory_matrix(2, 12) or
            memory_matrix(3, 11) or memory_matrix(3, 12)) 
            when "1010",
            
            (memory_matrix(3, 12) or memory_matrix(2, 12))
            when "1011",
            
           '0' when others;
           
           
           
    c_any_down: with address2 select any_below <=
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or
            memory_matrix(1, 8) or memory_matrix(1, 9) or memory_matrix(1, 10) or memory_matrix(1, 11) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or
            memory_matrix(2, 8) or memory_matrix(2, 9) or memory_matrix(2, 10) or memory_matrix(2, 11) or 
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or
            memory_matrix(3, 8) or memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 11)  or memory_matrix(3, 0)) 
            when "1100",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or 
            memory_matrix(1, 8) or memory_matrix(1, 9) or memory_matrix(1, 10) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or 
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or 
            memory_matrix(2, 8) or memory_matrix(2, 9) or memory_matrix(2, 10) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or 
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or 
            memory_matrix(3, 8) or memory_matrix(3, 9) or memory_matrix(3, 10) or memory_matrix(3, 0)) 
            when "1011",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or
            memory_matrix(1, 8) or memory_matrix(1, 9) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or 
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or
            memory_matrix(2, 8) or memory_matrix(2, 9) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or 
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or
            memory_matrix(3, 8) or memory_matrix(3, 9)  or memory_matrix(3, 0)) 
            when "1010",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or
            memory_matrix(1, 8) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or
            memory_matrix(2, 8) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or
            memory_matrix(3, 8) or memory_matrix(3, 0)) 
            when "1001",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or memory_matrix(3, 0)) 
            when "1000",
           
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or memory_matrix(1, 6) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(2, 4) or memory_matrix(2, 5) or memory_matrix(2, 6) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 0)) 
            when "0111",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or memory_matrix(1, 5) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(2, 4) or memory_matrix(2, 5) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or
            memory_matrix(3, 4) or memory_matrix(3, 5) or memory_matrix(3, 0)) 
            when "0110",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(1, 4) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(2, 4) or 
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or
            memory_matrix(3, 4) or memory_matrix(3, 0)) 
            when "0101",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 0) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or memory_matrix(3, 0))
            when "0100",
            
           (memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 0) or
            memory_matrix(2, 1) or memory_matrix(2, 2) or
            memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 0)) 
            when "0011",
            
           (memory_matrix(1, 1) or memory_matrix(1, 0) or
            memory_matrix(2, 1) or 
            memory_matrix(3, 1) or memory_matrix(3, 0)) 
            when "0010",
           
           (memory_matrix(1, 0) or
            memory_matrix(3, 0))
            when "0001",
            
           '0' when others;


    c_0: process(clock)
        variable etaj : natural range 0 to 12;
        variable oprire : std_logic := '0';
        begin
            if (rising_edge(clock)) then --and resume = '1') then
                case address2 is
                    when "0000" => etaj := 0;
                    when "0001" => etaj := 1;
                    when "0010" => etaj := 2;
                    when "0011" => etaj := 3;
                    when "0100" => etaj := 4;
                    when "0101" => etaj := 5;
                    when "0110" => etaj := 6;
                    when "0111" => etaj := 7;
                    when "1000" => etaj := 8;
                    when "1001" => etaj := 9;
                    when "1010" => etaj := 10;
                    when "1011" => etaj := 11;
                    when "1100" => etaj := 12;
                    when others => etaj := 0;
                end case;
                if ((direction = '0' and memory_matrix(1, etaj) = '1') or 
                    (direction = '1' and memory_matrix(2, etaj) = '1') or  
                     memory_matrix(3, etaj) = '1') then
                    oprire := '1';
                else
                    oprire := '0';
                end if;
                stop <= oprire;
                if oprire = '1' then
                    interm_memory_matrix1_0(etaj) <= '0';
                    interm_memory_matrix2_0(etaj) <= '0';
                    interm_memory_matrix3_0(etaj) <= '0';
                else
                    interm_memory_matrix1_0(etaj) <= memory_matrix(1, etaj);
                    interm_memory_matrix2_0(etaj) <= memory_matrix(2, etaj);
                    interm_memory_matrix3_0(etaj) <= memory_matrix(3, etaj);
                end if;
                if (interm_x = '0') then
                    yes_up <= '0';
                    if etaj /= 0 then 
                        yes_down <= '1';
                        if direction = '1' then 
                            change_dir <= '0';
                        else
                            change_dir <= '1';
                        end if;
                    else
                        yes_down <= '0';
                        if direction = '1' then 
                            change_dir <= '1';
                        else
                            change_dir <= '0';
                        end if;
                    end if;
                else
                    if direction = '0' then
                        if (any_above = '0' and etaj /= "0000") then
                            change_dir <= '1';
                            yes_up <= '0';
                            yes_down <= '1';
                        elsif any_above = '1' then
                            change_dir <= '0';
                            yes_up <= '1';
                            yes_down <= '0';
                        end if;
                    elsif direction = '1' then
                        if any_below = '0' then
                            change_dir <= any_above;
                        else 
                            change_dir <= '0';
                        end if;
                        yes_up <= not any_below;
                        yes_down <= any_below;
                    end if;
                end if;
                if (resume = '0' or g_max = '1' or in_between_doors = '1')then
                    change_dir <= '0';
                    yes_up <= '0';
                    yes_down <= '0';
                end if;
            end if;
    end process;
    
    
    c1_1:  interm1 <= memory_matrix(1, 0) or memory_matrix(1, 1) or memory_matrix(1, 2) or memory_matrix(1, 3) or memory_matrix(1, 4) or 
                      memory_matrix(1, 5) or memory_matrix(1, 6) or memory_matrix(1, 7) or memory_matrix(1, 8) or memory_matrix(1, 9) or 
                      memory_matrix(1, 10) or memory_matrix(1, 11);-- or memory_matrix(1, 12);
    c1_2:  interm2 <= memory_matrix(2, 1) or memory_matrix(2, 2) or memory_matrix(2, 3) or memory_matrix(2, 4) or 
                      memory_matrix(2, 5) or memory_matrix(2, 6) or memory_matrix(2, 7) or memory_matrix(2, 8) or memory_matrix(2, 9) or 
                      memory_matrix(2, 10) or memory_matrix(2, 11) or memory_matrix(2, 12);-- or memory_matrix(2, 0);
    c1_3:  interm3 <= memory_matrix(3, 0) or memory_matrix(3, 1) or memory_matrix(3, 2) or memory_matrix(3, 3) or memory_matrix(3, 4) or 
                      memory_matrix(3, 5) or memory_matrix(3, 6) or memory_matrix(3, 7) or memory_matrix(3, 8) or memory_matrix(3, 9) or 
                      memory_matrix(3, 10) or memory_matrix(3, 11) or memory_matrix(3, 12);
    c_2: interm_x <= (interm1 or interm2 or interm3);
    c_3: any_request <= interm_x;
    c_4: process(clock)
        begin                    
            if rising_edge(clock) then
                if we = '1' then
                        case address1 is
                           when "0000" => memory_matrix(1, 0) <= up_button;
                                          memory_matrix(2, 0) <= down_button;
                                          memory_matrix(3, 0) <= ((not up_button) and (not down_button)) or up_button;
				           when "0001" => memory_matrix(1, 1) <= up_button;
                                          memory_matrix(2, 1) <= down_button;
                                          memory_matrix(3, 1) <= (not up_button) and (not down_button);
				    	   when "0010" => memory_matrix(1, 2) <= up_button;
                                          memory_matrix(2, 2) <= down_button;
                                          memory_matrix(3, 2) <= (not up_button) and (not down_button);
    					   when "0011" => memory_matrix(1, 3) <= up_button;
                                          memory_matrix(2, 3) <= down_button;
                                          memory_matrix(3, 3) <= (not up_button) and (not down_button);
	   		    		   when "0100" => memory_matrix(1, 4) <= up_button;
                                          memory_matrix(2, 4) <= down_button;
                                          memory_matrix(3, 4) <= (not up_button) and (not down_button);
		  		    	   when "0101" => memory_matrix(1, 5) <= up_button;
                                          memory_matrix(2, 5) <= down_button;
                                          memory_matrix(3, 5) <= (not up_button) and (not down_button); 
					       when "0110" => memory_matrix(1, 6) <= up_button;
                                          memory_matrix(2, 6) <= down_button;
                                          memory_matrix(3, 6) <= (not up_button) and (not down_button);
					       when "0111" => memory_matrix(1, 7) <= up_button;
                                          memory_matrix(2, 7) <= down_button;
                                          memory_matrix(3, 7) <= (not up_button) and (not down_button);
    				       when "1000" => memory_matrix(1, 8) <= up_button;
                                          memory_matrix(2, 8) <= down_button;
                                          memory_matrix(3, 8) <= (not up_button) and (not down_button);
	   				       when "1001" => memory_matrix(1, 9) <= up_button;
                                          memory_matrix(2, 9) <= down_button;
                                          memory_matrix(3, 9) <= (not up_button) and (not down_button);
		  		  	       when "1010" => memory_matrix(1, 10) <= up_button;
                                          memory_matrix(2, 10) <= down_button;
                                          memory_matrix(3, 10) <= (not up_button) and (not down_button);
			 		       when "1011" => memory_matrix(1, 11) <= up_button;
                                          memory_matrix(2, 11) <= down_button;
                                          memory_matrix(3, 11) <= (not up_button) and (not down_button);
				    	   when "1100" => memory_matrix(1, 12) <= up_button;
                                          memory_matrix(2, 12) <= down_button;
                                          memory_matrix(3, 12) <= ((not up_button) and (not down_button)) or down_button;
					       when others =>  null;
                        end case;
                        case address2 is 
                           when "0000" => memory_matrix(1, 0) <= interm_memory_matrix1_0(0);
                                          memory_matrix(2, 0) <= interm_memory_matrix2_0(0);
                                          memory_matrix(3, 0) <= interm_memory_matrix3_0(0);
				           when "0001" => memory_matrix(1, 1) <= interm_memory_matrix1_0(1);
                                          memory_matrix(2, 1) <= interm_memory_matrix2_0(1);
                                          memory_matrix(3, 1) <= interm_memory_matrix3_0(1);
				    	   when "0010" => memory_matrix(1, 2) <= interm_memory_matrix1_0(2);
                                          memory_matrix(2, 2) <= interm_memory_matrix2_0(2);
                                          memory_matrix(3, 2) <= interm_memory_matrix3_0(2);
    					   when "0011" => memory_matrix(1, 3) <= interm_memory_matrix1_0(3);
                                          memory_matrix(2, 3) <= interm_memory_matrix2_0(3);
                                          memory_matrix(3, 3) <= interm_memory_matrix3_0(3);
	   		    		   when "0100" => memory_matrix(1, 4) <= interm_memory_matrix1_0(4);
                                          memory_matrix(2, 4) <= interm_memory_matrix2_0(4);
                                          memory_matrix(3, 4) <= interm_memory_matrix3_0(4);
		  		    	   when "0101" => memory_matrix(1, 5) <= interm_memory_matrix1_0(5);
                                          memory_matrix(2, 5) <= interm_memory_matrix2_0(5);
                                          memory_matrix(3, 5) <= interm_memory_matrix3_0(5);
					       when "0110" => memory_matrix(1, 6) <= interm_memory_matrix1_0(6);
                                          memory_matrix(2, 6) <= interm_memory_matrix2_0(6);
                                          memory_matrix(3, 6) <= interm_memory_matrix3_0(6);
					       when "0111" => memory_matrix(1, 7) <= interm_memory_matrix1_0(7);
                                          memory_matrix(2, 7) <= interm_memory_matrix2_0(7);
                                          memory_matrix(3, 7) <= interm_memory_matrix3_0(7);
    				       when "1000" => memory_matrix(1, 8) <= interm_memory_matrix1_0(8);
                                          memory_matrix(2, 8) <= interm_memory_matrix2_0(8);
                                          memory_matrix(3, 8) <= interm_memory_matrix3_0(8);
	   				       when "1001" => memory_matrix(1, 9) <= interm_memory_matrix1_0(9);
                                          memory_matrix(2, 9) <= interm_memory_matrix2_0(9);
                                          memory_matrix(3, 9) <= interm_memory_matrix3_0(9);
		  		  	       when "1010" => memory_matrix(1, 10) <= interm_memory_matrix1_0(10);
                                          memory_matrix(2, 10) <= interm_memory_matrix2_0(10);
                                          memory_matrix(3, 10) <= interm_memory_matrix3_0(10);
			 		       when "1011" => memory_matrix(1, 11) <= interm_memory_matrix1_0(11);
                                          memory_matrix(2, 11) <= interm_memory_matrix2_0(11);
                                          memory_matrix(3, 11) <= interm_memory_matrix3_0(11);
				    	   when "1100" => memory_matrix(1, 12) <= interm_memory_matrix1_0(12);
                                          memory_matrix(2, 12) <= interm_memory_matrix2_0(12);
                                          memory_matrix(3, 12) <= interm_memory_matrix3_0(12);
					       when others =>  null;
                        end case;
                    end if;
            end if; 
    end process;
    
end RAM_Behavioral;
