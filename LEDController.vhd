LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LEDController IS
PORT(
    CLK1       : IN  STD_LOGIC;
    CLK2       : IN  STD_LOGIC;
    CS         : IN  STD_LOGIC;
    WRITE_EN   : IN  STD_LOGIC;
    RESETN     : IN  STD_LOGIC;
    IO_DATA    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    LEDs       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
);
END LEDController;

ARCHITECTURE Simple OF LEDController IS
    type state_type is (s_off, s_on, s_flash);
    type state_array is array (0 to 9) of state_type;

    signal led_state    : state_array := (others => s_off);
    signal led_out      : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others => '0');
    signal flash_toggle : STD_LOGIC := '0';
BEGIN
    LEDs <= led_out;

    -- Toggle flash every CLK1 pulse
    PROCESS (CLK1)
    BEGIN
        IF rising_edge(CLK1) THEN
            flash_toggle <= NOT flash_toggle;
        END IF;
    END PROCESS;

    -- Handle state setting and LED output
    PROCESS (CLK2)
        variable state_bits : STD_LOGIC_VECTOR(1 DOWNTO 0);
        variable led_mask   : STD_LOGIC_VECTOR(9 DOWNTO 0);
    BEGIN
        IF rising_edge(CLK2) THEN
            IF RESETN = '0' THEN
                FOR i IN 0 TO 9 LOOP
                    led_state(i) <= s_off;
                END LOOP;

            ELSIF CS = '1' AND WRITE_EN = '1' THEN
                state_bits := IO_DATA(15 DOWNTO 14);
                led_mask   := IO_DATA(9 DOWNTO 0);

                FOR i IN 0 TO 9 LOOP
                    IF led_mask(i) = '1' THEN
                        CASE state_bits IS
                            WHEN "00" => led_state(i) <= s_off;
                            WHEN "01" => led_state(i) <= s_on;
                            WHEN "10" => led_state(i) <= s_flash;
                            WHEN OTHERS => led_state(i) <= s_off;
                        END CASE;
                    END IF;
                END LOOP;
            END IF;

            -- Apply logic to output LEDs
            FOR i IN 0 TO 9 LOOP
                CASE led_state(i) IS
                    WHEN s_off   => led_out(i) <= '0';
                    WHEN s_on    => led_out(i) <= '1';
                    WHEN s_flash => led_out(i) <= flash_toggle;
                    WHEN OTHERS  => led_out(i) <= '0';
                END CASE;
            END LOOP;
        END IF;
    END PROCESS;
END Simple;
