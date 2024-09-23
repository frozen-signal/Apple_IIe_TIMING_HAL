library IEEE;
use IEEE.std_logic_1164.all;

-- These equations are a mix between those in '3410170A (ABEL).txt' (see references directory) and the ones in "Understanding the Apple IIe" by Jim Sather, p3-22.
entity TIMING_INTERNALS is
    port (
        CLK_14M   : in std_logic;
        CLK_7M    : in std_logic;
        CREF      : in std_logic;  -- 3.5M CLK
        H0        : in std_logic;
        VID7      : in std_logic;
        SEGB      : in std_logic;
        GR_N      : in std_logic;  -- This is GR+2 in "Understanding the Apple IIe" by Jim Sather, and called LGR_TXT_N in the IOU emulator schematics.
        CASEN_N   : in std_logic;
        S_80COL_N : in std_logic;

        AX     : out std_logic;  -- This pin is left floating on the Apple IIe motherboard.
        LDPS_N : out std_logic;
        VID7M  : out std_logic;
        PHI_1  : out std_logic;
        PHI_0  : out std_logic;
        Q3     : out std_logic;
        CAS_N  : out std_logic;
        RAS_N  : out std_logic
    );
end TIMING_INTERNALS;

-- The PAL/GAL chips have an inverter just before the output pad. This means the equations compute the inverse-signal. This is why the '3410170A (ABEL).txt' equations have the form:
-- /MY_SIGNAL := THIS*THAT
-- (i.e. /MY_SIGNAL is inverted by the IC and the output is MY_SIGNAL)
--
-- The nomenclature of '3410170A (ABEL).txt' can't be used exactly in VHDL. So the signal names are renamed thus:
-- "/"" becomes "N_" (/MY_SIGNAL becomes N_MY_SIGNAL)
-- "'" becomes "_N" (CAS' becomes CAS_N)
architecture RTL of TIMING_INTERNALS is
    signal N_PHI_0  : std_logic := '0';
    signal N_CAS_N  : std_logic := '0';
    signal N_RAS_N  : std_logic := '0';
    signal N_Q3     : std_logic := '0';
    signal N_LDPS_N : std_logic := '0';
    signal N_VID7M  : std_logic := '0';
    signal N_AX     : std_logic := '0';

    signal AX_INT    : std_logic;
    signal N_80COL_N : std_logic;
    signal N_CASEN_N : std_logic;
    signal N_CLK_7M  : std_logic;
    signal N_CREF    : std_logic;
    signal N_GR_N    : std_logic;
    signal N_H0      : std_logic;
    signal N_SEGB    : std_logic;
    signal N_VID7    : std_logic;
    signal PHI_0_INT : std_logic;
    signal Q3_INT    : std_logic;
    signal RAS_N_INT : std_logic;
    signal VID7M_INT : std_logic;
begin
    -- Bunch of inverted signals to make the equations more readable.
    AX_INT    <= not N_AX;
    N_80COL_N <= not S_80COL_N;
    N_CASEN_N <= not CASEN_N;
    N_CLK_7M  <= not CLK_7M;
    N_CREF    <= not CREF;
    N_GR_N    <= not GR_N;
    N_H0      <= not H0;
    N_SEGB    <= not SEGB;
    N_VID7    <= not VID7;
    PHI_0_INT <= not N_PHI_0;
    Q3_INT    <= not N_Q3;
    RAS_N_INT <= not N_RAS_N;
    VID7M_INT <= not N_VID7M;

    process (CLK_14M, AX_INT, CLK_7M, CREF, GR_N, H0, N_80COL_N, N_AX, N_CASEN_N, N_CAS_N, N_CLK_7M, N_CREF, N_GR_N, N_H0, N_PHI_0, N_Q3, N_RAS_N, N_SEGB, N_VID7, PHI_0_INT, Q3_INT, RAS_N_INT, SEGB, VID7, VID7M_INT)
    begin
        if (rising_edge(CLK_14M)) then
            N_LDPS_N <= (CREF and N_H0 and N_PHI_0 and N_Q3 and N_AX)
                or (GR_N and N_80COL_N and N_Q3 and N_AX)
                or (GR_N and N_PHI_0 and N_Q3 and N_AX)
                or (SEGB and N_PHI_0 and N_Q3 and N_AX)
                or (N_CLK_7M and VID7 and N_SEGB and N_GR_N and N_PHI_0 and N_Q3 and N_RAS_N)
                or (CLK_7M and N_VID7 and N_SEGB and N_GR_N and N_PHI_0 and N_Q3 and N_RAS_N);

            N_VID7M <= (GR_N and N_80COL_N)
                or (SEGB and N_GR_N)
                or (CREF and N_H0 and N_GR_N and N_PHI_0 and N_Q3 and N_AX)
                or (N_VID7 and N_GR_N and N_PHI_0 and N_Q3 and N_AX)
                or (N_GR_N and VID7M_INT and AX_INT)
                or (N_GR_N and VID7M_INT and Q3_INT)
                or (N_GR_N and VID7M_INT and PHI_0_INT)
                or (CLK_7M and GR_N);

            N_PHI_0 <= (N_PHI_0 and N_RAS_N)
                or (N_PHI_0 and Q3_INT)
                or (PHI_0_INT and N_Q3 and RAS_N_INT);

            N_Q3 <= (CLK_7M and PHI_0_INT and N_AX)
                or (N_Q3 and N_RAS_N)
                or (N_CLK_7M and N_PHI_0 and N_AX);

            N_CAS_N <= (N_CAS_N and N_RAS_N)
                or (N_CASEN_N and N_AX and N_RAS_N)
                or (N_PHI_0 and N_AX and N_RAS_N);

            N_AX <= (Q3_INT and N_RAS_N);

            N_RAS_N <= (N_CLK_7M and N_CREF and H0 and PHI_0_INT)
                or (CLK_7M and CREF and H0 and PHI_0_INT and AX_INT)
                or (N_CLK_7M and PHI_0_INT and N_AX)
                or (CLK_7M and N_PHI_0 and N_RAS_N)
                or Q3_INT;
        end if;
    end process;

    -- Invert outputs
    AX     <= AX_INT;
	LDPS_N <= not N_LDPS_N;
    VID7M  <= VID7M_INT;
    PHI_1  <= not PHI_0_INT;
    PHI_0  <= PHI_0_INT;
    Q3     <= Q3_INT;
    CAS_N  <= not N_CAS_N;
    RAS_N  <= RAS_N_INT;
end RTL;
