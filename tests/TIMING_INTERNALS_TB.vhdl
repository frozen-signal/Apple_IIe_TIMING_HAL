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

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 9 loop
            assert (CAS_N = '1') report "CAS_N should be HIGH." severity error;
            wait until rising_edge(CLK_14M);
            wait for 0 ns;
            wait for 0 ns;
        end loop;
        CASEN_N <= '0';

        wait for 1 ms;
        -- To test:
        -- LDPS_N
        -- VID7M

        FINISHED <= '1';
        report "Tests finished." severity note;
        wait;
    end process;
end TESTBENCH;
