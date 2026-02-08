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

        wait for 1 ms;

        FINISHED <= '1';
        report "Tests finished." severity note;
        wait;
    end process;
end TESTBENCH;
