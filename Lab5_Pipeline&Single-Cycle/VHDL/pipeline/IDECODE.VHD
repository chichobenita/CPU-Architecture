---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Idecode module (implements the register file for the MIPS computer
LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;


ENTITY Idecode IS
	generic(
		DATA_BUS_WIDTH : integer := 32
	);
	PORT(	clk_i,rst_i		: IN 	STD_LOGIC;
			Stall_ID        : IN    STD_LOGIC;
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			dtcm_data_rd_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i : IN 	STD_LOGIC;
			MemtoReg_ctrl_i : IN 	STD_LOGIC;
			JAL_ctrl_i		: IN 	STD_LOGIC;
			pc_plus4_WB_i	: IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
			--RegDst_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ForwardA_ID		: IN    STD_LOGIC;
			ForwardB_ID		: IN    STD_LOGIC;
			write_dst_i     : IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
			Branch_FW_i     : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_plus4_i      : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
			read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			Jump_addr_o 	: OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PCBranch_addr_o : OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
			PCSrc_o		 	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			instruction_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			write_data_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

	SIGNAL RF_q					: register_file;
	SIGNAL write_reg_addr_w 	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_reg_data_w		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL rs_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rt_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rd_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL pc_plus4_w           : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL imm_value_w			: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL sign_extend_w        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data1_w			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data2_w			: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
	rs_register_w 			<= instruction_i(25 DOWNTO 21);
   	rt_register_w 			<= instruction_i(20 DOWNTO 16);
   	rd_register_w			<= instruction_i(15 DOWNTO 11);
   	imm_value_w 			<= instruction_i(15 DOWNTO 0);
	pc_plus4_w              <= pc_plus4_i(7 DOWNTO 0);
	instruction_o           <= instruction_i;
	
         
	
	-- Read Register 1 Operation
	read_data1_w <= RF_q(CONV_INTEGER(rs_register_w)) WHEN ForwardA_ID = '0' ELSE Branch_FW_i;
	read_data1_o <= read_data1_w;
	
	-- Read Register 2 Operation		 
	read_data2_w <= RF_q(CONV_INTEGER(rt_register_w)) WHEN ForwardB_ID = '0' ELSE Branch_FW_i;
	read_data2_o <= read_data2_w;
	
	-- Mux for Register Write Address
	write_reg_addr_w <= write_dst_i;
	
	-- Mux to bypass data memory for Rformat instructions
	write_reg_data_w <=	X"000000" & pc_plus4_WB_i(9 downto 2) WHEN JAL_ctrl_i = '1' ELSE
						alu_result_i(DATA_BUS_WIDTH-1 DOWNTO 0) WHEN (MemtoReg_ctrl_i = '0') ELSE 
						dtcm_data_rd_i;
						
	write_data_o <= write_reg_data_w; -- for forward
	
	-- Sign Extend 16-bits to 32-bits
    sign_extend_w <= 	X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE
						X"FFFF" & imm_value_w;

	--JM/BRANCH ADDR calc
	PCBranch_addr_o <= pc_plus4_i(9 DOWNTO 2) +  Sign_extend_w(7 DOWNTO 0);
	Jump_addr_o	    <= Sign_extend_w(7 DOWNTO 0) WHEN instruction_i(27 DOWNTO 26) = "10" OR instruction_i(27 DOWNTO 26) = "11" ELSE
					   read_data1_w(7 DOWNTO 0); -- jr
	
	sign_extend_o   <= sign_extend_w;
	
	-------------- PCSrc from Read Register Comp -----------------------
	PCSrc_o(1) 	  <= '1' WHEN instruction_i(31 downto 26) = "000010" or instruction_i(31 downto 26) = "000011" or -- JMP OR JAL
		             (instruction_i(31 downto 26) = "000000" and  instruction_i(5 downto 0) = "001000") else    -- JR
				     '0';
					 
	PCSrc_o(0) 	  <= '1' WHEN (((read_data1_w = read_data2_w) AND Stall_ID = '0') and instruction_i(31 downto 26) = "000100") or
                              (((read_data1_w /= read_data2_w) AND Stall_ID = '0') and instruction_i(31 downto 26) = "000101") ELSE
							  '0';
	process(clk_i,rst_i)
	begin
		if (rst_i='1') then
			FOR i IN 0 TO 31 LOOP
				-- RF_q(i) <= CONV_STD_LOGIC_VECTOR(i,32);
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(0,32);
			END LOOP;
		elsif (clk_i'event and clk_i='0') then
			if (RegWrite_ctrl_i = '1' AND write_reg_addr_w /= 0) then
				RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_w;
				-- index is integer type so we must use conv_integer for type casting
			end if;
		end if;
end process;

END behavior;





