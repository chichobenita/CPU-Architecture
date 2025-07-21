LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aux_package.all;


------entity------
entity digital_circuit is
		generic (n : integer := 16);
		port( x,y                  : in std_logic_vector(n-1 downto 0);
				pwm_mode           : in std_logic_vector(2 downto 0);
				counter_16_bit     : in std_logic_vector(15 downto 0);
				clk, enable, reset : in std_logic;
				pwm_out            : out std_logic;
				EQUY               : out std_logic
			);
end digital_circuit;

--------architecture-----
architecture dataflow of digital_circuit is
    signal x_sig               : std_logic_vector (n-1 downto 0);
    signal y_sig               : std_logic_vector (n-1 downto 0);
    signal pwm_mode_sig        : std_logic_vector (2 downto 0);
    signal counter_16_bit_sig  : std_logic_vector (15 downto 0);
    signal clk_sig             : std_logic;
    signal enable_sig          : std_logic;
    signal pwm_out_sig         : std_logic := '0';
    signal mux_to_ff           : std_logic := '0';
    signal reset_sig           : std_logic;
    signal EQUY_sig            : std_logic;
    signal toggle_triggered    : std_logic := '0';  -- prevent multiple toggles
begin
	 --- porting signals ---
	 x_sig 				<= x;
	 y_sig 				<= y;
	 pwm_mode_sig 		<= pwm_mode;
	 counter_16_bit_sig <= counter_16_bit;
	 clk_sig 		    <= clk;
	 enable_sig         <= enable;
	 pwm_out            <= pwm_out_sig;
	 reset_sig          <= reset;
	 EQUY				<= EQUY_sig;
	 
    -- EQUY signal logic (active when counter < y)
    process(counter_16_bit_sig, y_sig)
    begin
        if unsigned(counter_16_bit_sig) = unsigned(y_sig) then
            EQUY_sig <= '1';
        else
            EQUY_sig <= '0';
        end if;
    end process;

    -- Combinational logic for modes "000" and "001"
    process(x_sig, y_sig, pwm_mode_sig, counter_16_bit_sig, reset_sig)
    begin
        if reset_sig = '0' then
            mux_to_ff <= '0';
        else
            if unsigned(x_sig) < unsigned(y_sig) then
                case pwm_mode_sig is
                    when "000" =>
                        if (unsigned(x_sig) <= unsigned(counter_16_bit_sig)) and 
                           (unsigned(counter_16_bit_sig) <= unsigned(y_sig)) then
                            mux_to_ff <= '1';
                        else
                            mux_to_ff <= '0';
                        end if;

                    when "001" =>
                        if (unsigned(x_sig) <= unsigned(counter_16_bit_sig)) and 
                           (unsigned(counter_16_bit_sig) <= unsigned(y_sig)) then
                            mux_to_ff <= '0';
                        else
                            mux_to_ff <= '1';
                        end if;

                    when others =>
                        mux_to_ff <= '0';
                end case;
            else
                mux_to_ff <= '0';
            end if;
        end if;
    end process;

    -- Synchronous logic including toggle mode "010"
    process(clk_sig)
    begin
        if rising_edge(clk_sig) then
            if enable_sig = '1' then
                case pwm_mode_sig is
                    when "010" =>
                        -- Toggle pwm_out only when counter matches x
                        if unsigned(counter_16_bit_sig) = unsigned(x_sig) then
                            if toggle_triggered = '0' then
                                pwm_out_sig <= not pwm_out_sig;
                                toggle_triggered <= '1';
                            end if;
                        else
                            toggle_triggered <= '0';
                        end if;

                    when others =>
                        pwm_out_sig <= mux_to_ff;
                        toggle_triggered <= '0';  -- Reset toggle guard
                end case;
            end if;
        end if;
    end process;
end dataflow;


				