library IEEE;
use IEEE.std_logic_1164.all;

entity TIMING_INTERNALS is
    port (
        CLK_14M : in std_logic;
        CLK_7M : in std_logic;
        CREF : in std_logic;  -- 3.5M CLK
        H0 : in std_logic;
        VID7 : in std_logic;
        SEGB : in std_logic;
        GR : in std_logic;  -- This is GR+2 in "Understanding the Apple IIe" by Jim Sather, and called LGR_TXT_N in the IOU emulator schematics.
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
end TIMING_INTERNALS;

architecture RTL of TIMING_INTERNALS is
    signal RAS_N_INT : std_logic := '0';
    signal AX : std_logic;
    signal PHI_0_INT : std_logic := '0';
    signal Q3_INT : std_logic := '0';
    signal CAS_N_INT : std_logic;
    signal VID7M_INT : std_logic;
begin
    process (CLK_14M)
    begin
        if (rising_edge(CLK_14M)) then
            RAS_N_INT <= not (Q3_INT
                or (CLK_7M and (not RAS_N_INT) and (not PHI_0_INT))
                or ((not CLK_7M) and (not AX) and PHI_0_INT)
                or (CLK_7M and CREF and AX and H0 and PHI_0_INT)
                or ((not CLK_7M) and (not CREF) and AX and H0 and PHI_0_INT));

            AX <= not ((not RAS_N_INT) and Q3_INT);

            PHI_0_INT <= not ((RAS_N_INT and (not Q3_INT) and PHI_0_INT)
                or (Q3_INT and (not PHI_0_INT))
                or ((not RAS_N_INT) and (not PHI_0_INT)));

            Q3_INT <= not (((not CLK_7M) and (not AX) and (not PHI_0_INT))
                or ((not RAS_N_INT) and (not Q3_INT))
                or (CLK_7M and (not AX) and PHI_0_INT));

            CAS_N_INT <= not (((not RAS_N_INT) and (not AX) and CAS_N_INT and (not PHI_0_INT))
                or ((not RAS_N_INT) and (not AX) and CAS_N_INT and PHI_0_INT and (not CASEN_N))
                or ((not RAS_N_INT) and (not CAS_N_INT)));

            VID7M_INT <= not((CLK_7M and GR)
                or ((not SEGB) and PHI_0_INT and (not GR) and VID7M_INT)
                or (Q3_INT and (not SEGB) and (not GR) and VID7M_INT)
                or (AX and (not SEGB) and (not GR) and VID7M_INT)
                or ((not AX) and (not VID7) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR))
                or (CREF and (not AX) and (not H0) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR))
                or (SEGB and (not GR))
                or (GR and (not S_80COL_N)));

            LDPS_N <= not ((CLK_7M and (not RAS_N_INT) and (not VID7) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR))
                or ((not S_80COL_N) and (not RAS_N_INT) and VID7 and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR))
                or ((not AX) and (not Q3_INT) and SEGB and (not PHI_0_INT) and (not GR))
                or ((not AX) and (not Q3_INT) and (not PHI_0_INT) and GR)
                or ((not AX) and (not Q3_INT) and PHI_0_INT and GR and (not S_80COL_N))
                or (CREF and (not AX) and (not H0) and (not Q3_INT) and (not SEGB) and (not PHI_0_INT) and (not GR)));

        end if;
    end process;

    RAS_N <= RAS_N_INT;
    PHI_0 <= PHI_0_INT;
    PHI_1 <= not PHI_0_INT;
    Q3 <= Q3_INT;
    CAS_N_INT <= CAS_N_INT;
    VID7M <= VID7M_INT;
end RTL;
