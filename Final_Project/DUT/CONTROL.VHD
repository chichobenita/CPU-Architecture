---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.const_package.all;


ENTITY control IS
   PORT( 
		CLK_ctrl_i          : IN 	STD_LOGIC;
		RST_ctrl_i          : IN 	STD_LOGIC;
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		INTR_ctrl_i         : IN    STD_LOGIC;
		instruction_ctrl_i  : IN    STD_LOGIC_VECTOR(31 DOWNTO 0); 
		K0_0_ctrl_i         : IN    STD_LOGIC; -- COME FROM IDECODER
		INTA_ctrl_o         : OUT	STD_LOGIC;
		PC_TO_TEMP_ctrl_o   : OUT   STD_LOGIC;
		PC_TO_K1_ctrl_o     : OUT   STD_LOGIC;
		INT_JMP_MUX_ctrl_o  : OUT   STD_LOGIC;
		STATE2_BIT_ctrl_o	: OUT   STD_LOGIC;
		GIE_ctrl_o          : OUT 	STD_LOGIC; -- GO TO INTERRUPT CONTROLLER 
		
		RegDst_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC;
		Jump_ctrl_o         : OUT   STD_LOGIC;
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  rtype_w, rtype_w2, lw_w, sw_w, beq_w, itype_imm_w, bne_w, jmp_w , jal_w,reti_w: STD_LOGIC;
	SIGNAL  INTR_FSM   :STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  i_op       : STD_LOGIC_VECTOR(2 DOWNTO 0 );
	SIGNAL  GIE_MASKER : STD_LOGIC;
	SIGNAL  STATE2_BIT : STD_LOGIC; -- '1' WHEN WE ARE AT STATE 1

	
    type state is (state0,state1,state2,state3); -- 
    SIGNAL cur_state,next_state : state;
BEGIN          

	GIE_ctrl_o 		<= K0_0_ctrl_i AND GIE_MASKER; -- GO TO INTERRUPT CONTROLLER
	INT_JMP_MUX_ctrl_o <= '1' when cur_state = state2 else '0'; --CHOOSE THE INT ADDRESS FROM THE "READ DATA" IN DMEMOREY
	PC_TO_TEMP_ctrl_o  <= '1' when (cur_state = state0 AND INTR_ctrl_i = '1') else '0'; --ENABLE PC+4 TO TEMP REGISTER
	STATE2_BIT 		   <= '1' when cur_state = state2 else '0';
	PC_TO_K1_ctrl_o    <= '1' when cur_state = state2 else '0'; --ENABLE PC+4 TO WRITE REGISTER ADDRESS IN REG FILE
	INTA_ctrl_o 	   <= '1' when RST_ctrl_i ='1' ELSE
						  '0' when (cur_state = state2 )  
								else '1';
	--GIE_MASKER 		   <= '1' when (RST_ctrl_i = '1') OR ((cur_state = state0 AND INTR_ctrl_i = '1') OR cur_state = state3)   else '0';
	
	STATE2_BIT_ctrl_o <= STATE2_BIT;

	reti_w <= '1' when 
				  instruction_ctrl_i(31 downto 26) = "000000" and  -- R-type
				  instruction_ctrl_i(25 downto 21) = "11011" and   -- rs = $k1
				  instruction_ctrl_i(5 downto 0)   = "001000"      -- funct = JR
	              else     '0'; 

	control_unit : process (cur_state, INTR_ctrl_i, reti_w)
	begin
		next_state <= cur_state;  -- default
		case cur_state is
		---------------- state 0 ---------------------
		---- finish current flow and save pc+4 -- 
			when state0 =>
				if INTR_ctrl_i = '1' then
					next_state <= state1;
				end if;
		---------------- state 1 ---------------------
		---- start to load the interrupt rutine address and load to k1 pc+4 from last cycle		--
		-- and to enter jump address to pc
			when state1 =>
					next_state <= state2;
		---------------- state 2 ---------------------
		---- jump to interrupt rutine address and execute --
			when state2 =>
				next_state <= state3;
		---------------- state 3 ---------------------
		---- run the interrupt rutine --
			when state3 =>
				if reti_w = '1' then
					next_state <= state0;
				end if;
		end case;
	end process;
	
	
		state_process : process(CLK_ctrl_i, RST_ctrl_i)
begin 
	IF RST_ctrl_i = '1' then
		cur_state <= state0;
		GIE_MASKER <= '1';

	ELSIF rising_edge(CLK_ctrl_i) THEN
			cur_state <= next_state;
			case cur_state is 
				when state0 =>
					if INTR_ctrl_i = '1' then 
						GIE_MASKER <= '1';
					end if;
				when state1 => 
					GIE_MASKER <= '0';
				--	INTA_ctrl_o <= '0';
				when state2 => 
					GIE_MASKER <= '0';
				--	INTA_ctrl_o <= '1';
				when state3 => 	
					GIE_MASKER <= '1'; 
					--INTA_ctrl_o <= '1';
				when others =>
					GIE_MASKER <= '1';
				--	INTA_ctrl_o <= INTA_ctrl_o;
			END CASE;
	end if;
    end process;

				-- Code to generate control signals using opcode bits 
	rtype_w 			<=  '1'	WHEN	(opcode_i = R_TYPE_OPC  OR opcode_i = MUL_OPC)
										ELSE '0';
	rtype_w2			<=  '1' WHEN	opcode_i = MUL_OPC          ELSE '0';
	lw_w          		<=  '1'	WHEN  	opcode_i = LW_OPC  			ELSE '0';
 	sw_w          		<=  '1'	WHEN  	opcode_i = SW_OPC  			ELSE '0';
   	beq_w         		<=  '1'	WHEN  	opcode_i = BEQ_OPC  		ELSE '0';
	bne_w               <=  '1' WHEN    opcode_i = BNE_OPC          ELSE '0';
	jmp_w               <=  '1' WHEN    opcode_i = JMP_OPC          ELSE '0';
	jal_w               <=  '1' WHEN    opcode_i = JAL_OPC          ELSE '0';
	itype_imm_w			<=	'1'	WHEN	((opcode_i = ADDI_OPC) or 
										( opcode_i = ORI_OPC)  or 
										( opcode_i = ANDI_OPC) or 
										( opcode_i = XORI_OPC) or 
										( opcode_i = LUI_OPC)  or 
										( opcode_i = ADDIU_OPC)or 
										( opcode_i = SLTI_OPC)									
										)		ELSE '0';  	


	
							
  	RegDst_ctrl_o    	<=  jal_w & (rtype_w OR rtype_w2);
 	ALUSrc_ctrl_o  		<=  lw_w OR sw_w or itype_imm_w;
	MemtoReg_ctrl_o 	<=  lw_w;
  	RegWrite_ctrl_o 	<=  rtype_w OR lw_w or itype_imm_w OR rtype_w2 OR jal_w OR PC_TO_K1_ctrl_o;
  	MemRead_ctrl_o 		<=  lw_w OR STATE2_BIT;
   	MemWrite_ctrl_o 	<=  sw_w; 
 	Branch_ctrl_o      	<=  beq_w OR bne_w;
	Jump_ctrl_o         <=  jmp_w OR jal_w;
	i_op                <= "000" WHEN opcode_i = ADDI_OPC or opcode_i = ADDIU_OPC  ELSE
						   "001" WHEN opcode_i = ORI_OPC  ELSE
						   "010" WHEN opcode_i = ANDI_OPC ELSE
						   "011" WHEN opcode_i = XORI_OPC ELSE
						   "100" WHEN opcode_i = LUI_OPC  ELSE
						   "101" WHEN opcode_i = SLTI_OPC ELSE
						
						   "000";
	
	ALUOp_ctrl_o(0) 	<=  beq_w or bne_w or i_op(0);
	ALUOp_ctrl_o(1) 	<=  rtype_w or i_op(1);
	ALUOp_ctrl_o(2)     <=  rtype_w2 OR i_op(2);
	
   END behavior;


