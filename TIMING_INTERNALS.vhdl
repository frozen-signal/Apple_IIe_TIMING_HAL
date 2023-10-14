library IEEE;
use IEEE.std_logic_1164.all;

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

        AX     : out std_logic;
        LDPS_N : out std_logic;
        VID7M  : out std_logic;
        PHI_1  : out std_logic;
        PHI_0  : out std_logic;
        Q3     : out std_logic;
        CAS_N  : out std_logic;
        RAS_N  : out std_logic
    );
end TIMING_INTERNALS;

architecture RTL of TIMING_INTERNALS is
    signal RAS_N_INT : std_logic := '0';
    signal AX_INT    : std_logic;
    signal PHI_0_INT : std_logic := '0';
    signal Q3_INT    : std_logic := '0';
    signal CAS_N_INT : std_logic := '0';
    signal VID7M_INT : std_logic;
begin
    process (CLK_14M)
    begin
        if (rising_edge(CLK_14M)) then
            RAS_N_INT <= not (Q3_INT
                or (CLK_7M and (not RAS_N_INT) and (not PHI_0_INT))
                or ((not CLK_7M) and (not AX_INT) and PHI_0_INT)
                or (CLK_7M and CREF and AX_INT and H0 and PHI_0_INT)
                or ((not CLK_7M) and (not CREF) and AX_INT and H0 and PHI_0_INT));

                AX_INT <= not ((not RAS_N_INT) and Q3_INT);

            PHI_0_INT <= not ((RAS_N_INT and (not Q3_INT) and PHI_0_INT)
                or (Q3_INT and (not PHI_0_INT))
                or ((not RAS_N_INT) and (not PHI_0_INT)));

            Q3_INT <= not (((not CLK_7M) and (not AX_INT) and (not PHI_0_INT))
                or ((not RAS_N_INT) and (not Q3_INT))
                or (CLK_7M and (not AX_INT) and PHI_0_INT));

            -- From "Understanding the Apple IIe" by Jim Sather:
            --    "CAS_N is gated by CASEN_N from the MMU during PHASE 0 to enable or disable motherboard RAM.
            --     CAS_N always falls during PHASE 1 and falls during PHASE 0 if CASEN_N is low."
            CAS_N_INT <= not (((not RAS_N_INT) and (not AX_INT) and CAS_N_INT and (not PHI_0_INT))
                or ((not RAS_N_INT) and (not AX_INT) and CAS_N_INT and PHI_0_INT and (not CASEN_N))
                or ((not RAS_N_INT) and (not CAS_N_INT)));

            VID7M_INT <= not((CLK_7M and GR_N)
                or ((not SEGB) and PHI_0_INT and (not GR_N) and VID7M_INT)
                or (Q3_INT and (not SEGB) and (not GR_N) and VID7M_INT)
                or (AX_INT and (not SEGB) and (not GR_N) and VID7M_INT)
                or ((not AX_INT) and (not VID7) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR_N))
                or (CREF and (not AX_INT) and (not H0) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR_N))
                or (SEGB and (not GR_N))
                or (GR_N and (not S_80COL_N)));

            LDPS_N <= not ((CLK_7M     and (not RAS_N_INT) and (not VID7) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR_N))  -- HIRES Delayed
                or (      (not CLK_7M) and (not RAS_N_INT) and VID7       and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR_N))  -- HIRES not delayed
                or ((not AX_INT) and (not Q3_INT) and SEGB and (not PHI_0_INT) and (not GR_N))                               -- LORES mode
                or ((not AX_INT) and (not Q3_INT) and (not PHI_0_INT) and GR_N)                                              -- TEXT mode
                or ((not AX_INT) and (not Q3_INT) and PHI_0_INT and GR_N and (not S_80COL_N))                                -- Double RES causes LDPS_N during PHASE 0 & 1
                or (CREF and (not AX_INT) and (not H0) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR_N))); -- Right display edge cutoff

        end if;
    end process;

    AX    <= AX_INT;
    RAS_N <= RAS_N_INT;
    PHI_0 <= PHI_0_INT;
    PHI_1 <= not PHI_0_INT;
    Q3    <= Q3_INT;
    CAS_N <= CAS_N_INT;
    VID7M <= VID7M_INT;
end RTL;
