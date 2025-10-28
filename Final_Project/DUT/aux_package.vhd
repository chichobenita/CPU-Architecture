---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
USE work.cond_comilation_package.all;


package aux_package is

	component MIPS is
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
	end component;
---------------------------------------------------------  
	component control is
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
	end component;
---------------------------------------------------------	
	component dmemory is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		DTCM_ADDR_WIDTH : integer := 8;
		WORDS_NUM : integer := 256
	);
	PORT(	clk_i,rst_i			: IN 	STD_LOGIC;
			dtcm_addr_i 		: IN 	STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
			dtcm_data_wr_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MemRead_ctrl_i  	: IN 	STD_LOGIC;
			MemWrite_ctrl_i 	: IN 	STD_LOGIC;
			dtcm_data_rd_o 		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	end component;
---------------------------------------------------------		
	component Execute is
		generic(
			DATA_BUS_WIDTH : integer := 32;
			FUNCT_WIDTH : integer := 6;
			PC_WIDTH : integer := 10
		);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			addr_res_o 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 )
	);
	end component;
---------------------------------------------------------		
	component Idecode is
		generic(
			DATA_BUS_WIDTH : integer := 32
		);
	
	PORT(	clk_i,rst_i		 : IN 	STD_LOGIC;
			instruction_i 	 : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			dtcm_data_rd_i 	 : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	 : IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i  : IN 	STD_LOGIC;
			MemtoReg_ctrl_i  : IN 	STD_LOGIC;
			RegDst_ctrl_i 	 : IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			pc_plus4_i       : IN   STD_LOGIC_VECTOR(9 DOWNTO 0);
			KO_O_dec_o       : OUT  STD_LOGIC; 
			read_data1_o	 : OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	 : OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 	 : OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			PC_TO_K1_ctrl_i  : IN   STD_LOGIC;
			REG_TEMP_i       : IN   STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	
	end component;
---------------------------------------------------------		
	component Ifetch is
		generic(
			WORD_GRANULARITY : boolean 	:= False;
			DATA_BUS_WIDTH : integer 	:= 32;
			PC_WIDTH : integer 			:= 10;
			NEXT_PC_WIDTH : integer 	:= 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
			ITCM_ADDR_WIDTH : integer 	:= 8;
			WORDS_NUM : integer 		:= 256;
			INST_CNT_WIDTH : integer 	:= 16
		);
	PORT(	
		clk_i, rst_i 	: IN 	STD_LOGIC;
		add_result_i 	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
        Branch_ctrl_i 	: IN 	STD_LOGIC;
		Jump_ctrl_i     : IN    STD_LOGIC;
        zero_i 			: IN 	STD_LOGIC;	
		INT_JMP_MUX_ctrl_i :IN  STD_LOGIC;
		READ_DATA_MEM_i : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
		TEMP_REG_o      : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_o 			: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		pc_plus4_o 		: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		instruction_o 	: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PC_TO_TEMP_ctrl_i: IN   STD_LOGIC;
		inst_cnt_o 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)	
	);
	end component;
---------------------------------------------------------
	COMPONENT PLL port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	
    COMPONENT shifter is
    generic (
        n           : integer := 32;
        shift_level : integer := 5
    );
    port (
        x    : in std_logic_vector(shift_level-1 downto 0);  -- shift amount
        y    : in std_logic_vector(n-1 downto 0);            -- input vector
        dir  : in std_logic;              -- "0" = SHL, "1" = SHR
        res  : out std_logic_vector(n-1 downto 0)
    );
	END COMPONENT;
---------------------------------------------------------	
    COMPONENT InterruptController is
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
	END COMPONENT;
---------------------------------------------------------	
    COMPONENT BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
	END COMPONENT;
---------------------------------------------------------	
    COMPONENT GPIO is
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
			Output_HEX5 					: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 )
			);
	END COMPONENT;	
---------------------------------------------------------	
    COMPONENT BasicTimer is
	PORT(	MCLK		 	: IN 	STD_LOGIC;
			rst_i		 	: IN 	STD_LOGIC;
			address_bus_i	: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			data_bus_io		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead_i 		: IN 	STD_LOGIC;
			MemWrite_i 		: IN 	STD_LOGIC;
			PWM_out 		: OUT 	STD_LOGIC;
			BTIFG 		    : OUT 	STD_LOGIC );
	END COMPONENT;	
---------------------------------------------------------	
    COMPONENT mcu is	
	generic (MODELSIM : integer 			:= G_MODELSIM);
	PORT( 
			reset								: IN 	STD_LOGIC; 
			clk								    : IN 	STD_LOGIC; 
			KEY0, KEY1, KEY2, KEY3 				: IN 	STD_LOGIC;
			SW 									: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			RX_bit								: IN 	STD_LOGIC;
			TX_bit								: OUT 	STD_LOGIC ;
			PWM									: OUT   STD_LOGIC;
			PC									: OUT   STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			Instruction_out						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			LEDR						 		: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clk_out                             : OUT   STD_LOGIC;
			data_bus_out                        : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			HEX0, HEX1, HEX2, HEX3,HEX4, HEX5 	: OUT 	STD_LOGIC_VECTOR( 6 DOWNTO 0 )
			);
	END COMPONENT;	

---------------------------------------------------------
  COMPONENT SevenSegDecoder is
  GENERIC (	n			: INTEGER := 4;
			SegmentSize	: integer := 7);
  PORT (data		: in STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		seg   		: out STD_LOGIC_VECTOR (SegmentSize-1 downto 0));
	END COMPONENT;
