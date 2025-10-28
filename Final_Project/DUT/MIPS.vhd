---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS IS
	generic( 
			WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	        MODELSIM : integer 			:= G_MODELSIM;
			DATA_BUS_WIDTH : integer 	:= 32;
			ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			DTCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			PC_WIDTH : integer 			:= 10;
			FUNCT_WIDTH : integer 		:= 6;
			DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
			CLK_CNT_WIDTH : integer 	:= 16;
			INST_CNT_WIDTH : integer 	:= 16
	);
	PORT(	rst_i		 		:IN	    STD_LOGIC;
			clk_i				:IN	    STD_LOGIC; 
			DATA_BUS_io         :INOUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			ADDRESS_o           :OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
			MemWrite_ctrl_o		:OUT 	STD_LOGIC;
			RegWrite_ctrl_o     :OUT 	STD_LOGIC;
			MemRead_ctrl_o		:OUT 	STD_LOGIC;
			INTR                :IN     STD_LOGIC;
			INTA                :OUT    STD_LOGIC;
			GIE                 :OUT    STD_LOGIC; 
			
			-- Output important signals to pins for easy display in SignalTap
			pc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			alu_result_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data1_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			write_data_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			instruction_top_o	:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			Branch_ctrl_o		:OUT 	STD_LOGIC;
			Zero_o				:OUT 	STD_LOGIC; 
			mclk_cnt_o			:OUT	STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
			inst_cnt_o 			:OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)
	);		
END MIPS;
-------------------------------------------------------------------------------------
ARCHITECTURE structure OF MIPS IS
	-- declare signals used to connect VHDL components
	SIGNAL pc_plus4_w 			: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL read_data1_w 		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data2_w		 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL sign_extend_w 		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL addr_res_w 			: STD_LOGIC_VECTOR(7 DOWNTO 0 );
	SIGNAL alu_result_w 		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL dtcm_data_rd_w 		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL alu_src_w 			: STD_LOGIC;
	SIGNAL branch_w 			: STD_LOGIC;
	SIGNAL reg_dst_w	 		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_write_w 			: STD_LOGIC;
	SIGNAL zero_w 				: STD_LOGIC;
	SIGNAL mem_write_w	 		: STD_LOGIC;
	SIGNAL MemtoReg_w 			: STD_LOGIC;
	SIGNAL mem_read_w 			: STD_LOGIC;
	SIGNAL jmp_w        	    : STD_LOGIC;
	SIGNAL alu_op_w 			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL instruction_w		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL mclk_cnt_q			: STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL inst_cnt_w			: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL write_en_dmemory     : STD_LOGIC;
	SIGNAL DATA_BUS_DMEM_MUX    : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL EN_DATA_BUS_TO_MIPS : STD_LOGIC;
	SIGNAL DIN_DATA_BUS         : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL DTCM_ADDRESS			: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL JUMP_INT_ADDRESS_w     : STD_LOGIC;
	SIGNAL K0_0_w               : STD_LOGIC;
	SIGNAL TEMP_REG_w             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL READ_DATA_MEM_TO_IFE : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_TO_K1_ctrl_w      : STD_LOGIC;
	SIGNAL PC_TO_TEMP_ctrl_w    : STD_LOGIC;
	signal STATE2_BIT_w         : STD_LOGIC;

	

BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   instruction_top_o 	<= 	instruction_w;
   alu_result_o 		<= 	alu_result_w;
   read_data1_o 		<= 	read_data1_w;
   read_data2_o 		<= 	read_data2_w;
   MemRead_ctrl_o       <=  mem_read_w;

   write_data_o  		<= 	DATA_BUS_DMEM_MUX WHEN MemtoReg_w = '1' ELSE 
							alu_result_w;
							
   Branch_ctrl_o 		<= 	branch_w;
   Zero_o 				<= 	zero_w;
   RegWrite_ctrl_o 		<= 	reg_write_w;
   MemWrite_ctrl_o 		<= 	mem_write_w;	
   ADDRESS_o            <=  alu_result_w;
   
   EN_DATA_BUS_TO_MIPS <= '1' WHEN (mem_write_w = '1' AND alu_result_w(11) = '1') ELSE '0';
   
   DATA_BUS_TO_MIPS : BidirPin generic map(width => 32) port map(Dout => read_data2_w, en => EN_DATA_BUS_TO_MIPS
																	, Din => DIN_DATA_BUS, IOpin => DATA_BUS_io );
	-- connect the 5 MIPS components   
	IFE : Ifetch
	generic map(
		WORD_GRANULARITY	=> 	WORD_GRANULARITY,
		DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
		PC_WIDTH			=>	PC_WIDTH,
		ITCM_ADDR_WIDTH		=>	ITCM_ADDR_WIDTH,
		WORDS_NUM			=>	DATA_WORDS_NUM,
		INST_CNT_WIDTH		=>	INST_CNT_WIDTH
	)
	PORT MAP (	
		clk_i 			=> clk_i,  
		rst_i 			=> rst_i, 
		add_result_i 	=> addr_res_w,
		Branch_ctrl_i 	=> branch_w,
		zero_i 			=> zero_w,
		pc_o 			=> pc_o,
		instruction_o 	=> instruction_w,
    	pc_plus4_o	 	=> pc_plus4_w,
		Jump_ctrl_i     => jmp_w,
		inst_cnt_o		=> inst_cnt_w,
		PC_TO_TEMP_ctrl_i  => PC_TO_TEMP_ctrl_w,
		INT_JMP_MUX_ctrl_i => JUMP_INT_ADDRESS_w,
		READ_DATA_MEM_i => dtcm_data_rd_w,
		TEMP_REG_o      => TEMP_REG_w
	);

	ID : Idecode
   	generic map(
		DATA_BUS_WIDTH		=>  DATA_BUS_WIDTH
	)
	PORT MAP (	
			clk_i 				=> clk_i,  
			rst_i 				=> rst_i,
        	instruction_i 		=> instruction_w,
        	dtcm_data_rd_i 		=> DATA_BUS_DMEM_MUX,
			alu_result_i 		=> alu_result_w,
			RegWrite_ctrl_i 	=> reg_write_w,
			MemtoReg_ctrl_i 	=> MemtoReg_w,
			RegDst_ctrl_i 		=> reg_dst_w,
			pc_plus4_i          => pc_plus4_w,
			KO_O_dec_o          => K0_0_w,
			read_data1_o 		=> read_data1_w,
        	read_data2_o 		=> read_data2_w,
			sign_extend_o 		=> sign_extend_w,
			PC_TO_K1_ctrl_i     => PC_TO_K1_ctrl_w,
			REG_TEMP_i          => TEMP_REG_w		
		);

	CTL:   control
	PORT MAP ( 	
			CLK_ctrl_i          => clk_i,
			RST_ctrl_i          => rst_i,
			opcode_i 			=> instruction_w(DATA_BUS_WIDTH-1 DOWNTO 26),
			INTR_ctrl_i   		=> INTR,
			instruction_ctrl_i	=> instruction_w,
			K0_0_ctrl_i         => K0_0_w,
			INTA_ctrl_o         => INTA,
			PC_TO_K1_ctrl_o     => PC_TO_K1_ctrl_w,
			INT_JMP_MUX_ctrl_o  => JUMP_INT_ADDRESS_w,
			GIE_ctrl_o			=> GIE,
			RegDst_ctrl_o 		=> reg_dst_w,
			ALUSrc_ctrl_o 		=> alu_src_w,
			MemtoReg_ctrl_o 	=> MemtoReg_w,
			RegWrite_ctrl_o 	=> reg_write_w,
			MemRead_ctrl_o 		=> mem_read_w,
			MemWrite_ctrl_o 	=> mem_write_w,
			Branch_ctrl_o 		=> branch_w,
			Jump_ctrl_o         => jmp_w,
			PC_TO_TEMP_ctrl_o   => PC_TO_TEMP_ctrl_w,
			STATE2_BIT_ctrl_o   => STATE2_BIT_w,
			ALUOp_ctrl_o 		=> alu_op_w
		);

	EXE:  Execute
   	generic map(
		DATA_BUS_WIDTH 		=> 	DATA_BUS_WIDTH,
		FUNCT_WIDTH 		=>	FUNCT_WIDTH,
		PC_WIDTH 			=>	PC_WIDTH
	)
	PORT MAP (	
		pc_plus4_i		=> pc_plus4_w,
		read_data1_i 	=> read_data1_w,
        read_data2_i 	=> read_data2_w,
		sign_extend_i 	=> sign_extend_w,
        funct_i			=> instruction_w(5 DOWNTO 0),
		ALUOp_ctrl_i 	=> alu_op_w,
		ALUSrc_ctrl_i 	=> alu_src_w,
		zero_o 			=> zero_w,
        alu_res_o		=> alu_result_w,
		addr_res_o 		=> addr_res_w			
	);
    write_en_dmemory <= '1' WHEN (mem_write_w = '1' AND alu_result_w(11) = '0') ELSE
						'0';
	
	DATA_BUS_DMEM_MUX    <=   DIN_DATA_BUS WHEN (MemtoReg_w = '1' AND alu_result_w(11) = '1') ELSE
					          dtcm_data_rd_w;
						
	DTCM_ADDRESS <= DIN_DATA_BUS WHEN (STATE2_BIT_w = '1' ) ELSE alu_result_w;
	G1: 
	if (WORD_GRANULARITY = True) generate -- i.e. each WORD has a unike address
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> clk_i,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> DTCM_ADDRESS((DTCM_ADDR_WIDTH+2)-1 DOWNTO 2), -- increment memory address by 4
				dtcm_data_wr_i 		=> read_data2_w,
				MemRead_ctrl_i 		=> mem_read_w, 
				MemWrite_ctrl_i 	=> write_en_dmemory,
				dtcm_data_rd_o 		=> dtcm_data_rd_w 
			);	
	elsif (WORD_GRANULARITY = False) generate -- i.e. each BYTE has a unike address	
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> clk_i,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> DTCM_ADDRESS(DTCM_ADDR_WIDTH-1 DOWNTO 2)&"00",
				dtcm_data_wr_i 		=> read_data2_w,
				MemRead_ctrl_i 		=> mem_read_w, 
				MemWrite_ctrl_i 	=> write_en_dmemory,
				dtcm_data_rd_o 		=> dtcm_data_rd_w
			);
	end generate;
---------------------------------------------------------------------------------------
--									IPC - MCLK counter register
---------------------------------------------------------------------------------------
process (clk_i , rst_i)
begin
	if rst_i = '1' then
		mclk_cnt_q	<=	(others	=> '0');
	elsif rising_edge(clk_i) then
		mclk_cnt_q	<=	mclk_cnt_q + '1';
	end if;
end process;

mclk_cnt_o	<=	mclk_cnt_q;
inst_cnt_o	<=	inst_cnt_w;
---------------------------------------------------------------------------------------
END structure;

