LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY  InterruptController IS
	PORT(	clock	 		: IN 	STD_LOGIC;
			Reset		 	: IN 	STD_LOGIC; -- reset from tb
			address		 	: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ); 
			DataBus		 	: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead	 		: IN 	STD_LOGIC;
			MemWrite	 	: IN 	STD_LOGIC;
			IR	 			: IN 	STD_LOGIC_VECTOR(8 DOWNTO 0);
			GIE	 			: IN 	STD_LOGIC;
			DIN_FOR_DEBUG   : OUT    STD_LOGIC_VECTOR(8 DOWNTO 0);
			INTA	 		: IN 	STD_LOGIC;
			INTR		 	: OUT 	STD_LOGIC );
			
END InterruptController;

ARCHITECTURE behavior OF InterruptController IS

	SIGNAL irq, clr_irq									: STD_LOGIC_VECTOR( 8 DOWNTO 0 );
	SIGNAL IE_out										: STD_LOGIC_VECTOR( 6 DOWNTO 0 );
	SIGNAL TYPE_in, TYPE_out							: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL IFG_in, IFG_out								: STD_LOGIC_VECTOR( 8 DOWNTO 0 );
	SIGNAL CS											: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL rst											: STD_LOGIC;
	SIGNAL Dout, Din									: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL en											: STD_LOGIC;
	SIGNAL prev_IR 										: STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL IFG_RESET_IN :STD_LOGIC;
	SIGNAL IFG_RESET_OUT :STD_LOGIC;
	SIGNAL clr_rst :STD_LOGIC;
	SIGNAL reset_in :STD_LOGIC;
	signal prev_rst :STD_LOGIC;
	

	
			-- preserve them for SignalTap
attribute keep : boolean;
attribute keep of TYPE_in : signal is true;
attribute keep of IFG_RESET_IN : signal is true;


