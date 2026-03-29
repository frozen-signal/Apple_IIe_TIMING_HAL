library IEEE;
use IEEE.std_logic_1164.all;

entity TIMING_INTERNALS_TB is
    -- empty
end TIMING_INTERNALS_TB;

architecture TESTBENCH of TIMING_INTERNALS_TB is
    constant CLK_14M_CYCLES_PER_PHASE : integer := 7;

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

    function is_01(signal_value : std_logic) return boolean is
    begin
        return ((signal_value = '0') or (signal_value = '1'));
    end function;

    procedure wait_two_deltas is
    begin
        wait for 0 ns;
        wait for 0 ns;
    end procedure;

    function matches_or_dont_care(
        constant actual_value   : std_logic;
        constant expected_value : std_logic) return boolean is
    begin
        return ((expected_value = '-') or (actual_value = expected_value));
    end function;

    function state_matches(
        constant clk_7m_value    : std_logic;
        constant cref_value      : std_logic;
        constant h0_value        : std_logic;
        constant vid7_value      : std_logic;
        constant segb_value      : std_logic;
        constant gr_n_value      : std_logic;
        constant casen_n_value   : std_logic;
        constant s_80col_n_value : std_logic;
        constant ax_value        : std_logic;
        constant ldps_n_value    : std_logic;
        constant vid7m_value     : std_logic;
        constant phi_1_value     : std_logic;
        constant phi_0_value     : std_logic;
        constant q3_value        : std_logic;
        constant cas_n_value     : std_logic;
        constant ras_n_value     : std_logic;
        constant expected_clk_7m    : std_logic := '-';
        constant expected_cref      : std_logic := '-';
        constant expected_h0        : std_logic := '-';
        constant expected_vid7      : std_logic := '-';
        constant expected_segb      : std_logic := '-';
        constant expected_gr_n      : std_logic := '-';
        constant expected_casen_n   : std_logic := '-';
        constant expected_s_80col_n : std_logic := '-';
        constant expected_ax        : std_logic := '-';
        constant expected_ldps_n    : std_logic := '-';
        constant expected_vid7m     : std_logic := '-';
        constant expected_phi_1     : std_logic := '-';
        constant expected_phi_0     : std_logic := '-';
        constant expected_q3        : std_logic := '-';
        constant expected_cas_n     : std_logic := '-';
        constant expected_ras_n     : std_logic := '-') return boolean is
    begin
        return (matches_or_dont_care(clk_7m_value, expected_clk_7m)
            and matches_or_dont_care(cref_value, expected_cref)
            and matches_or_dont_care(h0_value, expected_h0)
            and matches_or_dont_care(vid7_value, expected_vid7)
            and matches_or_dont_care(segb_value, expected_segb)
            and matches_or_dont_care(gr_n_value, expected_gr_n)
            and matches_or_dont_care(casen_n_value, expected_casen_n)
            and matches_or_dont_care(s_80col_n_value, expected_s_80col_n)
            and matches_or_dont_care(ax_value, expected_ax)
            and matches_or_dont_care(ldps_n_value, expected_ldps_n)
            and matches_or_dont_care(vid7m_value, expected_vid7m)
            and matches_or_dont_care(phi_1_value, expected_phi_1)
            and matches_or_dont_care(phi_0_value, expected_phi_0)
            and matches_or_dont_care(q3_value, expected_q3)
            and matches_or_dont_care(cas_n_value, expected_cas_n)
            and matches_or_dont_care(ras_n_value, expected_ras_n));
    end function;

    procedure wait_clk_and_settle(constant clk_count : positive := 1) is
    begin
        for clk_idx in 1 to clk_count loop
            wait until rising_edge(CLK_14M);
            wait_two_deltas;
        end loop;
    end procedure;

    procedure expect_eq(
        signal actual_signal      : in std_logic;
        constant expected_value   : in std_logic;
        constant message_text     : in string) is
    begin
        assert (actual_signal = expected_value)
            report message_text
            severity error;
    end procedure;

    procedure seek_state_or_fail(
        constant failure_message   : in string;
        constant sample_on_clk     : in boolean := true;
        constant timeout_limit     : in time := 500 us;
        constant expected_clk_7m   : in std_logic := '-';
        constant expected_cref     : in std_logic := '-';
        constant expected_h0       : in std_logic := '-';
        constant expected_vid7     : in std_logic := '-';
        constant expected_segb     : in std_logic := '-';
        constant expected_gr_n     : in std_logic := '-';
        constant expected_casen_n  : in std_logic := '-';
        constant expected_s_80col_n : in std_logic := '-';
        constant expected_ax       : in std_logic := '-';
        constant expected_ldps_n   : in std_logic := '-';
        constant expected_vid7m    : in std_logic := '-';
        constant expected_phi_1    : in std_logic := '-';
        constant expected_phi_0    : in std_logic := '-';
        constant expected_q3       : in std_logic := '-';
        constant expected_cas_n    : in std_logic := '-';
        constant expected_ras_n    : in std_logic := '-') is
    begin
        if (sample_on_clk) then
            wait until rising_edge(CLK_14M) and state_matches(
                CLK_7M, CREF, H0, VID7, SEGB, GR_N, CASEN_N, S_80COL_N,
                AX, LDPS_N, VID7M, PHI_1, PHI_0, Q3, CAS_N, RAS_N,
                expected_clk_7m    => expected_clk_7m,
                expected_cref      => expected_cref,
                expected_h0        => expected_h0,
                expected_vid7      => expected_vid7,
                expected_segb      => expected_segb,
                expected_gr_n      => expected_gr_n,
                expected_casen_n   => expected_casen_n,
                expected_s_80col_n => expected_s_80col_n,
                expected_ax        => expected_ax,
                expected_ldps_n    => expected_ldps_n,
                expected_vid7m     => expected_vid7m,
                expected_phi_1     => expected_phi_1,
                expected_phi_0     => expected_phi_0,
                expected_q3        => expected_q3,
                expected_cas_n     => expected_cas_n,
                expected_ras_n     => expected_ras_n) for timeout_limit;
        else
            if ((expected_clk_7m = '-') and (expected_cref = '-') and (expected_h0 = '-') and
                (expected_vid7 = '-') and (expected_segb = '-') and (expected_gr_n = '-') and
                (expected_casen_n = '-') and (expected_s_80col_n = '-') and (expected_ldps_n = '-') and
                (expected_phi_1 = '-') and (expected_cas_n = '-') and (expected_ras_n = '-')) then
                wait until (matches_or_dont_care(PHI_0, expected_phi_0)
                    and matches_or_dont_care(AX, expected_ax)
                    and matches_or_dont_care(Q3, expected_q3)
                    and matches_or_dont_care(VID7M, expected_vid7m)) for timeout_limit;
            else
                wait until state_matches(
                    CLK_7M, CREF, H0, VID7, SEGB, GR_N, CASEN_N, S_80COL_N,
                    AX, LDPS_N, VID7M, PHI_1, PHI_0, Q3, CAS_N, RAS_N,
                    expected_clk_7m    => expected_clk_7m,
                    expected_cref      => expected_cref,
                    expected_h0        => expected_h0,
                    expected_vid7      => expected_vid7,
                    expected_segb      => expected_segb,
                    expected_gr_n      => expected_gr_n,
                    expected_casen_n   => expected_casen_n,
                    expected_s_80col_n => expected_s_80col_n,
                    expected_ax        => expected_ax,
                    expected_ldps_n    => expected_ldps_n,
                    expected_vid7m     => expected_vid7m,
                    expected_phi_1     => expected_phi_1,
                    expected_phi_0     => expected_phi_0,
                    expected_q3        => expected_q3,
                    expected_cas_n     => expected_cas_n,
                    expected_ras_n     => expected_ras_n) for timeout_limit;
            end if;
        end if;

        assert (state_matches(
            CLK_7M, CREF, H0, VID7, SEGB, GR_N, CASEN_N, S_80COL_N,
            AX, LDPS_N, VID7M, PHI_1, PHI_0, Q3, CAS_N, RAS_N,
            expected_clk_7m    => expected_clk_7m,
            expected_cref      => expected_cref,
            expected_h0        => expected_h0,
            expected_vid7      => expected_vid7,
            expected_segb      => expected_segb,
            expected_gr_n      => expected_gr_n,
            expected_casen_n   => expected_casen_n,
            expected_s_80col_n => expected_s_80col_n,
            expected_ax        => expected_ax,
            expected_ldps_n    => expected_ldps_n,
            expected_vid7m     => expected_vid7m,
            expected_phi_1     => expected_phi_1,
            expected_phi_0     => expected_phi_0,
            expected_q3        => expected_q3,
            expected_cas_n     => expected_cas_n,
            expected_ras_n     => expected_ras_n))
            report failure_message
            severity error;
        wait_two_deltas;
    end procedure;

    procedure set_text_mode(
        signal gr_n_signal      : out std_logic;
        signal segb_signal      : out std_logic;
        signal vid7_signal      : out std_logic;
        signal s_80col_n_signal : out std_logic;
        constant s_80col_n_value : std_logic := '1') is
    begin
        gr_n_signal      <= '1';
        segb_signal      <= '0';
        vid7_signal      <= '1';
        s_80col_n_signal <= s_80col_n_value;
        wait_two_deltas;
    end procedure;

    procedure set_graphics_mode(
        signal gr_n_signal      : out std_logic;
        signal segb_signal      : out std_logic;
        signal vid7_signal      : out std_logic;
        signal s_80col_n_signal : out std_logic;
        constant segb_value      : std_logic := '0';
        constant vid7_value      : std_logic := '1';
        constant s_80col_n_value : std_logic := '1') is
    begin
        gr_n_signal      <= '0';
        segb_signal      <= segb_value;
        vid7_signal      <= vid7_value;
        s_80col_n_signal <= s_80col_n_value;
        wait_two_deltas;
    end procedure;
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

    OUTPUTS_ARE_01_MONITOR : process
    begin
        -- OUTPUTS_ARE_01 --------------------------------------------------------
        wait_clk_and_settle(16);

        assert (is_01(AX)
            and is_01(LDPS_N)
            and is_01(VID7M)
            and is_01(RAS_N)
            and is_01(PHI_0)
            and (PHI_1 = (not PHI_0))
            and is_01(Q3)
            and is_01(CAS_N))
        report "OUTPUTS_ARE_01: DUT outputs should be '0' or '1', and PHI_1 should equal not PHI_0."
        severity error;

        loop
            wait on CLK_14M, FINISHED;
            exit when (FINISHED = '1');

            if (CLK_14M'event and (CLK_14M = '1')) then
                wait_two_deltas;
                assert (is_01(AX)
                    and is_01(LDPS_N)
                    and is_01(VID7M)
                    and is_01(RAS_N)
                    and is_01(PHI_0)
                    and (PHI_1 = (not PHI_0))
                    and is_01(Q3)
                    and is_01(CAS_N))
                report "OUTPUTS_ARE_01: DUT outputs should be '0' or '1', and PHI_1 should equal not PHI_0."
                severity error;
            end if;
        end loop;

        wait;
    end process;

    process
    begin
        -- STARTUP_SETTLE --------------------------------------------------------
        wait_clk_and_settle(16);

        -- H0_LONG_CYCLE_EXTENSION -----------------------------------------------
        wait until (PHI_0_COUNTER = 62);
        wait_two_deltas;
        expect_eq(H0, '1', "H0_LONG_CYCLE_EXTENSION: H0 should be HIGH at PHI_0_COUNTER=62.");

        wait until (PHI_0_COUNTER = 63);
        wait_two_deltas;
        expect_eq(H0, '0', "H0_LONG_CYCLE_EXTENSION: H0 should be LOW at PHI_0_COUNTER=63.");

        wait until (PHI_0_COUNTER = 64);
        wait_two_deltas;
        expect_eq(H0, '0', "H0_LONG_CYCLE_EXTENSION: H0 should stay LOW at PHI_0_COUNTER=64.");

        wait until (PHI_0_COUNTER = 0);
        wait_two_deltas;
        expect_eq(H0, '1', "H0_LONG_CYCLE_EXTENSION: H0 should return HIGH at PHI_0_COUNTER=0.");

        wait until (PHI_0_COUNTER = 64);

        -- PHI_0 / PHI_1 tests ----------------------------------------------------
        -- PHI_0 is 14x CLK_14M cycles, 7 HIGHs and 7 LOWs
        -- The "Long Cycle" is 16x CLK_14M cycles, 9 HIGHs and 7 LOWs
        wait until rising_edge(PHI_0);
        -- The long cycle should be 9 14M CLK HIGH, and 7 14M CLK LOW
        for clk_14m_idx in 1 to 9 loop
            expect_eq(PHI_0, '1', "PHI_0 should be HIGH.");
            expect_eq(PHI_1, '0', "PHI_1 should be LOW.");
            wait until rising_edge(CLK_14M);
        end loop;

        wait_two_deltas;

        for clk_14m_idx in 1 to 7 loop
            expect_eq(PHI_0, '0', "PHI_0 should be LOW.");
            expect_eq(PHI_1, '1', "PHI_1 should be HIGH.");
            wait until rising_edge(CLK_14M);
        end loop;

        -- Make sure we have 64 normal cycles
        for cycle in 1 to 64 loop
            wait_two_deltas;

            for clk_14m_idx in 1 to 7 loop
                expect_eq(PHI_0, '1', "PHI_0 should be HIGH.");
                expect_eq(PHI_1, '0', "PHI_1 should be LOW.");
                wait until rising_edge(CLK_14M);
            end loop;

            wait_two_deltas;

            for clk_14m_idx in 1 to 7 loop
                expect_eq(PHI_0, '0', "PHI_0 should be LOW.");
                expect_eq(PHI_1, '1', "PHI_1 should be HIGH.");
                wait until rising_edge(CLK_14M);
            end loop;
        end loop;

        wait_two_deltas;

        -- Make sure we have a long cycle after the 64 normal cycles
        for clk_14m_idx in 1 to 9 loop
            expect_eq(PHI_0, '1', "PHI_0 should be HIGH.");
            expect_eq(PHI_1, '0', "PHI_1 should be LOW.");
            wait until rising_edge(CLK_14M);
        end loop;

        -- AX tests ----------------------------------------------------
        -- AX Falls after PRAS_N falls and rises after Q3 falls
        -- AX should be affected by the long cycle
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 2 loop
            expect_eq(AX, '1', "AX should be HIGH.");
            wait_clk_and_settle; -- Note: PRAS_N falls
        end loop;

        for clk_14m_idx in 1 to 3 loop
            expect_eq(AX, '0', "AX should be LOW.");
            wait_clk_and_settle;
        end loop;

        for clk_14m_idx in 1 to 6 loop
            expect_eq(AX, '1', "AX should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            for clk_14m_idx in 1 to 3 loop
                expect_eq(AX, '0', "AX should be LOW.");
                wait_clk_and_settle;
            end loop;

            for clk_14m_idx in 1 to 4 loop
                expect_eq(AX, '1', "AX should be HIGH.");
                wait_clk_and_settle;
            end loop;
        end loop;

        -- Finally, we should have a long cycle AX again
        for clk_14m_idx in 1 to 3 loop
            expect_eq(AX, '0', "AX should be LOW.");
            wait_clk_and_settle;
        end loop;

        for clk_14m_idx in 1 to 6 loop
            expect_eq(AX, '1', "AX should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- RAS_N tests ----------------------------------------------------
        -- RAS rises on the last 14M cycle of the previous phase, and falls after the first 14M cycle of the current phase.
        -- Its HIGH period is unaffected by the long cycle, but its LOW period is.
        wait until (PHI_0_COUNTER = 0);

        expect_eq(RAS_N, '1', "RAS_N should be HIGH.");
        wait_clk_and_settle;

        -- The long cycle is 9 14M cycles, so the LOW period should be 7
        for clk_14m_idx in 1 to 7 loop
            expect_eq(RAS_N, '0', "RAS_N should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- RAS_N should be back HIGH for the last 14M cycle
        expect_eq(RAS_N, '1', "RAS_N should be HIGH.");
        wait_clk_and_settle;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            expect_eq(RAS_N, '1', "RAS_N should be HIGH.");
            wait_clk_and_settle;

            -- The normal cycle is 7 14M cycles, so the LOW period should be 5
            for clk_14m_idx in 1 to 5 loop
                expect_eq(RAS_N, '0', "RAS_N should be LOW.");
                wait_clk_and_settle;
            end loop;

            -- RAS_N should be back HIGH for the last 14M cycle
            expect_eq(RAS_N, '1', "RAS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- Then, we should have a long cycle again
        expect_eq(RAS_N, '1', "RAS_N should be HIGH.");
        wait_clk_and_settle;

        -- The long cycle is 9 14M cycles, so the LOW period should be 7
        for clk_14m_idx in 1 to 7 loop
            expect_eq(RAS_N, '0', "RAS_N should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- RAS_N should be back HIGH for the last 14M cycle
        expect_eq(RAS_N, '1', "RAS_N should be HIGH.");
        wait_clk_and_settle;

        -- Q3 tests ----------------------------------------------------
        -- Q3 rises at the start of PHASE 0 and 1, stays HIGH for 4 14M clock cycles, then falls and remain LOW for 3 14M clock cycles.
        -- In the case of the long cycle, the LOW phase is elongated 2 14M clock cycles.
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 4 loop
            expect_eq(Q3, '1', "Q3 should be HIGH.");
            wait_clk_and_settle;
        end loop;

        for clk_14m_idx in 1 to 5 loop
            expect_eq(Q3, '0', "Q3 should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            for clk_14m_idx in 1 to 4 loop
                expect_eq(Q3, '1', "Q3 should be HIGH.");
                wait_clk_and_settle;
            end loop;

            for clk_14m_idx in 1 to 3 loop
                expect_eq(Q3, '0', "Q3 should be LOW.");
                wait_clk_and_settle;
            end loop;
        end loop;

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 4 loop
            expect_eq(Q3, '1', "Q3 should be HIGH.");
            wait_clk_and_settle;
        end loop;

        for clk_14m_idx in 1 to 5 loop
            expect_eq(Q3, '0', "Q3 should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- CAS_N tests ----------------------------------------------------
        -- Case when CASEN_N is LOW
        -- CAS_N rises at the start of PHASE 0 and 1, stays HIGH for 3 14M clock cycles, then falls and remain LOW for 4 14M clock cycles.
        -- In the case of the long cycle, the LOW phase is elongated 2 14M clock cycles.
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 3 loop
            expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- The long cycle is 9 14M cycles, so the LOW period should be 6
        for clk_14m_idx in 1 to 6 loop
            expect_eq(CAS_N, '0', "CAS_N should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- We should have 1 cycle (the PHI_1 = '1' of the long cycle) + 64 cycles (all normal PHASE 0) + 64 cycles (all normal PHASE 1) = 129 cycles
        -- that are the same (non long AX version)
        for cycle in 1 to 129 loop
            for clk_14m_idx in 1 to 3 loop
                expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
                wait_clk_and_settle;
            end loop;

            for clk_14m_idx in 1 to 4 loop
                expect_eq(CAS_N, '0', "CAS_N should be LOW.");
                wait_clk_and_settle;
            end loop;
        end loop;

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 3 loop
            expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- The long cycle is 9 14M cycles, so the LOW period should be 6
        for clk_14m_idx in 1 to 6 loop
            expect_eq(CAS_N, '0', "CAS_N should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- Case when CASEN_N is HIGH
        -- CAS_N should not fall during PHASE 0
        CASEN_N <= '1';
        wait until (PHI_0_COUNTER = 0);

        for clk_14m_idx in 1 to 9 loop
            expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        for cycle in 1 to 64 loop
            -- PHASE 1: CAS_N should behave like when CASEN_N = '0'
            for clk_14m_idx in 1 to 3 loop
                expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
                wait_clk_and_settle;
            end loop;

            for clk_14m_idx in 1 to 4 loop
                expect_eq(CAS_N, '0', "CAS_N should be LOW.");
                wait_clk_and_settle;
            end loop;

            -- PHASE 0: Should not fall during PHASE 0
            for clk_14m_idx in 1 to 7 loop
                expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
                wait_clk_and_settle;
            end loop;
        end loop;

        -- PHASE 1: CAS_N should behave like when CASEN_N = '0'
        for clk_14m_idx in 1 to 3 loop
            expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        for clk_14m_idx in 1 to 4 loop
            expect_eq(CAS_N, '0', "CAS_N should be LOW.");
            wait_clk_and_settle;
        end loop;

        -- Then, we should have a long cycle again
        for clk_14m_idx in 1 to 9 loop
            expect_eq(CAS_N, '1', "CAS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- CASEN_N transition tests ----------------------------------------------
        CASEN_N <= '0';
        wait_two_deltas;

        seek_state_or_fail(
            failure_message => "CASEN_DISABLE_TRANSITION: pre-fall PHASE 0 state was not reached.",
            expected_phi_0  => '1',
            expected_ras_n  => '0',
            expected_ax     => '1',
            expected_q3     => '1',
            expected_cas_n  => '1');
        CASEN_N <= '1';
        wait_two_deltas;
        wait_clk_and_settle;
        expect_eq(CAS_N, '1', "CASEN_DISABLE_TRANSITION: CAS_N should stay HIGH through the next PHASE 0 CAS window.");

        seek_state_or_fail(
            failure_message => "CASEN_DISABLE_TRANSITION: PHASE 1 CAS_N low state was not reached after disabling CASEN_N.",
            expected_phi_0  => '0',
            expected_cas_n  => '0');

        seek_state_or_fail(
            failure_message => "CASEN_ENABLE_TRANSITION: pre-fall PHASE 0 state was not reached.",
            expected_phi_0  => '1',
            expected_ras_n  => '0',
            expected_ax     => '1',
            expected_q3     => '1',
            expected_cas_n  => '1');
        CASEN_N <= '0';
        wait_two_deltas;
        wait_clk_and_settle;
        expect_eq(CAS_N, '0', "CASEN_ENABLE_TRANSITION: CAS_N should fall in the next PHASE 0 CAS window.");

        CASEN_N <= '0';

        -- Targeted timing-term tests ----------------------------------------------
        -- RAS_N targeted term tests ------------------------------------------------
        -- Case 1: Q3 term
        seek_state_or_fail(
            failure_message => "RAS_N Case 1: Q3-term state was not reached.",
            expected_phi_0  => '0',
            expected_ax     => '0',
            expected_q3     => '1',
            expected_clk_7m => '0');
        expect_eq(RAS_N, '0', "RAS_N Case 1: RAS_N should be LOW for the Q3 term.");

        -- Reachable sampled-edge near-miss: Q3 is absent and the other RAS_N terms remain off.
        seek_state_or_fail(
            failure_message => "RAS_N Case 1 near-miss: Q3=0 near-miss state was not reached.",
            expected_phi_0  => '0',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_clk_7m => '0');
        expect_eq(RAS_N, '1', "RAS_N Case 1 near-miss: RAS_N should be HIGH when the Q3 term is absent and the other RAS_N terms are blocked.");

        -- Case 2: PHASE 1 hold term
        seek_state_or_fail(
            failure_message => "RAS_N Case 2: PHASE 1 hold state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '0',
            expected_q3     => '0',
            expected_clk_7m => '1');
        expect_eq(RAS_N, '0', "RAS_N Case 2: RAS_N should stay LOW for the PHASE 1 hold term.");

        seek_state_or_fail(
            failure_message => "RAS_N Case 2 near-miss: CLK_7M=0 near-miss state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '0',
            expected_q3     => '0',
            expected_clk_7m => '0');
        expect_eq(RAS_N, '1', "RAS_N Case 2 near-miss: RAS_N should return HIGH when only CLK_7M changes to '0'.");

        -- Case 3: PHASE 0 AX term
        seek_state_or_fail(
            failure_message => "RAS_N Case 3: PHASE 0 AX-term state was not reached.",
            expected_phi_0  => '1',
            expected_h0     => '0',
            expected_ax     => '0',
            expected_q3     => '0',
            expected_clk_7m => '0');
        expect_eq(RAS_N, '0', "RAS_N Case 3: RAS_N should be LOW for the PHASE 0 AX term.");

        seek_state_or_fail(
            failure_message => "RAS_N Case 3 near-miss: AX=1 near-miss state was not reached.",
            expected_phi_0  => '1',
            expected_h0     => '0',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_clk_7m => '0');
        expect_eq(RAS_N, '1', "RAS_N Case 3 near-miss: RAS_N should stay HIGH when only AX changes to '1'.");

        -- Case 4: long-cycle CLK_7M/CREF = 1/1 term
        seek_state_or_fail(
            failure_message => "RAS_N Case 4: long-cycle CLK_7M=1/CREF=1 state was not reached.",
            expected_phi_0  => '1',
            expected_h0     => '1',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_clk_7m => '1',
            expected_cref   => '1');
        expect_eq(RAS_N, '0', "RAS_N Case 4: RAS_N should stay LOW for the long-cycle CLK_7M=1/CREF=1 term.");

        seek_state_or_fail(
            failure_message => "RAS_N Case 4 near-miss: CREF=0 near-miss state was not reached.",
            expected_phi_0  => '1',
            expected_h0     => '1',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_clk_7m => '1',
            expected_cref   => '0');
        expect_eq(RAS_N, '1', "RAS_N Case 4 near-miss: RAS_N should return HIGH when only CREF changes to '0'.");

        -- Case 5: long-cycle CLK_7M/CREF = 0/0 term
        seek_state_or_fail(
            failure_message => "RAS_N Case 5: long-cycle CLK_7M=0/CREF=0 state was not reached.",
            expected_phi_0  => '1',
            expected_h0     => '1',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_clk_7m => '0',
            expected_cref   => '0');
        expect_eq(RAS_N, '0', "RAS_N Case 5: RAS_N should stay LOW for the long-cycle CLK_7M=0/CREF=0 term.");

        seek_state_or_fail(
            failure_message => "RAS_N Case 5 near-miss: CREF=1 near-miss state was not reached.",
            expected_phi_0  => '1',
            expected_h0     => '1',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_clk_7m => '0',
            expected_cref   => '1');
        expect_eq(RAS_N, '1', "RAS_N Case 5 near-miss: RAS_N should return HIGH when only CREF changes to '1'.");

        -- AX targeted term tests ---------------------------------------------------
        -- Case 1: fall term
        seek_state_or_fail(
            failure_message => "AX Case 1: pre-fall state was not reached.",
            expected_ras_n  => '0',
            expected_q3     => '1',
            expected_ax     => '1');
        expect_eq(AX, '0', "AX Case 1: AX should fall when RAS_N='0' and Q3='1'.");

        seek_state_or_fail(
            failure_message => "AX Case 1 near-miss: Q3=0 near-miss state was not reached.",
            expected_ras_n  => '0',
            expected_q3     => '0',
            expected_ax     => '1');
        expect_eq(AX, '1', "AX Case 1 near-miss: AX should stay HIGH when only Q3 changes to '0'.");

        -- PHI_0 targeted term tests -----------------------------------------------
        -- Case 1: high-hold term
        seek_state_or_fail(
            failure_message => "PHI_0 Case 1: high-hold pre-state was not reached.",
            expected_phi_0  => '1',
            expected_ras_n  => '1',
            expected_q3     => '1');
        expect_eq(PHI_0, '1', "PHI_0 Case 1: PHI_0 should stay HIGH for the high-hold term.");

        seek_state_or_fail(
            failure_message => "PHI_0 Case 1 near-miss: Q3=0 near-miss state was not reached.",
            expected_phi_0  => '1',
            expected_ras_n  => '1',
            expected_q3     => '0');
        expect_eq(PHI_0, '0', "PHI_0 Case 1 near-miss: PHI_0 should fall when only Q3 changes to '0'.");

        -- Case 2: rise term
        seek_state_or_fail(
            failure_message => "PHI_0 Case 2: rise pre-state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '1',
            expected_q3     => '0');
        expect_eq(PHI_0, '1', "PHI_0 Case 2: PHI_0 should rise when RAS_N='1' and Q3='0'.");

        seek_state_or_fail(
            failure_message => "PHI_0 Case 2 near-miss: RAS_N=0 near-miss state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '0',
            expected_q3     => '0');
        expect_eq(PHI_0, '0', "PHI_0 Case 2 near-miss: PHI_0 should stay LOW when only RAS_N changes to '0'.");

        -- Case 3: low-hold term
        seek_state_or_fail(
            failure_message => "PHI_0 Case 3: low-hold pre-state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '1',
            expected_q3     => '1');
        expect_eq(PHI_0, '0', "PHI_0 Case 3: PHI_0 should stay LOW for the low-hold term.");

        seek_state_or_fail(
            failure_message => "PHI_0 Case 3 near-miss: Q3=0 near-miss state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '1',
            expected_q3     => '0');
        expect_eq(PHI_0, '1', "PHI_0 Case 3 near-miss: PHI_0 should rise when only Q3 changes to '0'.");

        -- Q3 targeted term tests ---------------------------------------------------
        -- Case 1: PHASE 1 assert term
        seek_state_or_fail(
            failure_message => "Q3 Case 1: PHASE 1 assert pre-state was not reached.",
            expected_phi_0  => '0',
            expected_ax     => '0',
            expected_clk_7m => '0',
            expected_q3     => '1');
        expect_eq(Q3, '0', "Q3 Case 1: Q3 should fall for the PHASE 1 assert term.");

        seek_state_or_fail(
            failure_message => "Q3 Case 1 near-miss: CLK_7M=1 near-miss state was not reached.",
            expected_phi_0  => '0',
            expected_ax     => '0',
            expected_clk_7m => '1',
            expected_q3     => '1');
        expect_eq(Q3, '1', "Q3 Case 1 near-miss: Q3 should stay HIGH when only CLK_7M changes to '1'.");

        -- Case 2: low-hold term
        seek_state_or_fail(
            failure_message => "Q3 Case 2: low-hold pre-state was not reached.",
            expected_q3     => '0',
            expected_ras_n  => '0',
            expected_ax     => '1');
        expect_eq(Q3, '0', "Q3 Case 2: Q3 should stay LOW for the low-hold term.");

        seek_state_or_fail(
            failure_message => "Q3 Case 2 near-miss: RAS_N=1 near-miss state was not reached.",
            expected_q3     => '0',
            expected_ras_n  => '1',
            expected_ax     => '1');
        expect_eq(Q3, '1', "Q3 Case 2 near-miss: Q3 should rise when only RAS_N changes to '1'.");

        -- Case 3: PHASE 0 assert term
        seek_state_or_fail(
            failure_message => "Q3 Case 3: PHASE 0 assert pre-state was not reached.",
            expected_phi_0  => '1',
            expected_ax     => '0',
            expected_clk_7m => '1',
            expected_q3     => '1');
        expect_eq(Q3, '0', "Q3 Case 3: Q3 should fall for the PHASE 0 assert term.");

        seek_state_or_fail(
            failure_message => "Q3 Case 3 near-miss: CLK_7M=0 near-miss state was not reached.",
            expected_phi_0  => '1',
            expected_ax     => '0',
            expected_clk_7m => '0',
            expected_q3     => '1');
        expect_eq(Q3, '1', "Q3 Case 3 near-miss: Q3 should stay HIGH when only CLK_7M changes to '0'.");

        -- CAS_N targeted term tests -----------------------------------------------
        -- Case 1: PHASE 1 fall term
        seek_state_or_fail(
            failure_message => "CAS_N Case 1: PHASE 1 fall pre-state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '0',
            expected_ax     => '0',
            expected_cas_n  => '1');
        expect_eq(CAS_N, '0', "CAS_N Case 1: CAS_N should fall during PHASE 1.");

        seek_state_or_fail(
            failure_message => "CAS_N Case 1 near-miss: PHASE 1 near-miss state was not reached.",
            expected_phi_0  => '0',
            expected_ras_n  => '0',
            expected_ax     => '1',
            expected_cas_n  => '1');
        expect_eq(CAS_N, '1', "CAS_N Case 1 near-miss: CAS_N should stay HIGH when the PHASE 1 fall term is blocked.");

        -- Case 2: PHASE 0 gated fall term
        seek_state_or_fail(
            failure_message => "CAS_N Case 2: PHASE 0 gated-fall pre-state was not reached.",
            expected_phi_0  => '1',
            expected_ras_n  => '0',
            expected_ax     => '0',
            expected_cas_n  => '1',
            expected_casen_n => '0');
        expect_eq(CAS_N, '0', "CAS_N Case 2: CAS_N should fall during PHASE 0 when CASEN_N='0'.");

        seek_state_or_fail(
            failure_message  => "CAS_N Case 2 near-miss: CASEN_N-gated near-miss state was not reached.",
            sample_on_clk    => false,
            expected_phi_0   => '1',
            expected_ras_n   => '0',
            expected_ax      => '0',
            expected_cas_n   => '1',
            expected_casen_n => '0');
        CASEN_N <= '1';
        wait_two_deltas;
        wait_clk_and_settle;
        expect_eq(CAS_N, '1', "CAS_N Case 2 near-miss: CAS_N should stay HIGH when only CASEN_N changes to '1'.");
        CASEN_N <= '0';
        wait_two_deltas;

        -- Case 3: low-hold term
        seek_state_or_fail(
            failure_message => "CAS_N Case 3: low-hold pre-state was not reached.",
            expected_ras_n  => '0',
            expected_ax     => '1',
            expected_cas_n  => '0');
        expect_eq(CAS_N, '0', "CAS_N Case 3: CAS_N should stay LOW for the low-hold term.");

        seek_state_or_fail(
            failure_message => "CAS_N Case 3 near-miss: RAS_N=1 near-miss state was not reached.",
            expected_ras_n  => '1',
            expected_ax     => '1',
            expected_cas_n  => '0');
        expect_eq(CAS_N, '1', "CAS_N Case 3 near-miss: CAS_N should rise when only RAS_N changes to '1'.");

        -- LDPS_N tests ----------------------------------------------------
        -- Case 1: hold LDPS_N inactive in a graphics configuration where
        -- no LDPS_N term can assert during PHASE 0
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        wait until (PHI_0_COUNTER = 1);
        wait_two_deltas;

        for clk_14m_idx in 1 to CLK_14M_CYCLES_PER_PHASE loop
            expect_eq(PHI_0, '1', "PHI_0 should be HIGH.");
            expect_eq(LDPS_N, '1', "LDPS_N should be HIGH.");
            wait_clk_and_settle;
        end loop;

        -- Case 2: HIRES delayed term
        -- Force graphics/hires mode and delayed case (VID7 = '0').
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, vid7_value => '0');

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '1') and (CREF = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '0', "LDPS_N Case 2: LDPS_N should pulse LOW (HIRES delayed case).");

        -- The pulse should be short (1x 14M tick in this registered implementation).
        wait_clk_and_settle;
        expect_eq(LDPS_N, '1', "LDPS_N Case 2: LDPS_N should return HIGH after the pulse");

        -- Near-miss: same preconditions except VID7 = '1', LDPS_N should remain HIGH
        VID7 <= '1';
        wait_two_deltas;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '1') and (CREF = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '1', "LDPS_N Case 2 near-miss: LDPS_N should stay HIGH if VID7 = '1'");

        -- Case 3: HIRES not delayed term
        -- Force graphics/hires mode and non-delayed case (VID7 = '1').
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, vid7_value => '1');

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '0') and (CREF = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '0', "LDPS_N Case 3: LDPS_N should pulse LOW (HIRES not-delayed case).");

        -- Near-miss: same conditions except CLK_7M = '1' should not assert this term.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (RAS_N = '0') and (Q3 = '0') and (CLK_7M = '1') and (CREF = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '1', "LDPS_N Case 3 near-miss: LDPS_N should stay HIGH for the CLK_7M = '1' near-miss.");

        -- Case 4: LORES mode term
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, segb_value => '1');

        -- Wait for LORES-term preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '0', "LDPS_N Case 3 near-miss: LDPS_N should be LOW (LORES mode term).");

        -- Case 4 near-miss:
        -- Disable LORES by setting SEGB=0, but also prevent HIRES and cutoff terms from asserting
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, segb_value => '0');

        wait until rising_edge(CLK_14M) and
        (PHI_0 = '0') and (AX = '0') and (Q3 = '0') and
        (CREF = '0') and -- blocks the cutoff term
        (CLK_7M = '1');  -- blocks HIRES not-delayed (and VID7=1 blocks HIRES delayed)
        wait_two_deltas;
        expect_eq(LDPS_N, '1', "LDPS_N Case 4 near-miss: LDPS_N should stay HIGH for the SEGB='0' LORES case");

        -- Case 5: TEXT mode term
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '0', "LDPS_N Case 5: LDPS_N should be LOW (TEXT mode term).");

        -- Near-miss: same conditions but PHI_0 = '1' should not assert TEXT term.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '1', "LDPS_N Case 5 near-miss: LDPS_N should stay HIGH for the PHI_0 = '1' case");

        -- Case 6: 80-col text extra pulse during PHASE 0
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N, s_80col_n_value => '0');

        -- Wait for 80-col text PHASE-0 preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '0', "LDPS_N Case 6: LDPS_N should be LOW (80-col text PHASE 0 pulse).");

        -- Near-miss: same conditions but S_80COL_N = '1' should not assert this term.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        wait until rising_edge(CLK_14M) and ((PHI_0 = '1') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(LDPS_N, '1', "LDPS_N Case 6 near-miss: LDPS_N should stay HIGH for the S_80COL_N = '1' case");

        -- Case 7: Right display edge cutoff
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        -- Assert case: wait for a 14M edge where the cutoff term must be true
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '1') and (H0 = '0') and (CLK_7M = '1'));
        wait_two_deltas;
        expect_eq(LDPS_N, '0', "LDPS_N Case 7: LDPS_N should be LOW (right display edge cutoff).");

        -- Near-miss: same but H0 = 1 disables only the cutoff term
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '1') and (H0 = '1') and (CLK_7M = '1'));
        wait_two_deltas;
        expect_eq(LDPS_N, '1', "LDPS_N Case 7 near-miss: LDPS_N should stay HIGH for the H0 = '1' near-miss.");

        -- VID7M tests ----------------------------------------------------
        -- Case 1: Graphics + SEGB = '1' clamps VID7M LOW
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, segb_value => '1');

        -- Give one 14M edge for registered outputs to settle after forcing inputs.
        wait_clk_and_settle;

        -- VID7M should stay LOW regardless of phase/timing state.
        for clk_14m_idx in 1 to (2 * CLK_14M_CYCLES_PER_PHASE) loop
            expect_eq(VID7M, '0', "VID7M Case 1: VID7M should be LOW when GR_N = '0' and SEGB = '1'.");
            wait_clk_and_settle;
        end loop;

        -- Near-miss: change only SEGB = '0'; VID7M should no longer be permanently clamped LOW.
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, segb_value => '0');

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '0'));
        wait_two_deltas;
        expect_eq(VID7M, '1', "VID7M Case 1 near-miss: VID7M should no longer be clamped LOW when only SEGB changes to '0'.");

        -- Case 2: Text + 80COL active clamps VID7M LOW
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N, s_80col_n_value => '0');

        wait_clk_and_settle;

        -- VID7M should stay LOW regardless of phase/timing state.
        for clk_14m_idx in 1 to (2 * CLK_14M_CYCLES_PER_PHASE) loop
            expect_eq(VID7M, '0', "VID7M Case 2: VID7M should be LOW when GR_N = '1' and S_80COL_N = '0'.");
            wait_clk_and_settle;
        end loop;

        -- Near-miss: change only S_80COL_N = '1'; VID7M should no longer be permanently clamped LOW.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        -- In text mode with S_80COL_N = '1', VID7M follows CLK_7M and should be HIGH when CLK_7M = '0'.
        wait until rising_edge(CLK_14M) and (CLK_7M = '0');
        wait_two_deltas;
        expect_eq(VID7M, '1', "VID7M Case 2: VID7M should no longer be clamped LOW when only S_80COL_N changes to '1'.");

        -- Case 3: Text, 40COL => VID7M is inverted 7M
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        -- Give one 14M edge for registered outputs to settle after forcing inputs.
        wait_clk_and_settle;

        -- Subcase A: when CLK_7M = '1', VID7M should be '0'.
        wait until rising_edge(CLK_14M) and (CLK_7M = '1');
        wait_two_deltas;
        expect_eq(VID7M, '0', "VID7M Case 3A: VID7M should be LOW when GR_N = '1', S_80COL_N = '1', and CLK_7M = '1'.");

        -- Subcase B: when CLK_7M = '0', VID7M should be '1'.
        wait until rising_edge(CLK_14M) and (CLK_7M = '0');
        wait_two_deltas;
        expect_eq(VID7M, '1', "VID7M Case 3B: VID7M should be HIGH when GR_N = '1', S_80COL_N = '1', and CLK_7M = '0'.");

        -- Case 4: HIRES pixel-related assert (VID7 = '0') in graphics
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, vid7_value => '0');

        -- Wait for HIRES pixel-term preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (CREF = '0') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(VID7M, '0', "VID7M Case 4: VID7M should be LOW for the HIRES pixel-related term (VID7 = '0').");

        -- Near-miss: same conditions but VID7 = '1' disables only this term.
        VID7 <= '1';
        wait_two_deltas;

        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (CREF = '0') and (AX = '0') and (Q3 = '0'));
        wait_two_deltas;
        expect_eq(VID7M, '1', "VID7M Case 4 near-miss: VID7M should be HIGH with VID7 = '1'");

        -- Case 5: Right-edge cutoff assert in graphics (independent of VID7)
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N, vid7_value => '1');

        -- Wait for right-edge cutoff preconditions:
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '1') and (H0 = '0'));
        wait_two_deltas;
        expect_eq(VID7M, '0', "VID7M Case 5: VID7M should be LOW for the right-edge cutoff term.");

        -- Near-miss: flip CREF only; right-edge term should not assert.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '0') and (H0 = '0'));
        wait_two_deltas;
        expect_eq(VID7M, '1', "VID7M Case 5 near-miss: VID7M should be HIGH");

        -- Additional near-miss: keep CREF high but set H0 high to disable only the H0-gated cutoff term.
        wait until rising_edge(CLK_14M) and ((PHI_0 = '0') and (AX = '0') and (Q3 = '0') and (CREF = '1') and (H0 = '1'));
        wait_two_deltas;
        expect_eq(VID7M, '1', "VID7M Case 5 H0 near-miss: VID7M should stay HIGH when only H0 changes to '1'.");

        -- Case 6: Feedback term driven by PHI_0
        -- TEXT / 40COL so VID7M = not CLK_7M and no other graphics VID7M terms apply.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        seek_state_or_fail(
            failure_message => "VID7M Case 6 near-miss: Did not get required state: PHI_0=1, AX=0, Q3=0, VID7M=0 in TEXT mode.",
            sample_on_clk   => false,
            expected_phi_0  => '1',
            expected_ax     => '0',
            expected_q3     => '0',
            expected_vid7m  => '0');

        -- Switch to GR/HIRES for the next 14M edge (enables /GR' and /SEGB).
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        -- Case 6 near-miss: VID7M=0 disables PHI_0 feedback
        assert ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '0'))
            report "VID7M Case 6 near-miss: Unexpected state at start of test"
            severity error;
        wait_clk_and_settle;
        expect_eq(VID7M, '1', "VID7M Case 6 near-miss: VID7M should go HIGH before PHI_0 feedback can pull LOW.");

        seek_state_or_fail(
            failure_message => "VID7M Case 6 near-miss: Did not get required state: PHI_0=1, AX=0, Q3=0, VID7M=1 in graphics mode.",
            expected_phi_0  => '1',
            expected_ax     => '0',
            expected_q3     => '0',
            expected_vid7m  => '1');
        expect_eq(VID7M, '0', "VID7M Case 6 near-miss: VID7M should be LOW.");

        -- Case 6 near-miss: same isolated timing state, but VID7M = '0'
        -- TEXT / 40COL again.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        seek_state_or_fail(
            failure_message => "VID7M Case 6 near-miss: Did not get required state: PHI_0=1, AX=0, Q3=0, VID7M=0 in TEXT mode.",
            sample_on_clk   => false,
            expected_phi_0  => '1',
            expected_ax     => '0',
            expected_q3     => '0',
            expected_vid7m  => '0');

        -- Switch to GR/HIRES for the next edge.
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        -- Sanity: pre-edge state should still be the isolated one.
        assert ((PHI_0 = '1') and (AX = '0') and (Q3 = '0') and (VID7M = '0')) report "VID7M Case 6 near-miss: Unexpected state" severity error;

        wait_clk_and_settle;
        expect_eq(VID7M, '1', "VID7M Case 6 near-miss: VID7M should be HIGH.");

        -- Case 7: Q3'*/SEGB*/GR'*VID7M term
        -- TEXT / 40COL.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        seek_state_or_fail(
            failure_message => "VID7M Case 7: Did not get required state: PHI_0=0, AX=0, Q3=1, VID7M=1 in TEXT mode",
            sample_on_clk   => false,
            expected_phi_0  => '0',
            expected_ax     => '0',
            expected_q3     => '1',
            expected_vid7m  => '1');

        -- Switch to GR/HIRES for evaluation edge.
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        -- make sure state is still be what was set.
        assert ((PHI_0 = '0') and (AX = '0') and (Q3 = '1') and (VID7M = '1')) report "VID7M Case 7: Unexpected state" severity error;

        wait_clk_and_settle;
        expect_eq(VID7M, '0', "VID7M Case 7: VID7M should be LOW");

        -- Case 7 near-miss: same timing state, but VID7M = '0' disables the term
        -- TEXT / 40COL.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        seek_state_or_fail(
            failure_message => "VID7M Case 7 near-miss: Did not get required state: PHI_0=0, AX=0, Q3=1, VID7M=0 in TEXT mode.",
            sample_on_clk   => false,
            expected_phi_0  => '0',
            expected_ax     => '0',
            expected_q3     => '1',
            expected_vid7m  => '0');

        -- Switch to GR/HIRES for evaluation edge.
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        assert ((PHI_0 = '0') and (AX = '0') and (Q3 = '1')) report "VID7M Case 7 near-miss: Unexpected timing state" severity error;

        wait_clk_and_settle;
        expect_eq(VID7M, '1', "VID7M Case 7 near-miss: VID7M should be HIGH.");

        -- Case 8: AX*/SEGB*/GR'*VID7M term
        -- TEXT / 40COL.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        seek_state_or_fail(
            failure_message => "VID7M Case 8: Did not get required state: PHI_0=0, AX=1, Q3=0, VID7M=1 in TEXT mode.",
            sample_on_clk   => false,
            expected_phi_0  => '0',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_vid7m  => '1');

        -- Switch to GR/HIRES for evaluation edge.
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        assert ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '1')) report "VID7M Case 8: Unexpected state" severity error;

        wait_clk_and_settle;
        expect_eq(VID7M, '0', "VID7M Case 8: VID7M should be LOW");

        -- Case 8 near-miss: V7M-8 (same timing state, but VID7M = '0' disables the term)
        -- TEXT / 40COL.
        set_text_mode(GR_N, SEGB, VID7, S_80COL_N);

        seek_state_or_fail(
            failure_message => "VID7M Case 8: Did not get required state: PHI_0=0, AX=1, Q3=0, VID7M=0 in TEXT mode",
            sample_on_clk   => false,
            expected_phi_0  => '0',
            expected_ax     => '1',
            expected_q3     => '0',
            expected_vid7m  => '0');

        -- Switch to GR/HIRES for evaluation edge.
        set_graphics_mode(GR_N, SEGB, VID7, S_80COL_N);

        assert ((PHI_0 = '0') and (AX = '1') and (Q3 = '0') and (VID7M = '0')) report "VID7M Case 8 near-miss: Unexpected state" severity error;

        wait_clk_and_settle;
        expect_eq(VID7M, '1', "VID7M Case 8 near-miss: VID7M should be HIGH");

        FINISHED <= '1';
        report "Tests finished." severity note;
        wait;
    end process;
end TESTBENCH;
