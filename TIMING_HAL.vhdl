library IEEE;
use IEEE.std_logic_1164.all;

entity TIMING_HAL is
    port (
        CLK_14M   : in std_logic;  -- PIN 1
        CLK_7M    : in std_logic;  -- PIN 2
        CREF      : in std_logic;  -- PIN 3  Color REFerence 3.5M CLK
        H0        : in std_logic;  -- PIN 4
        VID7      : in std_logic;  -- PIN 5
        SEGB      : in std_logic;  -- PIN 6
        GR_N      : in std_logic;  -- PIN 7  This is INVERTED GR+2 in "Understanding the Apple IIe" by Jim Sather (INVERTED LGR_TXT_N in the IOU emulator schematics). ????
        CASEN_N   : in std_logic;  -- PIN 8  Also called RAMEN_N
        S_80COL_N : in std_logic;  -- PIN 9  Also called 80VID_N
        ENTMG_N   : in std_logic;  -- PIN 11

        LDPS_N : out std_logic;  -- PIN 12
        VID7M  : out std_logic;  -- PIN 13
        PHI_1  : out std_logic;  -- PIN 14
        PHI_0  : out std_logic;  -- PIN 15
        Q3     : out std_logic;  -- PIN 16
        CAS_N  : out std_logic;  -- PIN 17
        AX     : out std_logic;  -- PIN 17  Left floating on the Apple IIe motherboard
        RAS_N  : out std_logic   -- PIN 19
    );
end TIMING_HAL;

architecture RTL of TIMING_HAL is
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

    signal LDPS_N_INT : std_logic;
    signal VID7M_INT  : std_logic;
    signal PHI_0_INT  : std_logic;
    signal PHI_1_INT  : std_logic;
    signal Q3_INT     : std_logic;
    signal CAS_N_INT  : std_logic;
    signal RAS_N_INT  : std_logic;
begin
    U_TIMING_INTERNALS : TIMING_INTERNALS port map(
        CLK_14M   => CLK_14M,
        CLK_7M    => CLK_7M,
        CREF      => CREF,
        H0        => H0,
        VID7      => VID7,
        SEGB      => SEGB,
        GR_N      => GR_N,
        CASEN_N   => CASEN_N,
        S_80COL_N => S_80COL_N,

        AX => AX,
        LDPS_N => LDPS_N_INT,
        VID7M  => VID7M_INT,
        PHI_1  => PHI_1_INT,
        PHI_0  => PHI_0_INT,
        Q3     => Q3_INT,
        CAS_N  => CAS_N_INT,
        RAS_N  => RAS_N_INT
    );

    LDPS_N <= LDPS_N_INT when ENTMG_N = '0' else 'Z';
    VID7M <= VID7M_INT   when ENTMG_N = '0' else 'Z';
    PHI_0 <= PHI_0_INT   when ENTMG_N = '0' else 'Z';
    PHI_1 <= PHI_1_INT   when ENTMG_N = '0' else 'Z';
    Q3    <= Q3_INT      when ENTMG_N = '0' else 'Z';
    CAS_N <= CAS_N_INT   when ENTMG_N = '0' else 'Z';
    RAS_N <= RAS_N_INT   when ENTMG_N = '0' else 'Z';
end RTL;
