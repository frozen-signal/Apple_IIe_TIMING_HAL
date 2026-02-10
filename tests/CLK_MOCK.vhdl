library IEEE;
use IEEE.std_logic_1164.all;

entity CLK_MOCK is
    port (
        FINISHED : in std_logic;

        CLK_14M : out std_logic;
        CLK_7M  : out std_logic;
        CREF    : out std_logic
    );
end CLK_MOCK;

architecture MOCK of CLK_MOCK is
    constant HALF_14M_CYCLE : time := 34.920639355 ns;

    signal CLK_14M_INT : std_logic := '0';
    signal CLK_COUNTER : integer   := 0;
begin
    process begin
        CLK_14M_INT <= not CLK_14M_INT;

        if ((CLK_COUNTER mod 2) = 0) then
            CLK_7M <= '0';
        else
            CLK_7M <= '1';
        end if;

        if ((CLK_COUNTER mod 4) <= 1) then
            CREF                    <= '0';
        else
            CREF <= '1';
        end if;

        CLK_COUNTER <= (CLK_COUNTER + 1) mod 16;

        wait for HALF_14M_CYCLE;
        CLK_14M_INT <= not CLK_14M_INT;
        wait for HALF_14M_CYCLE;

        if FINISHED = '1' then
            wait;
        end if;
    end process;

    CLK_14M <= CLK_14M_INT;

end MOCK;
