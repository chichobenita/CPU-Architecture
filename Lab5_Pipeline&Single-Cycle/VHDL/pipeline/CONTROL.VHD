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
USE work.aux_package.ALL;


ENTITY control IS
   PORT( 	
		clk_i 				: IN 	STD_LOGIC;  
		rst_i 				: IN 	STD_LOGIC;
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		RegDst_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC;
		Bne_ctrl_o 		    : OUT 	STD_LOGIC;
		Beq_ctrl_o 		    : OUT 	STD_LOGIC;
		Jump_ctrl_o         : OUT   STD_LOGIC;
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  rtype_w, rtype_w2, lw_w, sw_w, beq_w, itype_imm_w, bne_w, jmp_w , jal_w: STD_LOGIC;
	SIGNAL i_op  : STD_LOGIC_VECTOR(2 DOWNTO 0 );

BEGIN           
				-- Code to generate control signals using opcode bits
	rtype_w 			<=  '1'	WHEN	((opcode_i = R_TYPE_OPC)  OR (opcode_i = MUL_OPC))
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
  	RegWrite_ctrl_o 	<=  rtype_w OR lw_w or itype_imm_w OR rtype_w2 OR jal_w;
  	MemRead_ctrl_o 		<=  lw_w;
   	MemWrite_ctrl_o 	<=  sw_w; 
 	Branch_ctrl_o      	<=  beq_w OR bne_w;
	Jump_ctrl_o         <=  jmp_w OR jal_w;
	Bne_ctrl_o          <=  bne_w;
	Beq_ctrl_o          <=  beq_w;
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


