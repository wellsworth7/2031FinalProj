-- LEDController.vhd (Simple version)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LEDController IS
PORT(
	 CLK1		  : IN  STD_LOGIC;
	 CLK2		  : IN  STD_LOGIC;
    CS        : IN  STD_LOGIC;
    WRITE_EN  : IN  STD_LOGIC;
    RESETN    : IN  STD_LOGIC;
    IO_DATA   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    LEDs      : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
);
END LEDController;

ARCHITECTURE Simple OF LEDController IS
    type state_type is (s_on, s_off, s_flash, s_pulse);
    type state_array is array (0 to 9) of state_type;

    signal led_state   : state_array := (others => s_off);
    signal led_out     : std_logic_vector(9 downto 0) := (others => '0');
    signal counter     : integer range 0 to 15 := 0;
    signal flash_toggle: std_logic := '0';

    signal led_mask   : std_logic_vector(9 downto 0);
    signal state_bits : std_logic_vector(1 downto 0);
BEGIN
    -- Connect to output
    LEDs <= led_out;

    ------------------------------------
    -- Process 1: Write to led_state[] --
    ------------------------------------
    PROCESS(CLK2)
    BEGIN
        IF rising_edge(CLK2) THEN
            IF RESETN = '0' THEN
                FOR i IN 0 TO 9 LOOP
                    led_state(i) <= s_off;
                END LOOP;

            ELSIF CS = '1' AND WRITE_EN = '1' THEN
                led_mask   <= IO_DATA(9 downto 0);
                state_bits <= IO_DATA(15 downto 14);

                FOR i IN 0 TO 9 LOOP
						  IF led_mask(i) = '1' THEN
								CASE state_bits IS
                            WHEN "00" => led_state(i) <= s_off;
                            WHEN "01" => led_state(i) <= s_on;
                            WHEN "10" => led_state(i) <= s_flash;
                            WHEN "11" => led_state(i) <= s_pulse;
                            WHEN OTHERS => led_state(i) <= s_off;
                        END CASE;
                    END IF;
                END LOOP;
            END IF;

            -- Flash counter update
            IF counter < 15 THEN
                counter <= counter + 1;
            ELSE
                counter <= 0;
                flash_toggle <= NOT flash_toggle;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------
    -- Process 2: Drive led_out[] based on state
    --------------------------------------------
    PROCESS(CLK2)
    BEGIN
        IF rising_edge(CLK2) THEN
            FOR i IN 0 TO 9 LOOP
                CASE led_state(i) IS
                    WHEN s_on =>
                        led_out(i) <= '1';
                    WHEN s_off =>
                        led_out(i) <= '0';
                    WHEN s_flash =>
                        led_out(i) <= flash_toggle;
                    WHEN s_pulse =>
                        IF counter < 8 THEN
                            led_out(i) <= '1';
                        ELSE
                            led_out(i) <= '0';
                        END IF;
                    WHEN OTHERS =>
                        led_out(i) <= '0';
                END CASE;
            END LOOP;
        END IF;
    END PROCESS;
END Simple;