BEGIN



	IC2BUS :BidirPin generic map(width => 32) port map(Dout => Dout, en => en, Din => Din, IOpin => DataBUS);
	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	INTR <= ((IFG_out(0) OR IFG_out(1) OR IFG_out(2) OR IFG_out(3) OR IFG_out(4) OR IFG_out(5) OR IFG_out(6) OR IFG_out(7) OR IFG_out(8) OR IFG_RESET_OUT) AND GIE) ; --(1.2) telling the CPU “I have a pending interrupt.”
	-- The CPU detect INTR = 1 and change INTA = 0, the CPU acknowledges the interrupt and ready to know what is the interrupt type.
	
	rst <= Reset; -- local register reset in the start of the system or when key0 is pressed
	DIN_FOR_DEBUG <= Din(8 DOWNTO 0);
	WITH address SELECT
	CS <= "001" WHEN "11000000", -- IE Address
		  "010" WHEN "11000001", -- IFG Address
		  "100" WHEN "11000010", -- TYPE Address
		  "000" WHEN OTHERS;
		  
	en <= '1' WHEN (INTA = '0' OR (CS(2) = '1' AND MemRead = '1')) OR (CS(1) = '1' AND MemRead = '1') OR (CS(0) = '1' AND MemRead = '1') ELSE '0';
	
	Dout <= X"000000" & TYPE_out 		WHEN (INTA = '0' OR (CS(2) = '1' AND MemRead = '1')) ELSE --(2.2) IntA received or read from TYPE 
			X"00000" & "000" & IFG_out 	WHEN (CS(1) = '1' AND MemRead = '1') ELSE -- read from IFG
			X"000000" & "0" & IE_out 	WHEN (CS(0) = '1' AND MemRead = '1') ELSE -- read from IE
			(OTHERS => '0');

	-- PROCESS(rst, IFG_out,reset_out,clock)
		-- BEGIN
		-- IF rst = '1' THEN 
			-- TYPE_in <= "00000000";
		-- ELSIF rising_edge(clock) THEN
		-- TYPE_in(7 DOWNTO 6) <= "00";															--|--
		-- TYPE_in(5 DOWNTO 2) <= "0000" WHEN reset_out  = '1' ELSE -- KEY0						--|--
						   -- "0001" WHEN IFG_out(7) = '1' ELSE -- RX status error				--|--
						   -- "0010" WHEN IFG_out(0) = '1' ELSE -- RX						  --(1.3)-- prepare TYPE_in for TYPE_out before INTA = 0  change
						   -- "0011" WHEN IFG_out(1) = '1' ELSE -- TX							--|--
						   -- "0100" WHEN IFG_out(2) = '1' ELSE -- BT 							--|--
						   -- "0101" WHEN IFG_out(3) = '1' ELSE -- KEY1						--|--
						   -- "0110" WHEN IFG_out(4) = '1' ELSE -- KEY2
						   -- "0111" WHEN IFG_out(5) = '1' ELSE -- KEY3
						   -- "1000" WHEN IFG_out(6) = '1' ELSE -- FIFOEMPTY
						   -- "1001" WHEN IFG_out(8) = '1' ELSE -- FIROUT
						   -- "0000";
			-- TYPE_in(1 DOWNTO 0) <= "00";
		-- END IF;
	-- END PROCESS;	
	
		TYPE_in(7 DOWNTO 6) <= "00";															--|--
		TYPE_in(5 DOWNTO 2) <= "0000" WHEN IFG_RESET_OUT  = '1' ELSE -- KEY0						--|--
						   "0001" WHEN IFG_out(7) = '1' ELSE -- RX status error				--|--
						   "0010" WHEN IFG_out(0) = '1' ELSE -- RX						  --(1.3)-- prepare TYPE_in for TYPE_out before INTA = 0  change
						   "0011" WHEN IFG_out(1) = '1' ELSE -- TX							--|--
						   "0100" WHEN IFG_out(2) = '1' ELSE -- BT 							--|--
						   "0101" WHEN IFG_out(3) = '1' ELSE -- KEY1						--|--
						   "0110" WHEN IFG_out(4) = '1' ELSE -- KEY2
						   "0111" WHEN IFG_out(5) = '1' ELSE -- KEY3
						   "1000" WHEN IFG_out(6) = '1' ELSE -- FIFOEMPTY
						   "1001" WHEN IFG_out(8) = '1' ELSE -- FIROUT
						   "0000";
			TYPE_in(1 DOWNTO 0) <= "00";
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	--- (2.0) after we get acknowledge from the MCU we clear the the bit we turn on in the IFG.
	clr_rst	   <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0000" AND INTA = '0') ELSE '0';
	clr_irq(7) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0001" AND INTA = '0') ELSE '0';
	clr_irq(0) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0010" AND INTA = '0') ELSE '0';
	clr_irq(1) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0011" AND INTA = '0') ELSE '0';
	clr_irq(2) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0100" AND INTA = '0') ELSE '0';
	clr_irq(3) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0101" AND INTA = '0') ELSE '0';
	clr_irq(4) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0110" AND INTA = '0') ELSE '0';
	clr_irq(5) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "0111" AND INTA = '0') ELSE '0';
	clr_irq(6) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "1000" AND INTA = '0') ELSE '0';
	clr_irq(8) <= '1' WHEN (TYPE_out(5 DOWNTO 2) = "1001" AND INTA = '0') ELSE '0';
	
	--IFG_in <= irq AND IE_out; -- (1.1) update the IFG for sending it to MCU
	
		-- PROCESS(rst,irq,IE_out,clock)
		-- BEGIN
		-- IF rst = '1' THEN 
			-- IFG_in <= "000000000";
		-- ELSIF rising_edge(clock) THEN
	-- IFG_in(7) <= '1' WHEN (irq(7) = '1' AND IE_out(0) = '1') ELSE '0';
	-- IFG_in(0) <= '1' WHEN (irq(0) = '1' AND IE_out(0) = '1') ELSE '0';
	-- IFG_in(1) <= '1' WHEN (irq(1) = '1' AND IE_out(1) = '1') ELSE '0';
	-- IFG_in(2) <= '1' WHEN (irq(2) = '1' AND IE_out(2) = '1') ELSE '0';
	-- IFG_in(3) <= '1' WHEN (irq(3) = '1' AND IE_out(3) = '1') ELSE '0';
	-- IFG_in(4) <= '1' WHEN (irq(4) = '1' AND IE_out(4) = '1') ELSE '0';
	-- IFG_in(5) <= '1' WHEN (irq(5) = '1' AND IE_out(5) = '1') ELSE '0';
	-- IFG_in(6) <= '1' WHEN (irq(6) = '1' AND IE_out(6) = '1') ELSE '0';
	-- IFG_in(8) <= '1' WHEN (irq(8) = '1' AND IE_out(6) = '1') ELSE '0';
		-- END IF;
	-- END PROCESS;	
	IFG_RESET_IN <= '1' WHEN reset_in = '1' ELSE '0';
	IFG_in(7) <= '1' WHEN (irq(7) = '1' AND IE_out(0) = '1') ELSE '0';
	IFG_in(0) <= '1' WHEN (irq(0) = '1' AND IE_out(0) = '1') ELSE '0';
	IFG_in(1) <= '1' WHEN (irq(1) = '1' AND IE_out(1) = '1') ELSE '0';
	IFG_in(2) <= '1' WHEN (irq(2) = '1' AND IE_out(2) = '1') ELSE '0';
	IFG_in(3) <= '1' WHEN (irq(3) = '1' AND IE_out(3) = '1') ELSE '0';
	IFG_in(4) <= '1' WHEN (irq(4) = '1' AND IE_out(4) = '1') ELSE '0';
	IFG_in(5) <= '1' WHEN (irq(5) = '1' AND IE_out(5) = '1') ELSE '0';
	IFG_in(6) <= '1' WHEN (irq(6) = '1' AND IE_out(6) = '1') ELSE '0';
	IFG_in(8) <= '1' WHEN (irq(8) = '1' AND IE_out(6) = '1') ELSE '0';
	------------------------------------------------------------------------------------------------------------------------------------------------------
	
	-- PROCESS(rst, clr_rst) -- KEY0
		-- BEGIN
			-- IF clr_rst = '1' THEN
				-- reset_in <= '0';
			-- ELSIF rising_edge(rst) THEN
				-- reset_in <= '1';
			-- END IF;
	-- END PROCESS;
	
	
	
 PROCESS(clock) -- KEY0
