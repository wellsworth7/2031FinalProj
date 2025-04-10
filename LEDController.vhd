LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LEDController IS
PORT(
	 CLK1			: IN  STD_LOGIC;
    CLK2       : IN  STD_LOGIC;
    CS         : IN  STD_LOGIC;
    WRITE_EN   : IN  STD_LOGIC;
    RESETN     : IN  STD_LOGIC;
    IO_DATA    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    LEDs       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
);
END LEDController;

ARCHITECTURE Simple OF LEDController IS
    signal led_out : std_logic_vector(9 downto 0) := (others => '0');
BEGIN
    LEDs <= led_out;

    PROCESS (CLK2)
        variable state_bits : std_logic_vector(1 downto 0);
        variable led_mask   : std_logic_vector(9 downto 0);
    BEGIN
        IF rising_edge(CLK2) THEN
            IF RESETN = '0' THEN
                led_out <= (others => '0');

            ELSIF CS = '1' AND WRITE_EN = '1' THEN
                state_bits := IO_DATA(15 downto 14);
                led_mask   := IO_DATA(9 downto 0);

                FOR i IN 0 TO 9 LOOP
    IF led_mask(i) = '1' THEN
        -- LED should be turned ON
        CASE state_bits IS
            WHEN "00" => led_out(i) <= '0';  -- s_off
            WHEN "01" => led_out(i) <= '1';  -- s_on
            WHEN OTHERS => led_out(i) <= '0';
        END CASE;
    ELSE
        -- Mask bit is 0 → force OFF
        led_out(i) <= '0';
    END IF;
END LOOP;

            END IF;
        END IF;
    END PROCESS;
END Simple;
