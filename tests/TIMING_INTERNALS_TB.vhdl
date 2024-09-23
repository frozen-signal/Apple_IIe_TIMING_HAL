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
            CREF   : out std_logic
        );
    end component;

    component IOU_MOCK is
        port (
            PHI_0 : in std_logic;

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
            GR_N      : in std_logic;
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

    procedure assertNextTimingHalOutputs(signal CLK : in std_logic;

                                         signal PHI_0, PHI_1  : in std_logic;
                                         constant PHI_0_PHASE : in std_logic;

                                         signal RAS_N           : in std_logic;
                                         constant expectedRAS_N : in std_logic;

                                         signal Q3           : in std_logic;
                                         constant expectedQ3 : in std_logic;

                                         signal CAS_N           : in std_logic;
                                         constant expectedCAS_N : in std_logic) is
    begin
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert(PHI_0 = PHI_0_PHASE) report "PHI_0 is " & std_logic'image(PHI_0) & " but should be " & std_logic'image(PHI_0_PHASE) severity error;
        assert(PHI_1 = (not PHI_0_PHASE)) report "PHI_1 is " & std_logic'image(PHI_1) & " but should be " & std_logic'image(not PHI_0_PHASE) severity error;
        assert(RAS_N = expectedRAS_N) report "RAS_N is " & std_logic'image(RAS_N) & " but should be " & std_logic'image(expectedRAS_N) severity error;
        assert(Q3 = expectedQ3) report "RAS_N is " & std_logic'image(Q3) & " but should be " & std_logic'image(expectedQ3) severity error;
        assert(CAS_N = expectedCAS_N) report "CAS_N is " & std_logic'image(CAS_N) & " but should be " & std_logic'image(expectedCAS_N) severity error;
    end procedure;

    procedure assertNextVIDEOSignals(signal CLK              : in std_logic;
                                     signal PHI_1            : in std_logic;
                                     constant expectedPHI_1  : in std_logic;
                                     signal RAS_N            : in std_logic;
                                     constant expectedRAS_N  : in std_logic;
                                     signal LDPS_N           : in std_logic;
                                     constant expectedLDPS_N : in std_logic;
                                     signal VID7M            : in std_logic;
                                     constant expectedVID7M  : in std_logic) is
    begin
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert(PHI_1 = expectedPHI_1) report "PHI_1 is " & std_logic'image(PHI_1) & " but should be " & std_logic'image(expectedPHI_1) severity error;
        assert(RAS_N = expectedRAS_N) report "RAS_N is " & std_logic'image(RAS_N) & " but should be " & std_logic'image(expectedRAS_N) severity error;
        assert(LDPS_N = expectedLDPS_N) report "LDPS_N is " & std_logic'image(LDPS_N) & " but should be " & std_logic'image(expectedLDPS_N) severity error;
        assert(VID7M = expectedVID7M) report "VID7M is " & std_logic'image(VID7M) & " but should be " & std_logic'image(expectedVID7M) severity error;
    end procedure;

    procedure assertNextLDPS_N(signal CLK              : in std_logic;
                               signal PHI_1            : in std_logic;
                               constant expectedPHI_1  : in std_logic;
                               signal RAS_N            : in std_logic;
                               constant expectedRAS_N  : in std_logic;
                               signal LDPS_N           : in std_logic;
                               constant expectedLDPS_N : in std_logic) is
    begin
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert(PHI_1 = expectedPHI_1) report "PHI_1 is " & std_logic'image(PHI_1) & " but should be " & std_logic'image(expectedPHI_1) severity error;
        assert(RAS_N = expectedRAS_N) report "RAS_N is " & std_logic'image(RAS_N) & " but should be " & std_logic'image(expectedRAS_N) severity error;
        assert(LDPS_N = expectedLDPS_N) report "LDPS_N is " & std_logic'image(LDPS_N) & " but should be " & std_logic'image(expectedLDPS_N) severity error;
    end procedure;

    signal CLK_14M : std_logic := '0';
    signal CLK_7M  : std_logic;
    signal CREF    : std_logic;

    signal H0        : std_logic := '0';
    signal VID7      : std_logic := '0';
    signal SEGB      : std_logic := '0';
    signal GR_N      : std_logic := '1';
    signal CASEN_N   : std_logic := '0';
    signal S_80COL_N : std_logic := '1';

    signal AX     : std_logic;
    signal RAS_N  : std_logic := '0';
    signal CAS_N  : std_logic;
    signal Q3     : std_logic := '0';
    signal PHI_0  : std_logic := '0';
    signal PHI_1  : std_logic;
    signal VID7M  : std_logic;
    signal LDPS_N : std_logic;

    signal FINISHED : std_logic := '0';
begin
    u_clk_mock : CLK_MOCK port map(
        FINISHED => FINISHED,
        CLK_14M  => CLK_14M,
        CLK_7M   => CLK_7M,
        CREF     => CREF
    );

    u_iou_mock : IOU_MOCK port map (
        PHI_0 => PHI_0,
        H0    => H0
    );

    dut : TIMING_INTERNALS port map (
        CLK_14M   => CLK_14M,
        CLK_7M    => CLK_7M,
        CREF      => CREF,
        H0        => H0,
        VID7      => VID7,
        SEGB      => SEGB,
        GR_N      => GR_N,
        CASEN_N   => CASEN_N,
        S_80COL_N => S_80COL_N,

        AX     => AX,
        LDPS_N => LDPS_N,  -- TODO: untested
        VID7M  => VID7M,  -- TODO: untested
        PHI_1  => PHI_1,
        PHI_0  => PHI_0,
        Q3     => Q3,
        CAS_N  => CAS_N,
        RAS_N  => RAS_N
    );

    process
        variable expectedRAS_N : std_logic;
    begin
        -- "Burn" a full horizontal line.
        for i in 1 to 65 loop
            wait until rising_edge(PHI_0);
        end loop;

        -- Test PHI, RAS_N, and Q3 during the long-cycle. The long cycle has 2 extra 14M cycles.
        CASEN_N <= '0';
        assertNextTimingHalOutputs(PHI_0,   PHI_0, PHI_1, '1', RAS_N, '1', Q3, '1', CAS_N, '1');
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '1', CAS_N, '1');
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '1', CAS_N, '1');
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '1', CAS_N, '0');
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '0', CAS_N, '0');
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '0', CAS_N, '0');
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '0', CAS_N, '0');  -- The first extra 14M cycle
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '0', Q3, '0', CAS_N, '0');  -- The second extra 14M cycle
        assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, '1', RAS_N, '1', Q3, '0', CAS_N, '0');

        -- Test the remainder of the horizontal line (64x short cycles)
        for cycle in 1 to 64 loop
            -- Test CASEN_N: half cycles HIGH, and the other half LOW
            if (cycle < 32) then
                CASEN_N <= '0';
            else
                CASEN_N <= '1';
            end if;

            for PHI_0_PHASE in std_logic range '0' to '1' loop
                expectedRAS_N := PHI_0_PHASE and CASEN_N;

                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '1', Q3, '1', CAS_N, '1');
                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '0', Q3, '1', CAS_N, '1');
                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '0', Q3, '1', CAS_N, '1');
                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '0', Q3, '1', CAS_N, expectedRAS_N);
                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '0', Q3, '0', CAS_N, expectedRAS_N);
                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '0', Q3, '0', CAS_N, expectedRAS_N);
                assertNextTimingHalOutputs(CLK_14M, PHI_0, PHI_1, PHI_0_PHASE, RAS_N, '1', Q3, '0', CAS_N, expectedRAS_N);
            end loop;
        end loop;

        -- Test LDPS_N, TEXT40, long cycle ------------------------------------------------------------
        -- In TEXT40, LDPS_N pulses LOW for 1x14M cycle on PHASE 1
        assertNextVIDEOSignals(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
        -- In TEXT40, LDPS_N remains HIGH during PHASE 0
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');  -- LONG CYCLE
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');  -- LONG CYCLE
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');

        -- Retest LDPS_N, TEXT40, normal cycle
        for cycle in 1 to 64 loop
            -- In TEXT40, LDPS_N pulses LOW for 1x14M cycle on PHASE 1
            assertNextVIDEOSignals(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
            -- In TEXT40, LDPS_N remains HIGH during PHASE 0
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        end loop;

        -- Test LDPS_N, LORES, long cycle -------------------------------------------------------------
        GR_N <= '0';
        SEGB <= '1';
        -- In LORES, LDPS_N pulses LOW for 1x14M cycle on PHASE 1
        assertNextVIDEOSignals(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        -- In LORES, LDPS_N remains HIGH during PHASE 0
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');  -- LONG CYCLE
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');  -- LONG CYCLE
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');

        -- Retest LDPS_N, LORES, normal cycle
        for cycle in 1 to 64 loop
            -- In LORES, LDPS_N pulses LOW for 1x14M cycle on PHASE 1
            assertNextVIDEOSignals(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '0');
            -- In LORES, LDPS_N remains HIGH during PHASE 0
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        end loop;

        -- Test LDPS_N, "HIRES, Not Delayed Cycle", long cycle -----------------------------------------------
        GR_N <= '0';
        SEGB <= '0';
        VID7 <= '0';
        -- In "HIRES, Not Delayed Cycle", LDPS_N pulses LOW for 1x14M cycle on PHASE 1
        assertNextVIDEOSignals(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
        -- In "HIRES, Not Delayed Cycle", LDPS_N remains HIGH during PHASE 0
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');  -- LONG CYCLE
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');  -- LONG CYCLE
        assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');

        -- Retest LDPS_N, "HIRES, Not Delayed Cycle", normal cycle
        for cycle in 1 to 64 loop
            -- In "HIRES, Not Delayed Cycle", LDPS_N pulses LOW for 1x14M cycle on PHASE 1
            assertNextVIDEOSignals(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1', VID7M, '1');
            -- In "HIRES, Not Delayed Cycle", LDPS_N remains HIGH during PHASE 0
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '0');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1', VID7M, '1');
            assertNextVIDEOSignals(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1', VID7M, '0');
        end loop;

        -- Note VID7M is not tested here for HIRES
        -- Test LDPS_N, "HIRES, Delayed Cycle", long cycle -----------------------------------------------
        GR_N <= '0';
        SEGB <= '0';
        VID7 <= '1';
        -- In "HIRES, Delayed Cycle", LDPS_N pulses LOW for 1x14M cycle on PHASE 1
        assertNextLDPS_N(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0');  -- Delayed LDPS_N during the long cycle lasts 2x 14M cycle
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '0');

        -- In "HIRES, Delayed Cycle", LDPS_N remains HIGH during PHASE 0
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');  -- LONG CYCLE
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');  -- LONG CYCLE
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');

        -- Retest LDPS_N, "HIRES, Delayed Cycle", normal cycle
        for cycle in 1 to 64 loop
            -- In "HIRES, Delayed Cycle", LDPS_N pulses LOW for 1x14M cycle on PHASE 1
            assertNextLDPS_N(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '0');  -- LDPS_N is delayed 1x 14M cycle
            -- In "HIRES, Delayed Cycle", LDPS_N remains HIGH during PHASE 0
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');
        end loop;

        -- Test LDPS_N, Double RES, long cycle -----------------------------------------------
        GR_N <= '1';
        SEGB <= '0';
        VID7 <= '0';
        S_80COL_N <= '0';

        -- In Double RES, LDPS_N pulses LOW for 1x14M cycle on PHASE 1
        assertNextLDPS_N(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0');
        assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1');
        -- In Double RES, LDPS_N also pulses LOW for 1x14M cycle on PHASE 0
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '0');
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');  -- LONG CYCLE
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');  -- LONG CYCLE
        assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');

        -- Retest LDPS_N, Double RES, normal cycle
        for cycle in 1 to 64 loop
            -- In Double RES, LDPS_N pulses LOW for 1x14M cycle on PHASE 1
            assertNextLDPS_N(PHI_1,   PHI_1, '1', RAS_N, '1', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '0', LDPS_N, '0');
            assertNextLDPS_N(CLK_14M, PHI_1, '1', RAS_N, '1', LDPS_N, '1');
            -- In Double RES, LDPS_N also pulses LOW for 1x14M cycle on PHASE 0
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '1');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '0', LDPS_N, '0');
            assertNextLDPS_N(CLK_14M, PHI_1, '0', RAS_N, '1', LDPS_N, '1');
        end loop;

        FINISHED <= '1';
        assert false report "Test done." severity note;
        wait;

    end process;
end TIMING_INTERNALS_TEST;
