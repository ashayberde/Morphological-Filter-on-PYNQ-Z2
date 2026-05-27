-- Libraries and Packages
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Entity Declaration
ENTITY FIR_3x3 IS
    PORT (
        clk : IN STD_LOGIC; -- Clock signal
        rst : IN STD_LOGIC; -- Reset signal
        switch : IN UNSIGNED(31 DOWNTO 0); -- Control for operations (0: erosion, 1: dilation)
        run : IN STD_LOGIC; -- Signal to start computations
        x_input : IN SIGNED(8 DOWNTO 0); -- Input signal
        y : OUT SIGNED(8 DOWNTO 0) -- Output signal
    );
END FIR_3x3;

-- Architecture Declaration
ARCHITECTURE Behavioral OF FIR_3x3 IS
    -- Internal data structure for processing
    TYPE pixel_window IS ARRAY (1 TO 3, 1 TO 3) OF SIGNED(8 DOWNTO 0);
    SIGNAL window : pixel_window;
    SIGNAL column : INTEGER RANGE 0 TO 2 := 0; -- To track the current column in the row
    SIGNAL row : INTEGER RANGE 1 TO 3 := 1;    -- To track the current row

BEGIN
    -- Main Process
    PROCESS (clk, rst)
    VARIABLE min_val : SIGNED(8 DOWNTO 0) := "011111111"; -- Initial minimum value
    VARIABLE max_val : SIGNED(8 DOWNTO 0) := (OTHERS => '0'); -- Initial maximum value
    BEGIN
        IF rst = '0' THEN
            -- Reset condition
            FOR i IN 1 TO 3 LOOP
                FOR j IN 1 TO 3 LOOP
                    window(i, j) <= (OTHERS => '0'); -- Reset all elements
                END LOOP;
            END LOOP;
            min_val := "011111111"; -- Reset min value
            max_val := (OTHERS => '0'); -- Reset max value
            column <= 0;
            row <= 1;
        ELSIF rising_edge(clk) THEN
            IF run = '1' THEN
                -- Load new pixel into the current position
                window(row, column + 1) <= x_input;

                -- Update column, manage row and column transitions
                IF column = 2 THEN
                    column <= 0;
                    IF row = 3 THEN
                        -- Shift rows up when the last column of the last row is filled
                        FOR i IN 1 TO 2 LOOP
                            FOR j IN 1 TO 3 LOOP
                                window(i, j) <= window(i+1, j);
                            END LOOP;
                        END LOOP;
                        row <= 3;
                    ELSE
                        row <= row + 1;
                    END IF;
                ELSE
                    column <= column + 1;
                END IF;

                -- Perform morphological operations
                IF switch =0 THEN -- Erosion
                    min_val := window(1, 1); -- Initialize minimum value
                    FOR i IN 1 TO 3 LOOP
                        FOR j IN 1 TO 3 LOOP
                            IF window(i, j) < min_val THEN
                                min_val := window(i, j); -- Find minimum
                            END IF;
                        END LOOP;
                    END LOOP;
                    y <= min_val; -- Assign resized min value to output

                ELSIF switch =1 THEN -- Dilation
                    max_val := window(1, 1); -- Initialize maximum value
                    FOR i IN 1 TO 3 LOOP
                        FOR j IN 1 TO 3 LOOP
                            IF window(i, j) > max_val THEN
                                max_val := window(i, j); -- Find maximum
                            END IF;
                        END LOOP;
                    END LOOP;
                    y <= max_val; -- Assign resized max value to output
               ELSIF switch =2 THEN -- Erosion
                    min_val := window(1, 1); -- Initialize minimum value
                    FOR i IN 1 TO 3 LOOP
                        FOR j IN 1 TO 3 LOOP
                            IF window(i, j) < min_val THEN
                                min_val := window(i, j); -- Find minimum
                            END IF;
                        END LOOP;
                    END LOOP;
                    y <= min_val; -- Assign resized min value to output
               ELSIF switch =3 THEN -- Dilation
                    max_val := window(1, 1); -- Initialize maximum value
                    FOR i IN 1 TO 3 LOOP
                        FOR j IN 1 TO 3 LOOP
                            IF window(i, j) > max_val THEN
                                max_val := window(i, j); -- Find maximum
                            END IF;
                        END LOOP;
                    END LOOP;
                   y <= max_val; -- Assign resized max value to output
              
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;