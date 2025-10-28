-- Top Level Structural Model for mips-core based MCU
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.all;
USE work.cond_comilation_package.all;

ENTITY MCU IS
	generic (MODELSIM : integer 			:= G_MODELSIM);
	PORT( 
			reset								: IN 	STD_LOGIC; 
			clk								    : IN 	STD_LOGIC; 
			KEY0, KEY1, KEY2, KEY3 				: IN 	STD_LOGIC;
			SW 									: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			RX_bit								: IN 	STD_LOGIC;
			TX_bit								: OUT 	STD_LOGIC;
			PWM									: OUT   STD_LOGIC;
			PC									: OUT   STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			Instruction_out						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			LEDR						 		: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clk_out                             : OUT   STD_LOGIC;
			data_bus_out                        : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			DIN_FOR_DEBUG             : OUT 	STD_LOGIC_VECTOR( 8 DOWNTO 0 );
			HEX0, HEX1, HEX2, HEX3,HEX4, HEX5 	: OUT 	STD_LOGIC_VECTOR( 6 DOWNTO 0 )
			);
END MCU;

ARCHITECTURE structure OF MCU IS



	SIGNAL MemWrite_w						: STD_LOGIC;
	SIGNAL MemRead_w						: STD_LOGIC;
	SIGNAL INTA_w							: STD_LOGIC;
	SIGNAL INTR_w							: STD_LOGIC;
	SIGNAL GIE_w							: STD_LOGIC;
	
	SIGNAL DataBUS_w						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	-- 32 bits Data bus
	SIGNAL address				     		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	
	SIGNAL HEX0_w					     	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL HEX1_w						    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL HEX2_w						    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL HEX3_w						    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL HEX4_w						    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL HEX5_w						    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL KEY0_rst							: STD_LOGIC;
	
	SIGNAL BTIFG_w				    		: STD_LOGIC;
	SIGNAL IR_w	 						    : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL BT_out                           : STD_LOGIC;
	SIGNAL RX_IFG							: STD_LOGIC;
	SIGNAL TX_IFG							: STD_LOGIC;
	signal Status_IFG						: STD_LOGIC;
	SIGNAL FIFOemp							: STD_LOGIC;
	SIGNAL FIRout							: STD_LOGIC;
	SIGNAL MCLK_w							: STD_LOGIC;
	SIGNAL CLK_FOR_DEBUG                    : STD_LOGIC;

	signal fake_reset : std_logic := '0';

	
	
				-- preserve them for SignalTap
attribute keep : boolean;
attribute keep of IR_w : signal is true;
attribute keep of address : signal is true;
attribute keep of fake_reset : signal is true;
BEGIN

	

	--FOR TEST ONLY !---
	FIFOemp <= '0';   --
	FIRout  <= '0';   --
	--Status_IFG <= '0';
