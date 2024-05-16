LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pMem IS
    PORT (
        clk : IN STD_LOGIC;
        cpu_address : IN unsigned(11 DOWNTO 0);
        cpu_data_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
        cpu_data_in : IN unsigned(23 DOWNTO 0);
        cpu_we : IN STD_LOGIC;
        video_address : IN unsigned(6 DOWNTO 0);
        video_data_out : OUT unsigned(5 DOWNTO 0)
    );
END pMem;

ARCHITECTURE func OF pMem IS


    TYPE p_mem_type IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(23 DOWNTO 0);

    CONSTANT PROGRAM : INTEGER := 0;
    CONSTANT VMEM : INTEGER := 1500;
    CONSTANT PATH : INTEGER := 1630;
    CONSTANT HEAP : INTEGER := 3000;

    -- 00000_0000_00_0_000000000000
    -- OP    GRx  M  K   ADR 
    -- 5     4    2  1   12  
    SIGNAL p_mem : p_mem_type := (
        -- PROGRAM
        PROGRAM+0 => b"00000_0000_01_0_------------", -- start : LDI GR0, 2
        PROGRAM+1 => b"000000000000000000000010", -- 
        PROGRAM+2 => b"00000_0011_01_0_------------", -- LDI GR3, 20
        PROGRAM+3 => b"000000000000000000010100", -- 
        PROGRAM+4 => b"00001_0000_11_0_010111011100", -- loop : STN 1500, GR0
        PROGRAM+5 => b"00011_0011_01_0_------------", -- SUBI GR3, 1
        PROGRAM+6 => b"000000000000000000000001", -- 
        PROGRAM+7 => b"01010_----_00_0_000000000100", -- BRA loop
        PROGRAM+8 => b"11111_----_--_0_------------", -- end : HALT
        -- VMEM
        VMEM+0 => b"000000000000000000000000", -- 0
        VMEM+1 => b"000000000000000000000000", -- 0
        VMEM+2 => b"000000000000000000000000", -- 0
        VMEM+3 => b"000000000000000000000000", -- 0
        VMEM+4 => b"000000000000000000000000", -- 0
        VMEM+5 => b"000000000000000000000000", -- 0
        VMEM+6 => b"000000000000000000000000", -- 0
        VMEM+7 => b"000000000000000000000000", -- 0
        VMEM+8 => b"000000000000000000000000", -- 0
        VMEM+9 => b"000000000000000000000000", -- 0
        VMEM+10 => b"000000000000000000100111", -- 39
        VMEM+11 => b"000000000000000000100110", -- 38
        VMEM+12 => b"000000000000000000101000", -- 40
        VMEM+13 => b"000000000000000000000000", -- 0
        VMEM+14 => b"000000000000000000011001", -- 25
        VMEM+15 => b"000000000000000000011001", -- 25
        VMEM+16 => b"000000000000000000011001", -- 25
        VMEM+17 => b"000000000000000000011001", -- 25
        VMEM+18 => b"000000000000000000011001", -- 25
        VMEM+19 => b"000000000000000000011001", -- 25
        VMEM+20 => b"000000000000000000011001", -- 25
        VMEM+21 => b"000000000000000000011001", -- 25
        VMEM+22 => b"000000000000000000000000", -- 0
        VMEM+23 => b"000000000000000000100110", -- 38
        VMEM+24 => b"000000000000000000100110", -- 38
        VMEM+25 => b"000000000000000000100110", -- 38
        VMEM+26 => b"000000000000000000000000", -- 0
        VMEM+27 => b"000000000000000000011001", -- 25
        VMEM+28 => b"000000000000000000000001", -- 1
        VMEM+29 => b"000000000000000000000000", -- 0
        VMEM+30 => b"000000000000000000000001", -- 1
        VMEM+31 => b"000000000000000000000000", -- 0
        VMEM+32 => b"000000000000000000000000", -- 0
        VMEM+33 => b"000000000000000000000000", -- 0
        VMEM+34 => b"000000000000000000011001", -- 25
        VMEM+35 => b"000000000000000000000000", -- 0
        VMEM+36 => b"000000000000000000101001", -- 41
        VMEM+37 => b"000000000000000000100110", -- 38
        VMEM+38 => b"000000000000000000101010", -- 42
        VMEM+39 => b"000000000000000000000000", -- 0
        VMEM+40 => b"000000000000000000011001", -- 25
        VMEM+41 => b"000000000000000000000000", -- 0
        VMEM+42 => b"000000000000000000011001", -- 25
        VMEM+43 => b"000000000000000000011001", -- 25
        VMEM+44 => b"000000000000000000011001", -- 25
        VMEM+45 => b"000000000000000000011001", -- 25
        VMEM+46 => b"000000000000000000011001", -- 25
        VMEM+47 => b"000000000000000000011001", -- 25
        VMEM+48 => b"000000000000000000000000", -- 0
        VMEM+49 => b"000000000000000000100110", -- 38
        VMEM+50 => b"000000000000000000100110", -- 38
        VMEM+51 => b"000000000000000000100110", -- 38
        VMEM+52 => b"000000000000000000011001", -- 25
        VMEM+53 => b"000000000000000000011001", -- 25
        VMEM+54 => b"000000000000000000000000", -- 0
        VMEM+55 => b"000000000000000000011001", -- 25
        VMEM+56 => b"000000000000000000000000", -- 0
        VMEM+57 => b"000000000000000000000000", -- 0
        VMEM+58 => b"000000000000000000000000", -- 0
        VMEM+59 => b"000000000000000000000000", -- 0
        VMEM+60 => b"000000000000000000000000", -- 0
        VMEM+61 => b"000000000000000000000000", -- 0
        VMEM+62 => b"000000000000000000101011", -- 43
        VMEM+63 => b"000000000000000000100110", -- 38
        VMEM+64 => b"000000000000000000101100", -- 44
        VMEM+65 => b"000000000000000000000000", -- 0
        VMEM+66 => b"000000000000000000000000", -- 0
        VMEM+67 => b"000000000000000000000000", -- 0
        VMEM+68 => b"000000000000000000011001", -- 25
        VMEM+69 => b"000000000000000000000000", -- 0
        VMEM+70 => b"000000000000000000011001", -- 25
        VMEM+71 => b"000000000000000000011001", -- 25
        VMEM+72 => b"000000000000000000011001", -- 25
        VMEM+73 => b"000000000000000000000000", -- 0
        VMEM+74 => b"000000000000000000000000", -- 0
        VMEM+75 => b"000000000000000000100110", -- 38
        VMEM+76 => b"000000000000000000100110", -- 38
        VMEM+77 => b"000000000000000000100110", -- 38
        VMEM+78 => b"000000000000000000000000", -- 0
        VMEM+79 => b"000000000000000000011001", -- 25
        VMEM+80 => b"000000000000000000011001", -- 25
        VMEM+81 => b"000000000000000000011001", -- 25
        VMEM+82 => b"000000000000000000000000", -- 0
        VMEM+83 => b"000000000000000000011001", -- 25
        VMEM+84 => b"000000000000000000000000", -- 0
        VMEM+85 => b"000000000000000000011001", -- 25
        VMEM+86 => b"000000000000000000000000", -- 0
        VMEM+87 => b"000000000000000000000000", -- 0
        VMEM+88 => b"000000000000000000100110", -- 38
        VMEM+89 => b"000000000000000000100110", -- 38
        VMEM+90 => b"000000000000000000100110", -- 38
        VMEM+91 => b"000000000000000000000000", -- 0
        VMEM+92 => b"000000000000000000011001", -- 25
        VMEM+93 => b"000000000000000000000000", -- 0
        VMEM+94 => b"000000000000000000000000", -- 0
        VMEM+95 => b"000000000000000000000000", -- 0
        VMEM+96 => b"000000000000000000011001", -- 25
        VMEM+97 => b"000000000000000000000000", -- 0
        VMEM+98 => b"000000000000000000011001", -- 25
        VMEM+99 => b"000000000000000000000000", -- 0
        VMEM+100 => b"000000000000000000000000", -- 0
        VMEM+101 => b"000000000000000000101101", -- 45
        VMEM+102 => b"000000000000000000101110", -- 46
        VMEM+103 => b"000000000000000000101111", -- 47
        VMEM+104 => b"000000000000000000000000", -- 0
        VMEM+105 => b"000000000000000000011001", -- 25
        VMEM+106 => b"000000000000000000011001", -- 25
        VMEM+107 => b"000000000000000000011001", -- 25
        VMEM+108 => b"000000000000000000011001", -- 25
        VMEM+109 => b"000000000000000000011001", -- 25
        VMEM+110 => b"000000000000000000000000", -- 0
        VMEM+111 => b"000000000000000000011001", -- 25
        VMEM+112 => b"000000000000000000011001", -- 25
        VMEM+113 => b"000000000000000000011001", -- 25
        VMEM+114 => b"000000000000000000100110", -- 38
        VMEM+115 => b"000000000000000000100110", -- 38
        VMEM+116 => b"000000000000000000100110", -- 38
        VMEM+117 => b"000000000000000000000000", -- 0
        VMEM+118 => b"000000000000000000000000", -- 0
        VMEM+119 => b"000000000000000000000000", -- 0
        VMEM+120 => b"000000000000000000000000", -- 0
        VMEM+121 => b"000000000000000000000000", -- 0
        VMEM+122 => b"000000000000000000000000", -- 0
        VMEM+123 => b"000000000000000000000000", -- 0
        VMEM+124 => b"000000000000000000000000", -- 0
        VMEM+125 => b"000000000000000000000000", -- 0
        VMEM+126 => b"000000000000000000000000", -- 0
        VMEM+127 => b"000000000000000000110000", -- 48
        VMEM+128 => b"000000000000000000110001", -- 49
        VMEM+129 => b"000000000000000000110010", -- 50
        -- PATH
        PATH+0 => b"000000000000000000110100", -- 52
        PATH+1 => b"000000000000000000110101", -- 53
        PATH+2 => b"000000000000000000101000", -- 40
        PATH+3 => b"000000000000000000011011", -- 27
        PATH+4 => b"000000000000000000001110", -- 14
        PATH+5 => b"000000000000000000001111", -- 15
        PATH+6 => b"000000000000000000010000", -- 16
        PATH+7 => b"000000000000000000010001", -- 17
        PATH+8 => b"000000000000000000010010", -- 18
        PATH+9 => b"000000000000000000010011", -- 19
        PATH+10 => b"000000000000000000010100", -- 20
        PATH+11 => b"000000000000000000010101", -- 21
        PATH+12 => b"000000000000000000100010", -- 34
        PATH+13 => b"000000000000000000101111", -- 47
        PATH+14 => b"000000000000000000101110", -- 46
        PATH+15 => b"000000000000000000101101", -- 45
        PATH+16 => b"000000000000000000101100", -- 44
        PATH+17 => b"000000000000000000101011", -- 43
        PATH+18 => b"000000000000000000101010", -- 42
        PATH+19 => b"000000000000000000110111", -- 55
        PATH+20 => b"000000000000000001000100", -- 68
        PATH+21 => b"000000000000000001010001", -- 81
        PATH+22 => b"000000000000000001010000", -- 80
        PATH+23 => b"000000000000000001001111", -- 79
        PATH+24 => b"000000000000000001011100", -- 92
        PATH+25 => b"000000000000000001101001", -- 105
        PATH+26 => b"000000000000000001101010", -- 106
        PATH+27 => b"000000000000000001101011", -- 107
        PATH+28 => b"000000000000000001101100", -- 108
        PATH+29 => b"000000000000000001101101", -- 109
        PATH+30 => b"000000000000000001100000", -- 96
        PATH+31 => b"000000000000000001010011", -- 83
        PATH+32 => b"000000000000000001000110", -- 70
        PATH+33 => b"000000000000000001000111", -- 71
        PATH+34 => b"000000000000000001001000", -- 72
        PATH+35 => b"000000000000000001010101", -- 85
        PATH+36 => b"000000000000000001100010", -- 98
        -- HEAP
        OTHERS => (OTHERS => '-')
    );

BEGIN

    -- Reading from two-port ram
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            cpu_data_out <= p_mem(TO_INTEGER(cpu_address) + PROGRAM);
            video_data_out <= unsigned(p_mem(TO_INTEGER(video_address) + VMEM)(5 downto 0));
        END IF;
    END PROCESS;

    -- STORE
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (cpu_we = '1') THEN
                p_mem(TO_INTEGER(cpu_address)) <= STD_LOGIC_VECTOR(cpu_data_in);
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;