library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sec10 is
    Port(
        b_clock1: in std_logic;
        startt: in std_logic;
        reset1: in std_logic;
        endc: out std_logic
    );
end sec10;

architecture arh10 of sec10 is

    begin
        process (b_clock1)
            variable aux: std_logic_vector(30 downto 0) := (others => '0');
            variable ok: std_logic := '0';
            variable init: std_logic := '1';
            begin
                if reset1 = '1' then
                    aux := (others => '0');
                elsif rising_edge(b_clock1) then
                    if startt = '1' then 
                        ok := '1';
                        init := '0';
                    end if;
                    if ok = '1' then
                        aux := aux + 1;
                    end if;
                    if (aux(30) = '1' and aux(5) = '1') then
                        aux := (others => '0');
                        ok := '0';
                        init := '1';
                    end if;
                end if;
                endc <= (aux(30) or init);
        end process;
end architecture;