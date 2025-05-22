library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;
-------------------------------------
entity DataPath is
generic( Dwidth		: integer:=16;
		 Awidth		: integer:=6;
		 BusSize	: integer:=16;
		 m			: integer:=16;
		 OffsetSize : integer := 8;
		 ImmidSize_1: integer := 8;
		 ImmidSize_2: integer := 4;
		 dept		: integer:=64;
		 RegSize	: integer:=4
		 );
port(	DTCM_wr,DTCM_addr_out,DTCM_addr_in,
		DTCM_out,Ain,RFin,RFout,IRin,PCin,Imm1_in,Imm2_in,clk,rst	: in std_logic;
		ALFUN 														: in std_logic_vector (3 downto 0);
		RFaddr_rd,RFaddr_wr,PCsel									: in std_logic_vector (1 downto 0);
		ITCM_tb_wr,DTCM_tb_wr,DTCM_addr_sel,TBactive				: in std_logic;
		ITCM_tb_in													: in std_logic_vector (m-1 downto 0);
		DTCM_tb_in													: in std_logic_vector (Dwidth-1 downto 0);
		ITCM_tb_addr_in,DTCM_tb_addr_in,DTCM_tb_addr_out 			: in std_logic_vector (Awidth-1 downto 0);
		st,ld,mov,done,add,sub,jmp,jc,
		jnc,and_o,or_o,xor_o,shl,Cflag,Nflag,Zflag						: out std_logic;
		DTCM_tb_out 												: out std_logic_vector(Dwidth-1 downto 0)
		);
