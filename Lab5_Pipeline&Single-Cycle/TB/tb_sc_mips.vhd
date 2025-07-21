---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS_tb IS
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
END MIPS_tb ;


ARCHITECTURE struct OF MIPS_tb IS
   -- Internal signal declarations
   SIGNAL rst_tb_i           	:   STD_LOGIC;
   SIGNAL clk_tb_i           	:   STD_LOGIC;
   SIGNAL BPADDR_i_tb			:   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
   SIGNAL STCNT_o_tb			:   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
   SIGNAL FHCNT_o_tb		    :   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
   SIGNAL STRIGGER_o_tb	        :   STD_LOGIC;			
   SIGNAL CLKCNT_o_tb			:	STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
   SIGNAL inst_cnt_o_tb 	    :	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	-- Output important signals to pins for easy display in SignalTap
   SIGNAL IFpc_o_tb				:	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
   SIGNAL IDpc_o_tb				:	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
   SIGNAL EXpc_o_tb				:	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
   SIGNAL MEMpc_o_tb			:	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
   SIGNAL WBpc_o_tb				:	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
   SIGNAL IFinstruction_o_tb    :	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
   SIGNAL IDinstruction_o_tb    :	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
   SIGNAL EXinstruction_o_tb    :	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
   SIGNAL MEMinstruction_o_tb	:	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
   SIGNAL WBinstruction_o_tb    :	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
   SIGNAL mclk_cnt_tb_o_tb	    :   STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
   SIGNAL inst_cnt_tb_o_tb 		:   STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
   
BEGIN
	CORE : MIPS
	generic map(
		WORD_GRANULARITY 			=> WORD_GRANULARITY,
	    MODELSIM 					=> MODELSIM,
		DATA_BUS_WIDTH				=> DATA_BUS_WIDTH,
		ITCM_ADDR_WIDTH				=> ITCM_ADDR_WIDTH,
		DTCM_ADDR_WIDTH				=> DTCM_ADDR_WIDTH,
		PC_WIDTH					=> PC_WIDTH,
		FUNCT_WIDTH					=> FUNCT_WIDTH,
		DATA_WORDS_NUM				=> DATA_WORDS_NUM,
		CLK_CNT_WIDTH				=> CLK_CNT_WIDTH,
		INST_CNT_WIDTH				=> INST_CNT_WIDTH
	)
	PORT MAP (
		rst_i           	=> rst_tb_i,
		clk_i           	=> clk_tb_i,
		BPADDR_i             => "00000000",
		FHCNT_o             => FHCNT_o_tb,
		STCNT_o             => STCNT_o_tb,
		STRIGGER_o          => STRIGGER_o_tb,
		IFpc_o				=> IFpc_o_tb,
		IDpc_o				=> IDpc_o_tb,
		EXpc_o				=> EXpc_o_tb,
		MEMpc_o				=> MEMpc_o_tb,
		WBpc_o				=> WBpc_o_tb,
		IFinstruction_o	    => IFinstruction_o_tb,
		IDinstruction_o	    => IDinstruction_o_tb,
		EXinstruction_o	    => EXinstruction_o_tb,
		MEMinstruction_o	=> MEMinstruction_o_tb,
		WBinstruction_o	    => WBinstruction_o_tb,
		CLKCNT_o		   	=> mclk_cnt_tb_o_tb,
		inst_cnt_o			=> inst_cnt_tb_o_tb
	);	
--------------------------------------------------------------------	
	gen_clk : 
	process
        begin
		  clk_tb_i <= '1';
		  wait for 50 ns;
		  clk_tb_i <= not clk_tb_i;
		  wait for 50 ns;
    end process;
	
	gen_rst : 
	process
        begin
		  rst_tb_i <='1','0' after 80 ns;
		  wait;
    end process;
--------------------------------------------------------------------		
END struct;
