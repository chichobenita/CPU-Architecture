LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;

ENTITY GPIO IS
	PORT(				
			Data_Bus		 				: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock		 					: IN 	STD_LOGIC;
			Reset		 					: IN 	STD_LOGIC;
			address		 					: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
			MemRead 						: IN 	STD_LOGIC;
			MemWrite 						: IN 	STD_LOGIC;
			A0              				: IN 	STD_LOGIC;
			Input_SW						: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );	 -- SW
			Output_LEDR						: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );	 -- LEDR
			Output_HEX0						: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );  -- HEX0
			Output_HEX1						: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );  -- HEX1
			Output_HEX2						: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );  -- HEX2
			Output_HEX3						: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );  -- HEX3
			Output_HEX4						: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );  -- HEX4
			Output_HEX5 					: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));  -- HEX5
END GPIO;

ARCHITECTURE behavior OF GPIO IS

			SIGNAL EN_SW_read,en									: STD_LOGIC;	-- SW input tristate enable
			SIGNAL EN_LEDR, EN_HEX0, EN_HEX1				    : STD_LOGIC;	-- LED/HEX output enable
			SIGNAL EN_HEX2, EN_HEX3, EN_HEX4, EN_HEX5	: STD_LOGIC;	-- LED/HEX output enable
			SIGNAL CS			 								: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			SIGNAL Dout, Din									: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			SIGNAL SW_REG 									    : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			SIGNAL LDR_REG  									: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			SIGNAL HEX0_REG,HEX1_REG,HEX2_REG,HEX3_REG,HEX4_REG,HEX5_REG	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL EN_LEDR_read, EN_HEX0_read, EN_HEX1_read				    : STD_LOGIC;	-- LED/HEX input enable
			SIGNAL EN_HEX2_read, EN_HEX3_read, EN_HEX4_read, EN_HEX5_read	: STD_LOGIC;	-- LED/HEX intput enable
			SIGNAL mux_to_Dout            						: STD_LOGIC_VECTOR( 7 DOWNTO 0 ); 
			SIGNAL prev_address 								: STD_LOGIC_VECTOR(7 DOWNTO 0);


			-- preserve them for SignalTap
attribute keep : boolean;
attribute keep of Dout : signal is true;
attribute keep of Din  : signal is true;
attribute keep of CS   : signal is true;


BEGIN

	prev_address_reg: PROCESS(clock, Reset)
    BEGIN
		IF Reset = '1' THEN
			prev_address <= (others => '0');
		ELSIF rising_edge(clock) THEN
			prev_address <= address;
		END IF;
	END PROCESS;

--		address  is address(11) & address(6 DOWNTO 0) 
	WITH address(7 DOWNTO 1) SELECT
	CS <= "00001" WHEN "1000000",	-- 0x800				- LEDR		- CS(0)
		  "00010" WHEN "1000010",	-- 0x804 or 0x805		- HEX0/1	- CS(1)	
		  "00100" WHEN "1000100",	-- 0x808 or 0x809		- HEX2/3	- CS(2)
		  "01000" WHEN "1000110",	-- 0x80C or 0x80D		- HEX4/5	- CS(3) 
		  "10000" WHEN "1001000",	-- 0x810				- SW		- CS(4) 
		  "00000" WHEN OTHERS;

