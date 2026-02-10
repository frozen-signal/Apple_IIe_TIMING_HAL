library IEEE;
use IEEE.std_logic_1164.all;

entity IOU_MOCK is
    port (
        PHI_0 : in std_logic;

        H0            : out std_logic;
        PHI_0_COUNTER : out integer
    );
end IOU_MOCK;

architecture MOCK of IOU_MOCK is
    constant NUMBER_OF_CYCLES   : integer := 65;
    constant INDEX_H0_STAYS_LOW : integer := NUMBER_OF_CYCLES - 1;

    signal H0_INT : std_logic := '0';
begin
    -- H0 phase alternates when PHI_0 rises for 64 of the 65 MPU cycles. Every 65th cycle,
    -- H0 stays low for one extra period.
    -- See "Understanding the Apple IIe" by Jim Sather, the last paragraph of p. 3-7
    process (PHI_0)
        variable cycle_counter : integer := 0;
    begin
        if (rising_edge(PHI_0)) then
            if (cycle_counter = INDEX_H0_STAYS_LOW) then
                H0_INT <= '0';
            else
                H0_INT <= (not H0_INT);
            end if;

            PHI_0_COUNTER <= cycle_counter;
            cycle_counter := (cycle_counter + 1) mod NUMBER_OF_CYCLES;
        end if;
    end process;

    H0 <= H0_INT;
end MOCK;
