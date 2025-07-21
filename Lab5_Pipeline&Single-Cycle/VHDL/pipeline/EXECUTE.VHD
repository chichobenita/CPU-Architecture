---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.aux_package.all;


ENTITY  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	clk_i, rst_i    : IN    STD_LOGIC;
			read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegDst_ctrl_i   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
			Wr_data_FW_WB_i : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			Wr_data_FW_MEM_i: IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			ForwardA_i      : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
			ForwardB_i      : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
			Wr_reg_addr_o   : OUT   STD_LOGIC_VECTOR(4 DOWNTO 0);
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			WriteData_o     : OUT   STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
			---addr_res_o 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );

	);
END Execute;


ARCHITECTURE behavior OF Execute IS
SIGNAL a_input_w, b_input_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL Bforward_mux    		 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_out_mux_w			: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL branch_addr_r 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL alu_ctl_w, alu_ctl_w1, alu_ctl_w2		: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Shifter_out              : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL is_shift                 : STD_LOGIC;
SIGNAL alu_res_o_TO_MUX         : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

BEGIN

---Forward A 
	WITH ForwardA_i SELECT 
			a_input_w    <= read_data1_i    WHEN "00",
							Wr_data_FW_WB_i  WHEN "01",
							Wr_data_FW_MEM_i WHEN "10",
							X"00000000"	   WHEN OTHERS;
---Forward B
	WITH ForwardB_i SELECT 
			Bforward_mux <= read_data2_i   WHEN "00",
							Wr_data_FW_WB_i  WHEN "01",
							Wr_data_FW_MEM_i WHEN "10",
							X"00000000"	   WHEN OTHERS;
							

	-- ALU input mux
	b_input_w <= 	Bforward_mux WHEN (ALUSrc_ctrl_i = '0' AND funct_i /= "001000") ELSE
					X"00000000"  WHEN (ALUSrc_ctrl_i = '0' AND funct_i = "001000")  ELSE
					sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0);
					
	WriteData_o <= Bforward_mux;
	
	Shifter_lab1 : Shifter generic map (32,5) PORT MAP(sign_extend_i(10 DOWNTO 6) , a_input_w, funct_i(1),Shifter_out); 
--------------------------------------------------------------------------------------------------------
--  Generate ALU control bits
--------------------------------------------------------------------------------------------------------
	is_shift <= '1' WHEN (((funct_i = "000000") or (funct_i = "000010")) AND (ALUOp_ctrl_i(2) = '0')) ELSE '0';--need to check


--011
	-- no I type --
	alu_ctl_w1(0) <= (NOT(is_shift) AND ((funct_i(0) OR funct_i(3)) AND ALUOp_ctrl_i(1)))                    OR is_shift; 
	alu_ctl_w1(1) <= (NOT(is_shift) AND ((not ALUOp_ctrl_i(1)) or (not funct_i(2) and not ALUOp_ctrl_i(0)))) OR '0'; 
	alu_ctl_w1(2) <= (NOT(is_shift) AND ((not ALUOp_ctrl_i(1) and ALUOp_ctrl_i(0)) or (funct_i(1))))         OR is_shift; 
	alu_ctl_w1(3) <= (NOT(is_shift) AND ((funct_i(1) and ALUOp_ctrl_i(2))))                                  OR '0'; 
	
	
	
	-- I type --
	alu_ctl_w2(0) <= ALUOp_ctrl_i(0);
	alu_ctl_w2(1) <= ALUOp_ctrl_i(1);
	alu_ctl_w2(2) <= ALUOp_ctrl_i(2);
	alu_ctl_w2(3) <= '1';
	
	alu_ctl_w <= alu_ctl_w2 when ALUSrc_ctrl_i = '1' ELSE alu_ctl_w1;
	
	
--------------------------------------------------------------------------------------------------------
	
	-- Generate Zero Flag
	zero_o <= 	'1' WHEN (alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0) = X"00000000") ELSE
				'0';    
	
	-- Select ALU output        
	alu_res_o_TO_MUX <= X"0000000" & B"000"  & alu_out_mux_w(31) WHEN  (alu_ctl_w = "0111" or alu_ctl_w = "1101") ELSE 
					alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0);
					
	alu_res_o <= alu_res_o_TO_MUX;
	
	
	Wr_reg_addr_o <= "11111"			        WHEN RegDst_ctrl_i = "10" ELSE -- jal
				instruction_i(15 DOWNTO 11) 	WHEN RegDst_ctrl_i = "01" ELSE 
				instruction_i(20 DOWNTO 16);
				
				
	-- Adder to compute Branch Address  MOVE TO DECODE
	/*branch_addr_r	<= pc_plus4_i(PC_WIDTH-1 DOWNTO 2) + sign_extend_i(7 DOWNTO 0) ;
	addr_res_o 		<= alu_res_o_TO_MUX(7 DOWNTO 0) WHEN funct_i = "001000"  ELSE
	                   branch_addr_r(7 DOWNTO 0);*/


PROCESS (alu_ctl_w, a_input_w, b_input_w)
	BEGIN		
 	CASE alu_ctl_w IS	-- Select ALU operation
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	alu_out_mux_w 	<= a_input_w AND b_input_w; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	alu_out_mux_w 	<= a_input_w OR b_input_w;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	alu_out_mux_w 	<= a_input_w + b_input_w;
		
		
						-- ALU performs ADDU (MOV)
 	 	WHEN "0011" 	=>	alu_out_mux_w <= unsigned(a_input_w)+ unsigned(b_input_w);
						-- ALU performs XOR
 	 	WHEN "0100" 	=>	alu_out_mux_w 	<= a_input_w xor b_input_w;
						-- ALU performs SHL \ SHR
 	 	WHEN "0101" 	=>	alu_out_mux_w 	<= Shifter_out;
						-- ALU performs ALUresult = A_input -B_input or beq
 	 	WHEN "0110" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w;
						-- ALU performs mult
		WHEN "1110"     =>  alu_out_mux_w    <= a_input_w(15 downto 0) * b_input_w(15 downto 0);
		
		-- iTYPE----------
						-- ALU performs ADDI
  	 	WHEN "1000" 	=>	alu_out_mux_w 	<= a_input_w + b_input_w ;
		
						-- ALU performs ORI
  	 	WHEN "1001" 	=>	alu_out_mux_w 	<= a_input_w OR b_input_w ;
		
						-- ALU performs ANDI
  	 	WHEN "1010" 	=>	alu_out_mux_w 	<= a_input_w AND b_input_w ;
		
						-- ALU performs XORI
  	 	WHEN "1011" 	=>	alu_out_mux_w 	<= a_input_w XOR b_input_w ;
		
						-- ALU performs load upper
		WHEN "1100"     =>  alu_out_mux_w   <= b_input_w(15 DOWNTO 0) & x"0000" ;
		
					    -- ALU performs SLTI		
		WHEN "1101"     =>  alu_out_mux_w   <= a_input_w - b_input_w;
		
 	 	WHEN OTHERS	=>	alu_out_mux_w 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
  
END behavior;