------------------------------------read data section------------------------------
	
	
	
	
	
	-- enable to write to mux_to_Dout ----
	EN_SW_read 	    <= '1' WHEN MemRead = '1' AND CS(4) = '1' ELSE '0';	-- SW input tristate enable
	EN_LEDR_read 	<= '1' WHEN MemRead = '1' AND CS(0) = '1'ELSE '0';				-- Enable LEDR 
	EN_HEX0_read 	<= '1' WHEN MemRead = '1' AND CS(1) = '1' AND A0 = '0' ELSE '0';	-- Enable HEX0 
	EN_HEX1_read 	<= '1' WHEN MemRead = '1' AND CS(1) = '1' AND A0 = '1' ELSE '0';	-- Enable HEX1 
	EN_HEX2_read 	<= '1' WHEN MemRead = '1' AND CS(2) = '1' AND A0 = '0' ELSE '0';	-- Enable HEX2 
	EN_HEX3_read 	<= '1' WHEN MemRead = '1' AND CS(2) = '1' AND A0 = '1' ELSE '0';	-- Enable HEX3 
	EN_HEX4_read 	<= '1' WHEN MemRead = '1' AND CS(3) = '1' AND A0 = '0' ELSE '0';	-- Enable HEX4 
	EN_HEX5_read 	<= '1' WHEN MemRead = '1' AND CS(3) = '1' AND A0 = '1' ELSE '0';	-- Enable HEX5 
	
	
	-- enable to databus ----
	en <= MemRead AND (CS(0) OR CS(1) OR CS(2) OR CS(3) OR CS(4));
	
	
	
 	-- write to data bus from latch ---
	mux_to_Dout <=		HEX0_REG when EN_HEX0_read = '1' ELSE
						HEX1_REG when EN_HEX1_read = '1' ELSE
						HEX2_REG when EN_HEX2_read = '1' ELSE
						HEX3_REG when EN_HEX3_read = '1' ELSE
						HEX4_REG when EN_HEX4_read = '1' ELSE
						HEX5_REG when EN_HEX5_read = '1' ELSE
						mux_to_Dout;
						
						
   Dout(31 DOWNTO 10) <= (OTHERS => '0');
   
   Dout(9 DOWNTO 0)   <= SW_REG   when EN_SW_read = '1'else
						 LDR_REG  when EN_LEDR_read = '1' ELSE
						 "00" & mux_to_Dout;
						

	GPIO2BUS: BidirPin generic map(width => 32) port map(Dout => Dout, en => en, Din => Din, IOpin => Data_Bus);
------------------------------------------------------------------------------------------------
--------------------------------enable to latches------------------------------
	EN_LEDR <= '1' WHEN (MemWrite = '1' AND CS(0) = '1'  and (not(prev_address = "10000000" and address /= "10000000"))) ELSE '0';				-- Enable LEDR 
	EN_HEX0 <= '1' WHEN MemWrite = '1' AND CS(1) = '1' AND A0 = '0' ELSE '0';	-- Enable HEX0 
	EN_HEX1 <= '1' WHEN MemWrite = '1' AND CS(1) = '1' AND A0 = '1' ELSE '0';	-- Enable HEX1 
	EN_HEX2 <= '1' WHEN MemWrite = '1' AND CS(2) = '1' AND A0 = '0' ELSE '0';	-- Enable HEX2 
	EN_HEX3 <= '1' WHEN MemWrite = '1' AND CS(2) = '1' AND A0 = '1' ELSE '0';	-- Enable HEX3 
	EN_HEX4 <= '1' WHEN MemWrite = '1' AND CS(3) = '1' AND A0 = '0' ELSE '0';	-- Enable HEX4 
	EN_HEX5 <= '1' WHEN MemWrite = '1' AND CS(3) = '1' AND A0 = '1' ELSE '0';	-- Enable HEX5 

	