BEGIN
    IF rising_edge(clock) THEN
            -- Clear irq if requested
            IF clr_rst = '1' THEN
               reset_in <= '0';
            -- Rising edge detection
            ELSIF rst = '1' AND prev_rst = '0' THEN
                reset_in <= '1';
            END IF;
            -- Update previous IR sample
            prev_rst <= rst;
    END IF;
END PROCESS;
	
-- Synchronous edge detection for IRQ signals only
IRQ_PROC: PROCESS(clock, rst)
    -- previous IR values for edge detection

BEGIN
    -- IF rst = '1' THEN
        -- irq     <= (others => '0');
        -- prev_IR <= (others => '0');
    IF rising_edge(clock) THEN
        FOR i IN 0 TO 8 LOOP
            -- Clear irq if requested
            IF clr_irq(i) = '1' THEN
                irq(i) <= '0';
            -- Rising edge detection
            ELSIF IR(i) = '1' AND prev_IR(i) = '0' THEN
                irq(i) <= '1';
            END IF;
            -- Update previous IR sample
            prev_IR(i) <= IR(i);
        END LOOP;
    END IF;
END PROCESS;


	

	
	-- PROCESS( IR(7),rst, clr_irq(7)) -- RX Status Register
	-- BEGIN
		-- IF rst = '1' THEN
			-- irq(7) <= '0';
		-- ELSIF clr_irq(7) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
			   -- irq(7) <= '0';
		-- ELSIF  rising_edge(IR(7)) THEN  -- (1.0) getting interrupt from UART status Register
			   -- irq(7) <= '1';
		-- END IF;
	-- END PROCESS;
	
	
	-- PROCESS(IR(0),rst, clr_irq(0)) -- RX
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(0) <= '0';
			-- ELSIF clr_irq(0) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(0) <= '0';
			-- ELSIF  rising_edge(IR(0) ) THEN -- (1.0) getting interrupt from UART RX
				   -- irq(0) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS(IR(1),rst, clr_irq(1)) -- TX
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(1) <= '0';
			-- ELSIF clr_irq(1) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(1) <= '0';
			-- ELSIF  rising_edge( IR(1) ) THEN -- (1.0) getting interrupt from UART TX
				   -- irq(1) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS(IR(2),rst, clr_irq(2)) -- BT
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(2) <= '0';
			-- ELSIF clr_irq(2) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(2) <= '0';
			-- ELSIF  rising_edge( IR(2) ) THEN -- (1.0) getting interrupt from BT
				   -- irq(2) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS( IR(3),rst, clr_irq(3)) -- KEY1
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(3) <= '0';
			-- ELSIF clr_irq(3) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(3) <= '0';
			-- ELSIF  rising_edge( IR(3) ) THEN -- (1.0) getting interrupt from KEY1
				   -- irq(3) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS( IR(4),rst, clr_irq(4)) -- KEY2
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(4) <= '0';
			-- ELSIF clr_irq(4) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(4) <= '0';
			-- ELSIF  rising_edge( IR(4) ) THEN -- (1.0) getting interrupt from KEY2
				   -- irq(4) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS( IR(5),rst, clr_irq(5)) -- KEY3
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(5) <= '0';
			-- ELSIF clr_irq(5) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(5) <= '0';
			-- ELSIF  rising_edge( IR(5) ) THEN -- (1.0) getting interrupt from KEY3
				   -- irq(5) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS( IR(6),rst, clr_irq(6)) -- FIFOEMPTY
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(6) <= '0';
			-- ELSIF clr_irq(6) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(6) <= '0';
			-- ELSIF  rising_edge( IR(6) ) THEN -- (1.0) getting interrupt from FIFOEMPTY
				   -- irq(6) <= '1';
			-- END IF;
	-- END PROCESS;
	
	-- PROCESS( IR(8),rst, clr_irq(8)) -- FIROUT
		-- BEGIN
			-- IF rst = '1' THEN
				-- irq(8) <= '0';
			-- ELSIF clr_irq(8) = '1' THEN --(2.1) clear the the bit we turn on in the IFG.
				   -- irq(8) <= '0';
			-- ELSIF  rising_edge( IR(8) ) THEN -- (1.0) getting interrupt from FIROUT
				   -- irq(8) <= '1';
			-- END IF;
	-- END PROCESS;
