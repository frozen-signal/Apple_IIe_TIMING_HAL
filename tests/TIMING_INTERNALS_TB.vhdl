library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

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

    component IOU_MOCK is
        port (
            PHI_0    : in std_logic;

            H0 : out std_logic
        );
    end component;

    component TIMING_INTERNALS is
        port (
            CLK_14M   : in std_logic;
            CLK_7M    : in std_logic;
            CREF      : in std_logic;
            H0        : in std_logic;
            VID7      : in std_logic;
            SEGB      : in std_logic;
            GR        : in std_logic;
            CASEN_N   : in std_logic;
            S_80COL_N : in std_logic;

            AX     : out std_logic;
            LDPS_N : out std_logic;
            VID7M  : out std_logic;
            PHI_1  : out std_logic;
            PHI_0  : out std_logic;
            Q3     : out std_logic;
            CAS_N  : out std_logic;
            RAS_N  : out std_logic
        );
    end component;

    signal CLK_14M : std_logic := '0';
    signal CLK_7M : std_logic;
    signal CREF : std_logic;

    signal H0 : std_logic := '0';
    signal VID7 : std_logic := '0';
    signal SEGB : std_logic := '0';
    signal GR : std_logic := '0';
    signal CASEN_N : std_logic := '0';
    signal S_80COL_N : std_logic := '1';

    signal AX : std_logic;
    signal RAS_N : std_logic := '0';
    signal CAS_N : std_logic;
    signal Q3 : std_logic := '0';
    signal PHI_0 : std_logic := '0';
    signal PHI_1 : std_logic;
    signal VID7M : std_logic;
    signal LDPS_N : std_logic;

    signal FINISHED : std_logic := '0';

    signal DEBUG : integer := 0;
begin
    u_clk_mock : CLK_MOCK port map(
        FINISHED => FINISHED,
        CLK_14M  => CLK_14M,
        CLK_7M   => CLK_7M,
        CREF => CREF
    );

    u_iou_mock : IOU_MOCK port map (
        PHI_0 => PHI_0,
        H0 => H0
    );

    dut : TIMING_INTERNALS port map (
        CLK_14M => CLK_14M,
        CLK_7M => CLK_7M,
        CREF => CREF,
        H0 => H0,
        VID7 => VID7,
        SEGB => SEGB,
        GR => GR,
        CASEN_N => GR,
        S_80COL_N => S_80COL_N,

        AX => AX,
        LDPS_N => LDPS_N,
        VID7M => VID7M,
        PHI_1 => PHI_1,
        PHI_0 => PHI_0,
        Q3 => Q3,
        CAS_N => CAS_N,
        RAS_N => RAS_N
    );

    process begin
        -- "Burn" a full horizontal line.
        for i in 1 to 65 loop
            wait until rising_edge(PHI_0);
        end loop;

        -- Test PHI, RAS_N, and Q3 during the long-cycle
        wait until rising_edge(PHI_0);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '1') report "RAS_N should be HIGH" severity error;
        assert(Q3 = '1') report "Q3 should be HIGH" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '1') report "Q3 should be HIGH" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '1') report "Q3 should be HIGH" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '1') report "Q3 should be HIGH" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '0') report "Q3 should be LOW" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '0') report "Q3 should be LOW" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '0') report "Q3 should be LOW" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
        assert(Q3 = '0') report "Q3 should be LOW" severity error;

        wait until rising_edge(CLK_14M);
        wait for 1 ns;
        assert(PHI_0 = '1') report "PHI_0 should be HIGH" severity error;
        assert(PHI_1 = '0') report "PHI_1 should be LOW" severity error;
        assert(RAS_N = '1') report "RAS_N should be HIGH" severity error;
        assert(Q3 = '0') report "Q3 should be LOW" severity error;

        -- Test the remainder of the horizontal line (64x short cycles)
        for cycle in 1 to 64 loop
            for phase in std_logic range '0' downto '1' loop
                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 is " & std_logic'image(PHI_0) & " but should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '1') report "RAS_N should be HIGH" severity error;
                assert(Q3 = '1') report "Q3 should be HIGH" severity error;

                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
                assert(Q3 = '1') report "Q3 should be HIGH" severity error;

                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
                assert(Q3 = '1') report "Q3 should be HIGH" severity error;

                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
                assert(Q3 = '1') report "Q3 should be HIGH" severity error;

                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
                assert(Q3 = '0') report "Q3 should be LOW" severity error;

                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '0') report "RAS_N should be LOW" severity error;
                assert(Q3 = '0') report "Q3 should be LOW" severity error;

                wait until rising_edge(CLK_14M);
                wait for 1 ns;
                assert(PHI_0 = phase) report "PHI_0 should be " & std_logic'image(phase) severity error;
                assert(PHI_1 = (not phase)) report "PHI_1 should be " & std_logic'image(not phase) severity error;
                assert(RAS_N = '1') report "RAS_N should be HIGH" severity error;
                assert(Q3 = '0') report "Q3 should be LOW" severity error;
            end loop;
        end loop;

        FINISHED <= '1';
        assert false report "Test done." severity note;
        wait;

    end process;
end TIMING_INTERNALS_TEST;