--	RX_IFG <= '0';
--	TX_IFG <= '0';
	--------------------
	
	IR_w(7)     <= Status_IFG;
	IR_w(0) 	<= RX_IFG;
	IR_w(1) 	<= TX_IFG;
	IR_w(2)     <= BTIFG_w;
	IR_w(3)	    <= NOT(KEY1);
	IR_w(4)	    <= NOT(KEY2);
	IR_w(5) 	<= NOT(KEY3);
	IR_w(6)     <= FIFOemp;
	IR_w(8)     <= FIRout;
	
	

	KEY0_rst <= NOT(KEY0);

	data_bus_out <= DataBUS_w; 
	clk_out      <= MCLK_w;
	
	G0: if (G_MODELSIM = 0) generate
    MCLK: PLL
        port map (
            inclk0 => clk,
            c0     => CLK_FOR_DEBUG
        );
	end generate G0;

	G1: if (G_MODELSIM /= 0) generate
		CLK_FOR_DEBUG <= clk;
	end generate G1;

	MCLK_w <= CLK_FOR_DEBUG ;
	mcu_to_mips: MIPS 

	PORT MAP (
	rst_i              => fake_reset,
	clk_i              => MCLK_w,
	DATA_BUS_io        => DataBUS_w,
    ADDRESS_o          => address,
    MemWrite_ctrl_o    => MemWrite_w,
    RegWrite_ctrl_o    => open,
    MemRead_ctrl_o     => MemRead_w,
    INTR               => INTR_w,
    INTA               => INTA_w,
    GIE                => GIE_w,
    pc_o               => PC,
    alu_result_o       => open,
    read_data1_o       => open,
    read_data2_o       => open,
    write_data_o       => open,
    instruction_top_o  => Instruction_out,
    Branch_ctrl_o      => open,
    Zero_o             => open,
    mclk_cnt_o         => open,
    inst_cnt_o         => open
	);

	mcu_to_GPIO : GPIO
   	PORT MAP (	
				Data_Bus			 			=> DataBUS_w,
				clock		 					=> MCLK_w,
				Reset		 				    => fake_reset,
				address		 					=> address(11)&address(6 DOWNTO 0),
				MemRead 						=> MemRead_w,
				MemWrite 						=> MemWrite_w,
				A0              				=> address(0),
				Input_SW						=> SW,
				Output_LEDR					    => LEDR,
				Output_HEX0						=> HEX0_w,
				Output_HEX1						=> HEX1_w,
				Output_HEX2						=> HEX2_w,
				Output_HEX3						=> HEX3_w,
				Output_HEX4						=> HEX4_w,
				Output_HEX5 					=> HEX5_w
				);

	mcu_to_interContro: InterruptController
	PORT MAP (
				clock	   						=> MCLK_w,	
				Reset		 					=> KEY0_rst,
				address		 					=> address(11)&address(6 DOWNTO 0),
				DataBus		 					=> DataBUS_w,
				MemRead	 						=> MemRead_w,
				MemWrite	 					=> MemWrite_w,
				IR	 							=> IR_w,
				DIN_FOR_DEBUG                   => DIN_FOR_DEBUG,
				GIE	 			 				=> GIE_w,
				INTA	 						=> INTA_w,
				INTR		 					=> INTR_w
				);

	mcu_to_basicTimer: BasicTimer
	PORT MAP (
				MCLK							=> MCLK_w,	 	
				rst_i		 					=> fake_reset,
				address_bus_i					=> address(11)&address(6 DOWNTO 0),
				data_bus_io		   				=> DataBUS_w,
				MemRead_i 						=> MemRead_w,
				MemWrite_i 						=> MemWrite_w,
				PWM_out 						=> PWM,
				BTIFG 							=> BTIFG_w
				);
	
	-- FIR: FIR_Top
	-- PORT MAP (			
				
	-- Data_Bus		=> DataBUS_w, 
	-- address		 	=> address(11)&address(6 DOWNTO 0),
	-- MemRead	 		=> MemRead_w,
	-- MemWrite	 	=> MemWrite_w,
	-- -- clocks & resets
    -- FIFOCLK         => MCLK_w,	
    -- FIFORST   		=> KEY0_rst,
    -- FIRCLK    
    -- FIRRST    

    -- -- write-side (CPU -> FIFO)
    -- fifo_full 
    -- fifo_empty			=>FIFOemp
	
    -- -- output
    -- firout    =>FIRout,
    -- firifg       
	
	-- FIR: fir_accel
	-- PORT MAP (
			-- clk_i => MCLK_w,
			-- rst_i => KEY0_rst,
			-- address_i => FIRaddress,
			-- MemRead_i => MemRead,
			-- MemWrite_i => MemWrite,
			-- data_io => DataBUS,
			-- fir_clk_i => MCLK_w,
			-- irq_fifo_empty_o => FIFOemp,
			-- irq_fir_done_o => FIRout
			-- );
			
	
mcu_to_UART: UART

  PORT MAP (
    clock      	=> MCLK_w,
	Reset		=> fake_reset,
	address		=> address(11)&address(6 DOWNTO 0),
	DataBus		=> DataBUS_w,
	MemRead     => MemRead_w,
	MemWrite 	=> MemWrite_w,
	RX_bit		=> RX_bit,
	TX_bit     	=> TX_bit,
	RX_IFG 		=> RX_IFG,
	TX_IFG		=> TX_IFG,
	Status_IFG	=> Status_IFG
    );
			
	
			
		
	g2: SevenSegDecoder 		PORT MAP ( data => HEX0_w(3 DOWNTO 0),  seg => HEX0);
	g3: SevenSegDecoder 		PORT MAP ( data => HEX1_w(3 DOWNTO 0),  seg => HEX1);
	g4: SevenSegDecoder 		PORT MAP ( data => HEX2_w(3 DOWNTO 0),  seg => HEX2);
	g5: SevenSegDecoder 		PORT MAP ( data => HEX3_w(3 DOWNTO 0),  seg => HEX3);
	g6: SevenSegDecoder 		PORT MAP ( data => HEX4_w(3 DOWNTO 0),  seg => HEX4);
	g7: SevenSegDecoder 		PORT MAP ( data => HEX5_w(3 DOWNTO 0),  seg => HEX5);
	
END structure;