-----------------
	
	IE_REG: PROCESS (rst, clock) 
	BEGIN
		-- IF rst = '1' THEN
			-- IE_out <= "1111111";
		IF  falling_edge( clock) THEN
			IF (CS(0) = '1' AND MemWrite = '1') THEN
				IE_out(0) <= Din(0);
				IE_out(1) <= Din(1);
				IE_out(2) <= Din(2);
				IE_out(3) <= Din(3);
				IE_out(4) <= Din(4);
				IE_out(5) <= Din(5);
				IE_out(6) <= Din(6);
			END IF;
		END IF;
	END PROCESS;
	
	IFG_REG: PROCESS (rst,clock) 
	BEGIN
		IFG_RESET_OUT <= IFG_RESET_IN;
		-- IF rst = '1' THEN
				 -- IFG_out <= "000000000";
		IF  falling_edge( clock) THEN
			IF (CS(1) = '1' AND MemWrite = '1') THEN 
				IFG_out <= Din(8 DOWNTO 0);
			ELSE 
				IFG_out <= IFG_in; --(1.2) we also updtae the IFG  to be ready whaen INTA will be arrive
			END IF;
		END IF;
	END PROCESS;
	
	TYPE_REG: PROCESS (rst, clock) 
	BEGIN
	--	IF rst = '1' THEN
			--TYPE_out <= X"00";
		IF  falling_edge( clock) THEN
				TYPE_out <= TYPE_in; -- 1.4 update TYPE_out
		END IF;
	END PROCESS;
	
	
END behavior;

