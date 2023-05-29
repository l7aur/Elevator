----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2023 09:48:57 PM
-- Design Name: 
-- Module Name: decision_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity decision_unit is
  Port ( 
    req_up, req_down: in std_logic;
    call_address: in std_logic_vector(3 downto 0);
    current_address: in std_logic_vector(3 downto 0);
    clock_b: in std_logic;
    reset_b: in std_logic;
    
    go_up, go_down: out std_logic;
    update_r: out std_logic;
  );
end decision_unit;

architecture Behavioral of decision_unit is

begin
                       


end Behavioral;