end DataPath;
------------------------------------
architecture behav of DataPath is
--PC--
signal PCtoProgMem_rd			:std_logic_vector(Awidth-1 downto 0);
-- Program Memory --
signal DataOutProgram :std_logic_vector(Dwidth-1 downto 0);
-- IR --
signal IRtoOPC 				:std_logic_vector(3 downto 0);
signal IRtoImm_1 			:std_logic_vector(ImmidSize_1-1 downto 0);
signal IRtoImm_2 			:std_logic_vector(ImmidSize_2-1 downto 0);
signal IRtoPC				:std_logic_vector(OffsetSize-1 downto 0);
signal IRtoRF_wr, IRtoRF_rd :std_logic_vector(3 downto 0);
--RF--
signal RFtoBusB :std_logic_vector(BusSize-1 downto 0);
--BusB--
signal BusB					 	:std_logic_vector(BusSize-1 downto 0);
signal BusBtoDTCM_addr_out_mux 	:std_logic_vector(BusSize-1 downto 0);
signal BusBtoDTCM_addr_in_mux	:std_logic_vector(BusSize-1 downto 0);
signal BusBtoALU				:std_logic_vector(BusSize-1 downto 0);
--ALU--
signal CtoBusA					:std_logic_vector(BusSize-1 downto 0);
--BusA--
signal BusA					 	:std_logic_vector(BusSize-1 downto 0);
signal BusAtoRegA				:std_logic_vector(BusSize-1 downto 0);
signal BusAtoDTCM_addr_out_mux 	:std_logic_vector(BusSize-1 downto 0);
signal BusAtoDTCM_addr_in_mux 	:std_logic_vector(BusSize-1 downto 0);
signal BusAtoRF					:std_logic_vector(BusSize-1 downto 0);
--Muxes--
signal MuxtoDataMem_rd		:std_logic_vector(Awidth-1 downto 0);
signal MuxtoDataMem_wr		:std_logic_vector(Awidth-1 downto 0);
signal MuxtoDataMem_wren	:std_logic;
signal MuxtoDataMem_datain	:std_logic_vector(BusSize-1 downto 0);
signal MuxtoFF_out			:std_logic_vector(BusSize-1 downto 0);
signal MuxtoFF_in			:std_logic_vector(BusSize-1 downto 0);
--FF(flip flop)--
signal FFtoMux_rd			:std_logic_vector(Awidth-1 downto 0);
signal FFtoMux_wr			:std_logic_vector(Awidth-1 downto 0);
--DataMemory--
signal DataMemtoBusB		:std_logic_vector(BusSize-1 downto 0);
--imm--
signal Imm_1 			:std_logic_vector(BusSize-1 downto 0);
signal Imm_2 			:std_logic_vector(BusSize-1 downto 0);
----------------------------------------- PORT MAPS --------------------------------------------
begin
-- Program Memory (clk, memEn, WmemData, WmemAddr, RmemAddr, RmemData)--
ProgMem_box: progMem generic map(BusSize, Awidth, dept) port map (clk, ITCM_tb_wr, ITCM_tb_in, ITCM_tb_addr_in, PCtoProgMem_rd(5 downto 0), DataOutProgram);
-- Data Memory    - (clk, memEn, WmemData, WmemAddr, RmemAddr, RmemData)
DataMem_box: dataMem generic map(BusSize, Awidth, dept) port map (clk, MuxtoDataMem_wren, MuxtoDataMem_datain, MuxtoDataMem_wr, MuxtoDataMem_rd, DataMemtoBusB);
-- Register File  - (clk, rst, WregEn, WregData, WregAddr, RregAddr, RregData)
RegFile_box: RF generic map(BusSize, RegSize) port map (clk, rst, RFin, BusAtoRF, IRtoRF_wr, IRtoRF_rd, RFtoBusB);
-- ALU            - (Ain,clk,ALUFN,A,B,C,CFlag,Nflag,Zflag)
ALU_box    : ALU generic map(BusSize) port map (Ain,clk, ALFUN,BusAtoRegA,BusB,CtoBusA, CFlag, NFlag, ZFlag);
-- ALUFN Decoder    - (IRreg, st, ld, mov, done, add, sub, jmp, jc, jnc,and_o,or_o,xor_o)
OPCdec_box : OPCdecoder port map(IRtoOPC, st, ld, mov, done, add, sub, jmp, jc, jnc, and_o, or_o, xor_o,shl);
-- PC             - (IR_offset, PCsel, clk, PCin, PCout)
PCLogic_box: PC  generic map(OffsetSize, Dwidth) port map(IRtoPC, PCsel, clk, PCin, PCtoProgMem_rd);
-- IR             -(IRin, RFaddr_rd,RFaddr_wr, DataIn,OPC,RegOut_rd,RegOut_wr,imm2,imm1,IRoffset)  
IR_box     : IR port map(IRin, RFaddr_rd, RFaddr_wr, DataOutProgram, IRtoOPC, IRtoRF_rd, IRtoRF_wr,IRtoImm_2, IRtoImm_1,IRtoPC);     
--------------------------------------------------------------------------------------------------
------------------------------------------ Debug -------------------------------------------
process(clk, PCtoProgMem_rd)
begin
    if rising_edge(clk) then
        report "Datapath Debug Section"
        & LF & "time =      " & to_string(now)
		& LF & "IR =      " & to_string(DataOutProgram)		
        & LF & "Immidiate_1 = " & to_string(IRtoImm_1)
		& LF & "Immidiate_2 = " & to_string(IRtoImm_2)
        & LF & "A =         " & to_string(BusAtoRegA)
        & LF & "B =         " & to_string(BusBtoALU)
        & LF & "C =         " & to_string(CtoBusA)
        & LF & "Cflag =     " & to_string(CFlag)
        & LF & "Nflag =     " & to_string(NFlag)
        & LF & "Zflag =     " & to_string(ZFlag)          
        & LF & "ALUFN =       " & to_string(ALFUN)
        & LF & "*"
        & LF & "IRopc =              " & to_string(IRtoOPC)
        & LF & "Write Data to RF =  " & to_string(BusAtoRF) 
        & LF & "Read Data from RF = " & to_string(RFtoBusB) 
        & LF & "RFaddr_rd =          " & to_string(IRtoRF_rd)
		& LF & "RFaddr_wr =          " & to_string(IRtoRF_wr)
        & LF & "dataBus_B =           " & to_string(BusB) 
		& LF & "dataBus_A =           " & to_string(BusA) 
        & LF & "WriteAddressDataMem =     " & to_string(MuxtoDataMem_wr)     
        & LF & "dataInDataMem =     " & to_string(MuxtoDataMem_datain)
		& LF & "DTCM_tb_out =     " & to_string(DTCM_tb_out)
        & LF & "**************** Status ***********************"
        & LF & "DTCM_wr =    " & to_string(DTCM_wr)
        & LF & "ALUFN =       " & to_string(ALFUN)
        & LF & "Ain =       " & to_string(Ain)
        & LF & "RFin =      " & to_string(RFin)
        & LF & "RFout =     " & to_string(RFout)
        & LF & "RFaddr_rd =    " & to_string(RFaddr_rd)
		& LF & "RFaddr_wr =    " & to_string(RFaddr_wr)
        & LF & "IRin =      " & to_string(IRin) 
        & LF & "PCin =      " & to_string(PCin) 
        & LF & "PCsel =     " & to_string(PCsel) 
        & LF & "Imm1_in =   " & to_string(Imm1_in) 
        & LF & "Imm2_in =   " & to_string(Imm2_in)
        & LF & "DTCM_addr_in =    " & to_string(DTCM_addr_in)
		& LF & "DTCM_addr_sel =     " & to_string(DTCM_addr_sel)
		& LF & "READ_addrMEMORY =    " & to_string(FFtoMux_wr)
		& LF & "FFtoMux_rd =    " & to_string(MuxtoFF_in)
        & LF & "DTCM_out =   " & to_string(DTCM_out);
    end if;