-----------------------------------------registers write------------------------------------------------------
	SW_REG_PROCESS: PROCESS(Reset,clock)
	BEGIN
		IF Reset = '1' THEN
			SW_REG  <= "0000000000";
		ELSIF rising_edge(clock) THEN
			SW_REG  <= Input_SW;	
		END IF;
	END PROCESS;

	-- LDR_REG_PROCESS: PROCESS(Reset,clock,EN_LEDR)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- LDR_REG <= "0000000000";
		-- ELSIF falling_edge(clock) THEN
			-- IF EN_LEDR = '1' THEN
			-- LDR_REG <= Din(9 DOWNTO 0);
			-- END IF;
		-- END IF;
	-- END PROCESS;
	
	-- HEX0_REG_PROCESS: PROCESS(Reset,clock,EN_HEX0)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- HEX0_REG <= X"00";
		-- ELSIF falling_edge(clock) THEN
			-- IF EN_HEX0 = '1' THEN
			-- HEX0_REG <= Din(7 DOWNTO 0);
			-- END IF;
		-- END IF;
	-- END PROCESS;
	
	-- HEX1_REG_PROCESS: PROCESS(Reset,clock,EN_HEX1)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- HEX1_REG <= X"00";
		-- ELSIF falling_edge(clock) THEN
			-- IF EN_HEX1 = '1' THEN
			-- HEX1_REG <= Din(7 DOWNTO 0);
			-- END IF;
		-- END IF;
	-- END PROCESS;
	
	-- HEX2_REG_PROCESS: PROCESS(Reset,clock,EN_HEX2)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- HEX2_REG <= X"00";
		-- ELSIF falling_edge(clock) THEN
			-- IF EN_HEX2 = '1' THEN
			-- HEX2_REG <= Din(7 DOWNTO 0);
			-- END IF;
		-- END IF;
	-- END PROCESS;
	
	-- HEX3_REG_PROCESS: PROCESS(Reset,clock,EN_HEX3)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- HEX3_REG <= X"00";
		-- ELSIF falling_edge(clock) THEN	
			-- IF EN_HEX3 = '1' THEN
			-- HEX3_REG <= Din(7 DOWNTO 0);
			-- END IF;			
		-- END IF;
	-- END PROCESS;
	
	-- HEX4_REG_PROCESS: PROCESS(Reset,clock,EN_HEX4)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- HEX4_REG <= X"00";
		-- ELSIF falling_edge(clock) THEN
			-- IF EN_HEX4 = '1' THEN
			-- HEX4_REG <= Din(7 DOWNTO 0);	
			-- END IF;
		-- END IF;
	-- END PROCESS;
	
	-- HEX5_REG_PROCESS: PROCESS(Reset,clock,EN_HEX5)
	-- BEGIN
		-- IF Reset = '1' THEN
			-- HEX5_REG <= X"00";
		-- ELSIF falling_edge(clock) THEN
			-- IF EN_HEX5 = '1' THEN
			-- HEX5_REG <= Din(7 DOWNTO 0);	
			-- END IF;
		-- END IF;
	-- END PROCESS;


	PROCESS(Reset, clock,EN_LEDR,EN_HEX0,EN_HEX1,EN_HEX2,EN_HEX3,EN_HEX4,EN_HEX5)
	BEGIN
		IF Reset = '1' THEN
			LDR_REG <= "0000000000";
			HEX0_REG <= X"00";
			HEX1_REG <= X"00";
			HEX2_REG <= X"00";
			HEX3_REG <= X"00";
			HEX4_REG <= X"00";
			HEX5_REG <= X"00";
		ELSIF falling_edge(clock) THEN 	
			IF    (EN_LEDR = '1') THEN
				LDR_REG <= Din(9 DOWNTO 0);
			ELSIF (EN_HEX0 = '1') THEN
				HEX0_REG <= Din(7 DOWNTO 0);
			ELSIF (EN_HEX1 = '1') THEN
				HEX1_REG <= Din(7 DOWNTO 0);
			ELSIF (EN_HEX2 = '1') THEN
				HEX2_REG <= Din(7 DOWNTO 0);
			ELSIF (EN_HEX3 = '1') THEN
				HEX3_REG <= Din(7 DOWNTO 0);
			ELSIF (EN_HEX4 = '1') THEN
				HEX4_REG <= Din(7 DOWNTO 0);
			ELSIF (EN_HEX5 = '1') THEN
				HEX5_REG <= Din(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	Output_LEDR <= LDR_REG;
	Output_HEX0 <= HEX0_REG;
	Output_HEX1	<= HEX1_REG;
	Output_HEX2 <= HEX2_REG;
	Output_HEX3 <= HEX3_REG;
	Output_HEX4 <= HEX4_REG;
	Output_HEX5 <= HEX5_REG;
	
END behavior;

