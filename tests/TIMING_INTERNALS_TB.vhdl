library IEEE;
use IEEE.std_logic_1164.all;

entity TIMING_INTERNALS_TB is
    -- empty
end TIMING_INTERNALS_TB;

architecture TIMING_INTERNALS_TEST of TIMING_INTERNALS_TB is

    component CLK_MOCK is
        port (
            FINISHED : in std_logic;

            CLK_14M : inout std_logic;

            CLK_7M : out std_logic;
            CREF : out std_logic
        );
    end component;

    component TIMING_INTERNALS is
        port (
            CLK_14M : in std_logic;
            CLK_7M : in std_logic;
            CREF : in std_logic;
            H0 : in std_logic;
            VID7 : in std_logic;
            SEGB : in std_logic;
            GR : in std_logic;
            CASEN_N : in std_logic;
            S_80COL_N : in std_logic;

            LDPS_N : out std_logic;
            VID7M : out std_logic;
            PHI_1 : out std_logic;
            PHI_0 : out std_logic;
            Q3 : out std_logic;
            CAS_N : out std_logic;
            RAS_N : out std_logic
        );
    end component;

    signal CLK_14M : std_logic := '0';
    signal CLK_7M : std_logic;
    signal CREF : std_logic;

    signal H0 : std_logic := '0';
    signal VID7 : std_logic := '0';
    signal SEGB : std_logic := '0';
    signal GR : std_logic := '0';  -- This is GRor (2
    signal CASEN_N : std_logic := '0';
    signal S_80COL_N : std_logic := '1';

    signal RAS_N : std_logic := '0';
    signal CAS_N : std_logic;
    signal Q3 : std_logic := '0';
    signal PHI_0 : std_logic := '0';
    signal PHI_1 : std_logic;
    signal VID7M : std_logic;
    signal LDPS_N : std_logic;

    signal FINISHED : std_logic := '0';

    signal P1 : std_logic;
begin
    hal_mock : CLK_MOCK port map(
        FINISHED => FINISHED,
        CLK_14M  => CLK_14M,
        CLK_7M   => CLK_7M,
        CREF => CREF
    );

    dut : TIMING_INTERNALS port map(
        CLK_14M => CLK_14M,
        CLK_7M => CLK_7M,
        CREF => CREF,
        H0 => H0,
        VID7 => VID7,
        SEGB => SEGB,
        GR => GR,
        CASEN_N => GR,
        S_80COL_N => S_80COL_N,

        LDPS_N => LDPS_N,
        VID7M => VID7M,
        PHI_1 => PHI_1,
        PHI_0 => PHI_0,
        Q3 => Q3,
        CAS_N => CAS_N,
        RAS_N => RAS_N
    );
    process begin
        wait for 1 ms;

        FINISHED <= '1';
        assert false report "Test done." severity note;
        wait;

    end process;
end TIMING_INTERNALS_TEST;
