LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pMem IS
    PORT (
        adress : IN unsigned(11 DOWNTO 0);
        data : OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
END pMem;

ARCHITECTURE func OF pMem IS
    TYPE p_mem_t IS ARRAY(NATURAL RANGE <>) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
    CONSTANT p_mem_c : p_mem_t :=
    -- 00000_000_00_000000000000_00
    -- OP    GRx M  ADR          *unused
    -- 5     3   2  12           2
    (
    b"00000_000_01_00000000111100", -- LOAD GR0, immediate, 0d60
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000",
    b"00000_000_00_00000000000000"
    );
BEGIN
    data <= p_mem_c(TO_INTEGER(adress));
END ARCHITECTURE;