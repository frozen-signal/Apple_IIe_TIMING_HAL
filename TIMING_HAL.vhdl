library IEEE;
use IEEE.std_logic_1164.all;

entity TIMING_HAL is
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
        ENTMG_N : in std_logic;

        LDPS_N : out std_logic;
        VID7M : out std_logic;
        PHI_1 : out std_logic;
        PHI_0 : out std_logic;
        Q3 : out std_logic;
        CAS_N : out std_logic;
        RAS_N : out std_logic
    );
end TIMING_HAL;

architecture RTL of TIMING_HAL is
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

    signal LDPS_N_INT : std_logic;
    signal VID7M_INT : std_logic;
    signal PHI_0_INT : std_logic;
    signal PHI_1_INT : std_logic;
    signal Q3_INT : std_logic;
    signal CAS_N_INT : std_logic;
    signal RAS_N_INT : std_logic;
begin
    U_TIMING_INTERNALS : TIMING_INTERNALS port map(
        CLK_14M => CLK_14M,
        CLK_7M => CLK_7M,
        CREF => CREF,
        H0 => H0,
        VID7 => VID7,
        SEGB => SEGB,
        GR => GR,
        CASEN_N => GR,
        S_80COL_N => S_80COL_N,

        LDPS_N => LDPS_N_INT,
        VID7M => VID7M_INT,
        PHI_1 => PHI_1_INT,
        PHI_0 => PHI_0_INT,
        Q3 => Q3_INT,
        CAS_N => CAS_N_INT,
        RAS_N => RAS_N_INT
    );

    LDPS_N <= LDPS_N_INT when ENTMG_N = '0' else 'Z';
    VID7M <= VID7M_INT when ENTMG_N = '0' else 'Z';
    PHI_0 <= PHI_0_INT when ENTMG_N = '0' else 'Z';
    PHI_1 <= PHI_1_INT when ENTMG_N = '0' else 'Z';
    Q3 <= Q3_INT when ENTMG_N = '0' else 'Z';
    CAS_N <= CAS_N_INT when ENTMG_N = '0' else 'Z';
    RAS_N <= RAS_N_INT when ENTMG_N = '0' else 'Z';

end RTL;
