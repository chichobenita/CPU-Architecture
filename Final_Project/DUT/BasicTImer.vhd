LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  BasicTimer IS
	PORT(	MCLK		 	: IN 	STD_LOGIC;
			rst_i		 	: IN 	STD_LOGIC;
			address_bus_i	: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			data_bus_io		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead_i 		: IN 	STD_LOGIC;
			MemWrite_i 		: IN 	STD_LOGIC;
			PWM_out 		: OUT 	STD_LOGIC;
			BTIFG 		    : OUT 	STD_LOGIC );
END BasicTimer;

ARCHITECTURE behavior OF BasicTimer IS

	SIGNAL CURRENT_REG			 					    : STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	SIGNAL Dout	, Din									: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL en_sig										: STD_LOGIC;
	SIGNAL output_unit									: STD_LOGIC;
	SIGNAL HEU0                                         : STD_LOGIC;
	SIGNAL BTCNT										: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCCR0_reg									: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCCR1_reg									: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCCR0_q							     		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCCR1_q									    : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCTL										: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL MCLK2, MCLK4, MCLK8, mux_to_clk		     	: STD_LOGIC;

BEGIN
	
BT2BUS : BidirPin generic map(width => 32) port map(Dout => Dout, en => en_sig, Din => Din, IOpin => data_bus_io);
	 -- address_bus_i(11) & address_bus_i(6 DOWNTO 0);
	WITH address_bus_i SELECT
	CURRENT_REG <= "0001" WHEN "10011100", -- BTCTL
		           "0010" WHEN "10100000", -- BTCNT
		           "0100" WHEN "10100100", -- BTCCR0_reg
		           "1000" WHEN "10101000", -- BTCCR1_reg
		           "0000" WHEN OTHERS;


	-- 	assign to Dout we want to write to the data bus;
	Dout <= X"000000" & BTCTL WHEN (MemRead_i = '1' AND CURRENT_REG(0) = '1') ELSE
			BTCNT             WHEN (MemRead_i = '1' AND CURRENT_REG(1) = '1') ELSE
			BTCCR0_reg        WHEN (MemRead_i = '1' AND CURRENT_REG(2) = '1') ELSE
			BTCCR1_reg        WHEN (MemRead_i = '1' AND CURRENT_REG(3) = '1') ELSE
			(OTHERS => '0');
	
	en_sig <= '1' WHEN (MemRead_i = '1' AND CURRENT_REG /= "0000") ELSE '0'; -- we can read only when the control bus tell as to read and a specific address


	-- mux of choosing the clock for BTCNT and output unit;
	mux_to_clk <=   MCLK  WHEN BTCTL(4 DOWNTO 3) = "00" ELSE
					MCLK2 WHEN BTCTL(4 DOWNTO 3) = "01" ELSE
					MCLK4 WHEN BTCTL(4 DOWNTO 3) = "10" ELSE
					MCLK8 WHEN BTCTL(4 DOWNTO 3) = "11" ELSE
					MCLK;		   			   


    
    BTCCRx_REG: PROCESS (rst_i, MCLK)
    BEGIN
		IF rst_i = '1' THEN
			BTCCR0_reg <= X"00000000";
			BTCCR1_reg <= X"00000000";
		ELSIF falling_edge(MCLK) THEN
			IF rst_i = '1' THEN
				BTCCR0_reg <= X"00000000";
				BTCCR1_reg <= X"00000000";
			ELSIF MemWrite_i = '1' AND CURRENT_REG(2) = '1' THEN
				BTCCR0_reg <= Din;
			ELSIF MemWrite_i = '1' AND CURRENT_REG(3) = '1' THEN
				BTCCR1_reg <= Din;
			END IF;
		END IF;
	END PROCESS;
	
	BTCCRx_latch: PROCESS (BTCNT, BTCCR0_reg, BTCCR1_reg)
    BEGIN
		IF rst_i = '1' THEN
			BTCCR0_q <= X"00000000";
			BTCCR1_q <= X"00000000";
		ELSIF unsigned(BTCNT) = 0 THEN -- only when BTCNT is zreo the ew can pass the data via the latch else it is lock
				BTCCR0_q <= BTCCR0_reg ;
				BTCCR1_q <= BTCCR1_reg ;
		END IF;
	END PROCESS;
	
	
	BTCTL_REG: PROCESS (rst_i, MCLK)
	BEGIN
		IF rst_i = '1' THEN
			BTCTL <= "00100000";
		ELSIF falling_edge(MCLK) THEN
			IF rst_i = '1' THEN
				BTCTL <= "00100000";
			ELSIF (MemWrite_i = '1' AND CURRENT_REG(0) = '1') THEN
				BTCTL <= Din(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;

		
	BTCNT_REG: PROCESS (rst_i, mux_to_clk)
	BEGIN
		IF falling_edge(mux_to_clk) THEN
			IF (rst_i = '1' OR HEU0 = '1') THEN
				BTCNT <= X"00000000";
			ELSIF BTCTL(2) = '1' THEN 
				BTCNT <= X"00000000";
			ELSIF BTCTL(5) = '0'  THEN
				BTCNT <= BTCNT + 1;
			ELSIF BTCTL(5) = '1' AND (MemWrite_i = '1' AND CURRENT_REG(1) = '1') THEN
				BTCNT <= Din;
			END IF;
		END IF;
	END PROCESS;
	
	BTIFG <= HEU0      WHEN BTCTL(1 DOWNTO 0) = "00" ELSE
		     BTCNT(23) WHEN BTCTL(1 DOWNTO 0) = "01" ELSE
			 BTCNT(27) WHEN BTCTL(1 DOWNTO 0) = "10" ELSE
			 BTCNT(31) WHEN BTCTL(1 DOWNTO 0) = "11" ELSE
			 HEU0;

	-- OUTPUT unit (pwm) --
	OUTPUT_UNIT_PROCESS: process(rst_i, mux_to_clk)
    begin
	IF falling_edge(mux_to_clk) THEN
        if rst_i = '1' then
            output_unit <= '0';
        else
			IF BTCTL(6) = '1'	THEN
				if unsigned(BTCCR1_q) < unsigned(BTCCR0_q) then
					case BTCTL(7) is
						when '0' =>
							if (unsigned(BTCCR1_q) <= unsigned(BTCNT)-1) and 
							   (unsigned(BTCNT) <= unsigned(BTCCR0_q)) then
								output_unit <= '1';
							else
								output_unit <= '0';
							end if;
						when '1' =>
							if (unsigned(BTCCR1_q) <= unsigned(BTCNT)-1) and 
							   (unsigned(BTCNT) <= unsigned(BTCCR0_q)) then
								output_unit <= '0';
							else
								output_unit <= '1';
							end if;
						when others =>
							output_unit <= '0';
					end case;
				else
					output_unit <= '0';
				end if;
			END IF;
        end if;
		IF unsigned(BTCCR0_q) = unsigned(BTCNT) THEN
			HEU0 <= '1' ;
		ELSE 
			HEU0 <= '0';
		END IF;
	END IF;
    end process;
	
	PWM_out <= output_unit; -- connect to the output
	
	
	-- clock divider --
	MCLK_Divider1: PROCESS (rst_i, MCLK)
	BEGIN
		IF rst_i = '1' THEN
			MCLK2 <= '0';
		ELSIF rising_edge(MCLK) THEN
			MCLK2 <= NOT MCLK2;
		END IF;
	END PROCESS;
	
	MCLK_Divider2: PROCESS (rst_i, MCLK2)
	BEGIN
		IF rst_i = '1' THEN
			MCLK4 <= '0';
		ELSIF rising_edge(MCLK2) THEN
			MCLK4 <= NOT MCLK4;
		END IF;
	END PROCESS;
	
	MCLK_Divider3: PROCESS (rst_i, MCLK4)
	BEGIN
		IF rst_i = '1' THEN
			MCLK8 <= '0';
		ELSIF rising_edge(MCLK4) THEN
			MCLK8 <= NOT MCLK8;
		END IF;
	END PROCESS;
	
END behavior;

