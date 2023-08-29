library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity T_flip_flop is
    Port ( T : in STD_LOGIC;
           clkk : in STD_LOGIC;
           MR: in STD_LOGIC;
           Q : out STD_LOGIC);
end T_flip_flop;

architecture Behavioral of T_flip_flop is
signal aux: std_logic;

begin
    c0: process(clkk, MR)
        begin
            if MR = '1' then
                aux <= '0';
            elsif rising_edge(clkk) then
                if T = '1' then
                    aux <=  not aux;
                elsif T = '0' then
                    aux <= aux;
                end if;
            end if;
            Q <= aux;
    end process;

end Behavioral;
