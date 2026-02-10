library IEEE;
use IEEE.std_logic_1164.all;

entity TIMING_INTERNALS_TB is
    -- empty
end TIMING_INTERNALS_TB;

architecture TESTBENCH of TIMING_INTERNALS_TB is
    constant CLK_14M_CYCLES_PER_PHASE : integer := 7;
    constant PHASE_RUNS_WARMUP        : integer := 4;
    constant PHASE_RUNS_TO_CHECK      : integer := 130;
    constant SAMPLE_DELAY             : time    := 1 ns;

    component CLK_MOCK is
        port (
            FINISHED : in std_logic;

            CLK_14M : out std_logic;

            CLK_7M : out std_logic;
            CREF   : out std_logic
        );
    end component;

    component IOU_MOCK is
        port (
            PHI_0 : in std_logic;

            H0            : out std_logic;
            PHI_0_COUNTER : out integer
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

    signal CLK_14M : std_logic;
    signal CLK_7M  : std_logic;
    signal CREF    : std_logic;

    signal H0            : std_logic;
    signal PHI_0_COUNTER : integer := 1;
    signal IS_LONG_CYCLE : std_logic;
    signal VID7          : std_logic := '0';
    signal SEGB          : std_logic := '0';
    signal GR_N          : std_logic := '1';
    signal CASEN_N       : std_logic := '0';
    signal S_80COL_N     : std_logic := '1';

    signal AX     : std_logic;
    signal LDPS_N : std_logic;
    signal VID7M  : std_logic;
    signal PHI_1  : std_logic;
    signal PHI_0  : std_logic;
    signal Q3     : std_logic;
    signal CAS_N  : std_logic;
    signal RAS_N  : std_logic;

    signal FINISHED : std_logic := '0';

    signal DEBUG : integer := 0;
begin
    U_CLK_MOCK : CLK_MOCK
    port map(
        FINISHED => FINISHED,
        CLK_14M  => CLK_14M,
        CLK_7M   => CLK_7M,
        CREF     => CREF
    );

    U_IOU_MOCK : IOU_MOCK
    port map(
        PHI_0         => PHI_0,
        H0            => H0,
        PHI_0_COUNTER => PHI_0_COUNTER
    );

    U_DUT : TIMING_INTERNALS
    port map(
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
        LDPS_N => LDPS_N,
        VID7M  => VID7M,
        PHI_1  => PHI_1,
        PHI_0  => PHI_0,
        Q3     => Q3,
        CAS_N  => CAS_N,
        RAS_N  => RAS_N
    );

    process
    begin
        wait until (PHI_0_COUNTER = 64);

        -- FIXME: Make sure H0 is elongated on the long cycle

        -- PHI_0 / PHI_1 tests ----------------------------------------------------
        -- PHI_0 is 14x CLK_14M cycles, 7 HIGHs and 7 LOWs
        -- The "Long Cycle" is 16x CLK_14M cycles, 9 HIGHs and 7 LOWs
        wait until rising_edge(PHI_0);
        -- The long cycle should be 9 14M CLK HIGH, and 7 14M CLK LOW
        for clk_14m_idx in 1 to 9 loop
            assert (PHI_0 = '1') report "PHI_0 should be HIGH." severity error;
            assert (PHI_1 = '0') report "PHI_1 should be LOW." severity error;
            wait until rising_edge(CLK_14M);
        end loop;

        wait for 0 ns;
        wait for 0 ns;

        for clk_14m_idx in 1 to 7 loop
            assert (PHI_0 = '0') report "PHI_0 should be LOW." severity error;
            assert (PHI_1 = '1') report "PHI_1 should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
        end loop;

        -- Make sure we have 64 normal cycles
        for cycle in 1 to 64 loop
            wait for 0 ns;
            wait for 0 ns;

            for clk_14m_idx in 1 to 7 loop
                assert (PHI_0 = '1') report "PHI_0 should be HIGH." severity error;
                assert (PHI_1 = '0') report "PHI_1 should be LOW." severity error;
                wait until rising_edge(CLK_14M);
            end loop;

            wait for 0 ns;
            wait for 0 ns;

            for clk_14m_idx in 1 to 7 loop
                assert (PHI_0 = '0') report "PHI_0 should be LOW." severity error;
                assert (PHI_1 = '1') report "PHI_1 should be HIGH." severity error;
                wait until rising_edge(CLK_14M);
            end loop;
        end loop;

        wait for 0 ns;
        wait for 0 ns;

        -- Make sure we have a long cycle after the 64 normal cycles
        for clk_14m_idx in 1 to 9 loop
            assert (PHI_0 = '1') report "PHI_0 should be HIGH." severity error;
            assert (PHI_1 = '0') report "PHI_1 should be LOW." severity error;
            wait until rising_edge(CLK_14M);
        end loop;

        -- AX tests ----------------------------------------------------
        -- AX Falls after PRAS_N falls and rises after Q3 falls
        -- AX should be affected by the long cycle
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 2 loop
            assert (AX = '1') report "AX should be HIGH." severity error;
            wait until rising_edge(CLK_14M); -- Note: PRAS_N falls
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for clk_14m_idx in 1 to 3 loop
            assert (AX = '0') report "AX should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for clk_14m_idx in 1 to 6 loop
            assert (AX = '1') report "AX should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            for clk_14m_idx in 1 to 3 loop
                assert (AX = '0') report "AX should be LOW." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;

            for clk_14m_idx in 1 to 4 loop
                assert (AX = '1') report "AX should be HIGH." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;
        end loop;

        -- Finally, we should have a long cycle AX again
        for clk_14m_idx in 1 to 3 loop
            assert (AX = '0') report "AX should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for clk_14m_idx in 1 to 6 loop
            assert (AX = '1') report "AX should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- RAS_N tests ----------------------------------------------------
        -- RAS rises on the last 14M cycle of the previous phase, and falls after the first 14M cycle of the current phase.
        -- Its HIGH period is unaffected by the long cycle, but its LOW period is.
        wait until (PHI_0_COUNTER = 0);

        assert (RAS_N = '1') report "RAS_N should be HIGH." severity error;
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- The long cycle is 9 14M cycles, so the LOW period should be 7
        for clk_14m_idx in 1 to 7 loop
            assert (RAS_N = '0') report "RAS_N should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- RAS_N should be back HIGH for the last 14M cycle
        assert (RAS_N = '1') report "RAS_N should be HIGH." severity error;
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            assert (RAS_N = '1') report "RAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;

            -- The normal cycle is 7 14M cycles, so the LOW period should be 5
            for clk_14m_idx in 1 to 5 loop
                assert (RAS_N = '0') report "RAS_N should be LOW." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;

            -- RAS_N should be back HIGH for the last 14M cycle
            assert (RAS_N = '1') report "RAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- Then, we should have a long cycle again
        assert (RAS_N = '1') report "RAS_N should be HIGH." severity error;
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- The long cycle is 9 14M cycles, so the LOW period should be 7
        for clk_14m_idx in 1 to 7 loop
            assert (RAS_N = '0') report "RAS_N should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- RAS_N should be back HIGH for the last 14M cycle
        assert (RAS_N = '1') report "RAS_N should be HIGH." severity error;
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- Q3 tests ----------------------------------------------------
        -- Q3 rises at the start of PHASE 0 and 1, stays HIGH for 4 14M clock cycles, then falls and remain LOW for 3 14M clock cycles.
        -- In the case of the long cycle, the LOW phase is elongated 2 14M clock cycles.
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 4 loop
            assert (Q3 = '1') report "Q3 should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for clk_14m_idx in 1 to 5 loop
            assert (Q3 = '0') report "Q3 should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            for clk_14m_idx in 1 to 4 loop
                assert (Q3 = '1') report "Q3 should be HIGH." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;

            for clk_14m_idx in 1 to 3 loop
                assert (Q3 = '0') report "Q3 should be LOW." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;
        end loop;

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 4 loop
            assert (Q3 = '1') report "Q3 should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for clk_14m_idx in 1 to 5 loop
            assert (Q3 = '0') report "Q3 should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- CAS_N tests ----------------------------------------------------
        -- Case when CASEN_N is LOW
        -- CAS_N rises at the start of PHASE 0 and 1, stays HIGH for 3 14M clock cycles, then falls and remain LOW for 4 14M clock cycles.
        -- In the case of the long cycle, the LOW phase is elongated 2 14M clock cycles.
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 3 loop
            assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- The long cycle is 9 14M cycles, so the LOW period should be 6
        for clk_14m_idx in 1 to 6 loop
            assert (CAS_N = '0') report "CAS_N should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            for clk_14m_idx in 1 to 3 loop
                assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;

            for clk_14m_idx in 1 to 4 loop
                assert (CAS_N = '0') report "CAS_N should be LOW." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;
        end loop;

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 3 loop
            assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- The long cycle is 9 14M cycles, so the LOW period should be 6
        for clk_14m_idx in 1 to 6 loop
            assert (CAS_N = '0') report "CAS_N should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- Case when CASEN_N is HIGH
        -- CAS_N should not fall during PHASE 0
        CASEN_N <= '1';
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 9 loop
            assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for cycle in 1 to 64 loop
            -- PHASE 1: CAS_N should behave like when CASEN_N = '0'
            for clk_14m_idx in 1 to 3 loop
                assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;

            for clk_14m_idx in 1 to 4 loop
                assert (CAS_N = '0') report "CAS_N should be LOW." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;

            -- PHASE 0: Should not fall during PHASE 0
            for clk_14m_idx in 1 to 7 loop
                assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
                wait until rising_edge(CLK_14M);
                wait for 0 ns;
                wait for 0 ns;
            end loop;
        end loop;

        -- PHASE 1: CAS_N should behave like when CASEN_N = '0'
        for clk_14m_idx in 1 to 3 loop
            assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        for clk_14m_idx in 1 to 4 loop
            assert (CAS_N = '0') report "CAS_N should be LOW." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 9 loop
            assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        CASEN_N <= '0';

        -- LDPS_N tests ----------------------------------------------------
        -- Case 1: hold LDPS_N inactive in a graphics configuration where
        -- no LDPS_N term can assert during PHASE 0
        GR_N      <= '0';
        SEGB      <= '0';
        S_80COL_N <= '1';
        VID7      <= '1';

        wait until (PHI_0_COUNTER = 1);
        wait for 0 ns;
        wait for 0 ns;

        for clk_14m_idx in 1 to CLK_14M_CYCLES_PER_PHASE loop
            assert (PHI_0 = '1') report "PHI_0 should be HIGH." severity error;
            assert (LDPS_N = '1') report "LDPS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- Case 2: HIRES delayed term
        -- Force graphics/hires mode and delayed case (VID7 = '0').
        GR_N      <= '0';
        SEGB      <= '0';
        S_80COL_N <= '1';
        VID7      <= '0';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '1') and (CREF = '0'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '0') report "LDPS_N Case 2: LDPS_N should pulse LOW (HIRES delayed case)." severity error;

        -- The pulse should be short (1x 14M tick in this registered implementation).
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1') report "LDPS_N Case 2: LDPS_N should return HIGH after the pulse" severity error;

        -- Near-miss: same preconditions except VID7 = '1', LDPS_N should remain HIGH
        VID7 <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '1') and (CREF = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1') report "LDPS_N Case 2 near-miss: LDPS_N should stay HIGH if VID7 = '1'" severity error;

        -- Case 3: HIRES not delayed term
        -- Force graphics/hires mode and non-delayed case (VID7 = '1').
        GR_N      <= '0';
        SEGB      <= '0';
        S_80COL_N <= '1';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '0') and (CREF = '0'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '0') report "LDPS_N Case 3: LDPS_N should pulse LOW (HIRES not-delayed case)." severity error;

        -- Near-miss: same conditions except CLK_7M = '1' should not assert this term.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '1') and (CREF = '0'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1') report "LDPS_N Case 3 near-miss: LDPS_N should stay HIGH for the CLK_7M = '1' near-miss." severity error;

        -- Case 4: LORES mode term
        GR_N <= '0';
        SEGB <= '1';
        VID7 <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Wait for LORES-term preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '0') report "LDPS_N Case 3 near-miss: LDPS_N should be LOW (LORES mode term)." severity error;

        -- Case 4 near-miss:
        -- Disable LORES by setting SEGB=0, but also prevent HIRES and cutoff terms from asserting
        SEGB <= '0';
        VID7 <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and
        (PHI_0 = '0') and (AX = '0') and (Q3 = '0') and
        (CREF = '0') and -- blocks the cutoff term
        (CLK_7M = '1');  -- blocks HIRES not-delayed (and VID7=1 blocks HIRES delayed)

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1') report "LDPS_N Case 4 near-miss: LDPS_N should stay HIGH for the SEGB='0' LORES case" severity error;

        -- Case 5: TEXT mode term
        GR_N      <= '1';
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '0') report "LDPS_N Case 5: LDPS_N should be LOW (TEXT mode term)." severity error;

        -- Near-miss: same conditions but PHI_0 = '1' should not assert TEXT term.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1') report "LDPS_N Case 5 near-miss: LDPS_N should stay HIGH for the PHI_0 = '1' case" severity error;

        -- Case 6: 80-col text extra pulse during PHASE 0
        GR_N      <= '1';
        S_80COL_N <= '0';
        wait for 0 ns;
        wait for 0 ns;

        -- Wait for 80-col text PHASE-0 preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '0') report "LDPS_N Case 6: LDPS_N should be LOW (80-col text PHASE 0 pulse)." severity error;

        -- Near-miss: same conditions but S_80COL_N = '1' should not assert this term.
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1') report "LDPS_N Case 6 near-miss: LDPS_N should stay HIGH for the S_80COL_N = '1' case" severity error;

        -- Case 7: Right display edge cutoff
        GR_N      <= '0';
        SEGB      <= '0';
        VID7      <= '1';
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Assert case: wait for a 14M edge where the cutoff term must be true
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '1') and (H0 = '0') and (CLK_7M = '1'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '0')
        report "LDPS_N Case 7: LDPS_N should be LOW (right display edge cutoff)." severity error;

        -- Near-miss: same but H0 = 1 disables only the cutoff term
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and(CREF = '1') and (H0 = '1') and (CLK_7M = '1'));

        wait for 0 ns;
        wait for 0 ns;
        assert (LDPS_N = '1')
        report "LDPS_N Case 7 near-miss: LDPS_N should stay HIGH for the H0 = '1' near-miss." severity error;

        -- VID7M tests ----------------------------------------------------
        -- Case 1: Graphics + SEGB = '1' clamps VID7M LOW
        GR_N      <= '0';
        SEGB      <= '1';
        VID7      <= '1';
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Give one 14M edge for registered outputs to settle after forcing inputs.
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- VID7M should stay LOW regardless of phase/timing state.
        for clk_14m_idx in 1 to (2 * CLK_14M_CYCLES_PER_PHASE) loop
            assert (VID7M = '0') report "VID7M Case 1: VID7M should be LOW when GR_N = '0' and SEGB = '1'." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- Near-miss: change only SEGB = '0'; VID7M should no longer be permanently clamped LOW.
        SEGB <= '0';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1') report "VID7M Case 1 near-miss: VID7M should no longer be clamped LOW when only SEGB changes to '0'." severity error;

        -- Case 2: Text + 80COL active clamps VID7M LOW
        GR_N      <= '1';
        S_80COL_N <= '0';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- VID7M should stay LOW regardless of phase/timing state.
        for clk_14m_idx in 1 to (2 * CLK_14M_CYCLES_PER_PHASE) loop
            assert (VID7M = '0') report "VID7M Case 2: VID7M should be LOW when GR_N = '1' and S_80COL_N = '0'." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;

        -- Near-miss: change only S_80COL_N = '1'; VID7M should no longer be permanently clamped LOW.
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- In text mode with S_80COL_N = '1', VID7M follows CLK_7M and should be HIGH when CLK_7M = '0'.
        wait until rising_edge(CLK_14M) and (CLK_7M = '0');
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1') report "VID7M Case 2: VID7M should no longer be clamped LOW when only S_80COL_N changes to '1'." severity error;

        -- Case 3: Text, 40COL => VID7M is inverted 7M
        GR_N      <= '1';
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Give one 14M edge for registered outputs to settle after forcing inputs.
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;

        -- Subcase A: when CLK_7M = '1', VID7M should be '0'.
        wait until rising_edge(CLK_14M) and (CLK_7M = '1');
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '0') report "VID7M Case 3A: VID7M should be LOW when GR_N = '1', S_80COL_N = '1', and CLK_7M = '1'." severity error;

        -- Subcase B: when CLK_7M = '0', VID7M should be '1'.
        wait until rising_edge(CLK_14M) and (CLK_7M = '0');
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1') report "VID7M Case 3B: VID7M should be HIGH when GR_N = '1', S_80COL_N = '1', and CLK_7M = '0'." severity error;

        -- Case 4: HIRES pixel-related assert (VID7 = '0') in graphics
        GR_N <= '0';
        SEGB <= '0';
        VID7 <= '0';
        wait for 0 ns;
        wait for 0 ns;

        -- Wait for HIRES pixel-term preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (CREF = '0') and (AX = '0') and (Q3 = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '0') report "VID7M Case 4: VID7M should be LOW for the HIRES pixel-related term (VID7 = '0')." severity error;

        -- Near-miss: same conditions but VID7 = '1' disables only this term.
        VID7 <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (CREF = '0') and (AX = '0') and (Q3 = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1') report "VID7M Case 4 near-miss: VID7M should be HIGH with VID7 = '1'" severity error;

        -- Case 5: Right-edge cutoff assert in graphics (independent of VID7)
        GR_N <= '0';
        SEGB <= '0';
        VID7 <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Wait for right-edge cutoff preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '1') and (H0 = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '0') report "VID7M Case 5: VID7M should be LOW for the right-edge cutoff term." severity error;

        -- Near-miss: flip CREF only; right-edge term should not assert.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '0') and (H0 = '0'));
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1') report "VID7M Case 5 near-miss: VID7M should be HIGH" severity error;

        -- Case 6: Feedback term driven by PHI_0
        -- TEXT / 40COL so VID7M = not CLK_7M and no other graphics VID7M terms apply.
        GR_N      <= '1';
        S_80COL_N <= '1';
        SEGB      <= '0';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '0'));
        wait for 0 ns;
        wait for 0 ns;

        -- Switch to GR/HIRES for the next 14M edge (enables /GR' and /SEGB).
        GR_N      <= '0';
        SEGB      <= '0';
        VID7      <= '1';
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Case 6 near-miss: VID7M=0 disables PHI_0 feedback
        assert ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '0'))
        report "VID7M Case 6 near-miss: Unexpected state at start of test"severity error;
        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1')
        report "VID7M Case 6 near-miss: VID7M should go HIGH before PHI_0 feedback can pull LOW." severity error;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '1'));
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '0')
        report "VID7M Case 6 near-miss: VID7M should be LOW" severity error;

        -- Case 6 near-miss: same isolated timing state, but VID7M = '0'
        -- TEXT / 40COL again.
        GR_N      <= '1';
        S_80COL_N <= '1';
        SEGB      <= '0';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '0'));
        wait for 0 ns;
        wait for 0 ns;

        -- Switch to GR/HIRES for the next edge.
        GR_N      <= '0';
        SEGB      <= '0';
        VID7      <= '1';
        S_80COL_N <= '1';
        wait for 0 ns;
        wait for 0 ns;

        -- Sanity: pre-edge state should still be the isolated one.
        assert ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '0')) report "VID7M Case 6 near-miss: Unexpected state" severity error;

        wait until rising_edge(CLK_14M);
        wait for 0 ns;
        wait for 0 ns;
        assert (VID7M = '1') report "VID7M Case 6 near-miss: : VID7M should be HIGH" severity error;

        -- Case 7: Q3'*/SEGB*/GR'*VID7M term
        -- TEXT / 40COL.
        GR_N      <= '1';
        S_80COL_N <= '1';
        SEGB      <= '0';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '1')) for 500 us;

        if ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '1')) then
            wait for 0 ns;
            wait for 0 ns;

            -- Switch to GR/HIRES for evaluation edge.
            GR_N      <= '0';
            SEGB      <= '0';
            VID7      <= '1';
            S_80COL_N <= '1';
            wait for 0 ns;
            wait for 0 ns;

            -- make sure state is still be what was set.
            assert ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '1')) report "VID7M Case 7: Unexpected state" severity error;

            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
            assert (VID7M = '0') report "VID7M Case 7: VID7M should be LOW" severity error;
        else
            assert false report "VID7M Case 7: Did not get required state: PHI_0=0, AX=0, Q3=1, VID7M=1 in TEXT mode" severity error;
        end if;

        -- Case 7 near-miss: same timing state, but VID7M = '0' disables the term
        -- TEXT / 40COL.
        GR_N      <= '1';
        S_80COL_N <= '1';
        SEGB      <= '0';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '0')) for 500 us;

        if ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '0')) then
            wait for 0 ns;
            wait for 0 ns;

            -- Switch to GR/HIRES for evaluation edge.
            GR_N      <= '0';
            SEGB      <= '0';
            VID7      <= '1';
            S_80COL_N <= '1';
            wait for 0 ns;
            wait for 0 ns;

            assert ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '0')) report "VID7M Case 7: Unexpected state" severity error;

            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
            assert (VID7M = '1') report "VID7M Case 7 near miss: VID7M should be HIGH" severity error;
        else
            assert false report "VID7M Case 7 near miss: Did not get required state: PHI_0=0, AX=0, Q3=1, VID7M=0 in TEXT mode." severity error;
        end if;

        -- Case 8: AX*/SEGB*/GR'*VID7M term
        -- TEXT / 40COL.
        GR_N      <= '1';
        S_80COL_N <= '1';
        SEGB      <= '0';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '1')) for 500 us;

        if ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '1')) then
            wait for 0 ns;
            wait for 0 ns;

            -- Switch to GR/HIRES for evaluation edge.
            GR_N      <= '0';
            SEGB      <= '0';
            VID7      <= '1';
            S_80COL_N <= '1';
            wait for 0 ns;
            wait for 0 ns;

            assert ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '1')) report "VID7M Case 8: Unexpected state" severity error;

            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
            assert (VID7M = '0') report "VID7M Case 8: VID7M should be LOW" severity error;
        else
            assert false report "VID7M Case 8: Did not get required state: PHI_0=0, AX=1, Q3=0, VID7M=1 in TEXT mode." severity error;
        end if;

        -- Case 8 near-miss: V7M-8 (same timing state, but VID7M = '0' disables the term)
        -- TEXT / 40COL.
        GR_N      <= '1';
        S_80COL_N <= '1';
        SEGB      <= '0';
        VID7      <= '1';
        wait for 0 ns;
        wait for 0 ns;

        wait until ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '0')) for 500 us;

        if ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '0')) then
            wait for 0 ns;
            wait for 0 ns;

            -- Switch to GR/HIRES for evaluation edge.
            GR_N      <= '0';
            SEGB      <= '0';
            VID7      <= '1';
            S_80COL_N <= '1';
            wait for 0 ns;
            wait for 0 ns;

            assert ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '0')) report "VID7M Case 8 near-miss: Unexpected state" severity error;

            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
            assert (VID7M = '1') report "VID7M Case 8 near-miss: VID7M should be HIGH" severity error;
        else
            assert false report "VID7M Case 8: Did not get required state: PHI_0=0, AX=1, Q3=0, VID7M=0 in TEXT mode" severity error;
        end if;

        FINISHED <= '1';
        report "Tests finished." severity note;
        wait;
    end process;
end TESTBENCH;