end process;
----------------------------------------- BiDir Bus B ------------------------------------------
RFtoBUS               : BidirPin generic map(BusSize) port map(RFtoBusB, RFout, BusBtoALU, BusB);
DataMEMtoBUS          : BidirPin generic map(BusSize) port map(DataMemtoBusB, DTCM_out, BusBtoALU, BusB);
Imm1toBUS             : BidirPin generic map(BusSize) port map(Imm_1, Imm1_in, BusBtoALU, BusB);
Imm2toBUS             : BidirPin generic map(BusSize) port map(Imm_2, Imm2_in, BusBtoALU, BusB);
-- Immidiate Sign Extension 
Imm_1 <= SXT(IRtoImm_1, BusSize) when Imm1_in ='1' else unaffected;
Imm_2 <= SXT(IRtoImm_2, BusSize) when Imm2_in ='1' else unaffected;
------------------------------------------Bus A-------------------------------------------------
BusA   <= CtoBusA;
BusAtoRF <= BusA;

------------------RegA------------------
RegA_proc: process (clk)
begin
	if (clk'event and clk = '1' and Ain = '1') then
		BusAtoRegA <= BusA;
		end if;
end process;
--------------- Data Memory Write/Read ----------------
MuxtoFF_out <= BusA when DTCM_addr_sel = '0' else BusB;
MuxtoFF_in  <= BusA when DTCM_addr_sel = '0' else BusB;


FFtoMux_rd <= MuxtoFF_out(Awidth-1 downto 0)  when (DTCM_addr_out = '1') else unaffected;

--DataMem_R: process(clk) 
--begin
 -- when (DTCM_addr_out = '1') then
  --           else unaffected;
--end process;

DataMem_W: process(clk) 
begin
    if (clk'event and clk='1') then
        if (DTCM_addr_in = '1') then
            FFtoMux_wr <= MuxtoFF_in(Awidth-1 downto 0);
        end if;
    end if;
end process;
----------------------------------------------------------------------------------------------
----- Test Bench Connections --------
-- Data Memory TB
MuxtoDataMem_wren       <= DTCM_tb_wr     when TBactive = '1'  else DTCM_wr;
MuxtoDataMem_datain     <= DTCM_tb_in   when TBactive = '1'  else BusB;
MuxtoDataMem_wr  		<= DTCM_tb_addr_in   when TBactive = '1'  else FFtoMux_wr;
MuxtoDataMem_rd   		<= DTCM_tb_addr_out   when TBactive = '1'  else FFtoMux_rd;
DTCM_tb_out             <= DataMemtoBusB;
end behav;
			 