------------------------------------------------------------------------------------------------------------------
  COMPONENT tb is

	END COMPONENT;
---------------------------------------------------------
  COMPONENT UART is
  port (
    clock      	: in  	std_logic;
	Reset		: in  	std_logic := '0';
	address		: in 	std_logic_vector( 7 downto 0 ) := "00000000";	-- a11,a6-a0
	DataBus		: inout std_logic_vector( 31 downto 0 );
	MemRead     : in 	std_logic:= '0';
	MemWrite 	: in 	std_logic:= '0';
	RX_bit		: in	std_logic := '1';
	TX_bit     	: out 	std_logic := '1';
	RX_IFG 		: out  	std_logic := '0';
	TX_IFG		: out	std_logic := '0';
	Status_IFG	: out 	std_logic
    );
	END COMPONENT;

---------------------------------------------------------
  COMPONENT UART_RX is
  port (
	g_CLKS_PER_BIT 	: in integer := 434;
    i_Clk       	: in  std_logic;
    i_RX_Serial 	: in  std_logic := '1';
    o_RX_DV     	: out std_logic;
    o_RX_Byte   	: out std_logic_vector(7 downto 0);
	SWRST			: in  std_logic := '0';
	PENA			: in  std_logic := '0';
	PEV				: in  std_logic := '0';
	FE     			: out std_logic := '0';
	PE     			: out std_logic := '0';
	OE     			: out std_logic := '0';
	RX_Busy     	: out std_logic := '0'
    );
	END COMPONENT;
---------------------------------------------------------
  COMPONENT UART_TX is
   port (
	
  	g_CLKS_PER_BIT 	: in integer := 434;
    i_Clk       	: in  std_logic;
    i_TX_DV     	: in  std_logic;
    i_TX_Byte   	: in  std_logic_vector(7 downto 0);
    o_TX_Serial 	: out std_logic;
    o_TX_Done   	: out std_logic;
	SWRST			: in  std_logic := '0';
	PENA			: in  std_logic := '0';
    TX_Busy 		: out std_logic
    );
END COMPONENT;

-- ---------------------------------------------------------
  -- COMPONENT FirCore8 is
  -- generic(
    -- W : positive := 24;  -- sample width
    -- Q : positive := 8    -- coef fractional bits (Q0.Q)
  -- );
  -- port(
    -- clk      : in  std_logic;                           -- FIRCLK
    -- rst      : in  std_logic;                           -- FIRRST
    -- step     : in  std_logic;                           -- accept one new sample (1 clk) FIRENA
    -- x_in     : in  std_logic_vector(W-1 downto 0);      -- new sample (popped from FIFO)
    -- coef     : in  std_logic_vector(8*Q-1 downto 0);    -- {c7,c6,...,c0}, each Q bits
    -- y_out    : out std_logic_vector(W-1 downto 0);		-- FIROUT
    -- y_valid  : out std_logic                            -- 1 when y_out updated FIRFIG
  -- );
-- END COMPONENT;
-- ---------------------------------------------------------
  -- COMPONENT PulseSync is
  -- port(
    -- rst      : in  std_logic;
    -- FIRCLK   : in  std_logic;
    -- FIRENA    : in  std_logic;   -- "pop one" request in FIR domain (gate with !empty)
    -- FIFOCLK  : in  std_logic;
    -- FIFOREN  : out std_logic    -- 1-cycle pulse in FIFOCLK domain
  -- );
-- END COMPONENT;

-- ---------------------------------------------------------
  -- COMPONENT SyncFifo is
  -- generic(
    -- WIDTH : positive := 24;
    -- DEPTH : positive := 8              -- power of 2
  -- );
  -- port(
    -- FIFOCLK     : in  std_logic;           -- FIFOFIFOCLK
    -- rst     	: in  std_logic;
    -- FIFOWEN  	: in  std_logic;
    -- FIFOIN      : in  std_logic_vector(WIDTH-1 downto 0);
    -- FIFOREN   	: in  std_logic;           -- must be FIFOFIFOCLK-synchronous
    -- DATAOUT    	: out std_logic_vector(WIDTH-1 downto 0);
    -- FIFOFULL    : out std_logic;
    -- FIFOEMPTY   : out std_logic
  -- );
-- END COMPONENT;
-- ---------------------------------------------------------
 -- COMPONENT FIR_Top is
  -- generic(
    -- W      : positive := 24;
    -- Q      : positive := 8;
    -- DEPTH  : positive := 8
  -- );
  -- port(
    -- Data_Bus		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	-- address		 	: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- A11,A6-A0
	-- MemRead	 		: IN 	STD_LOGIC;
	-- MemWrite	 	: IN 	STD_LOGIC;
	-- -- clocks & resets
    -- FIFOCLK   : in  std_logic;
    -- FIFORST   : in  std_logic;
    -- FIRCLK    : in  std_logic;
    -- FIRRST    : in  std_logic;

    -- -- write-side (CPU -> FIFO)
    -- fifo_full : out std_logic;
    -- fifo_empty: out std_logic;
	
    -- -- output
    -- firout    : out std_logic_vector(31 downto 0);      -- {8'h00, y[23:0]}
    -- firifg    : out std_logic                           -- 1 when new y available
  -- );
-- END COMPONENT;

end aux_package;

