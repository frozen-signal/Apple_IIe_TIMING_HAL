library IEEE;
use IEEE.std_logic_1164.all;

entity IOU_MOCK is
    port (
        PHI_0    : in std_logic;

        H0 : out std_logic
    );
end IOU_MOCK;

architecture MOCK of IOU_MOCK is

    signal PHI_0_COUNTER : integer := 0;
    signal H0_INT : std_logic := '0';
begin
    process (PHI_0)
    begin
        if (rising_edge(PHI_0)) then
            if (PHI_0_COUNTER = 64) then
                H0_INT <= '0';
            else
                H0_INT <= (not H0_INT);
            end if;

            PHI_0_COUNTER <= (PHI_0_COUNTER + 1) mod 65;
        end if;
    end process;

    H0 <= H0_INT;
end MOCK;
