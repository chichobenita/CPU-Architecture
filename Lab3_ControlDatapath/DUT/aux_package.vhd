LIBRARY ieee;
USE ieee.std_logic_1164.all;
-------------------------------
package aux_package is
component Adder is
  generic ( N : positive := 16 );
  port (
    A    : in  std_logic_vector(N-1 downto 0);
    B    : in  std_logic_vector(N-1 downto 0);
    Cin  : in  std_logic;
    Sum  : out std_logic_vector(N-1 downto 0);
    Cout : out std_logic
 );
end component;

component ALU is
  GENERIC (DataWidth : INTEGER := 16);
  PORT ( Ain,clk 			: in std_logic;
		ALFUN 				: in std_logic_vector(3 downto 0);
		RegA_in,RegB_in	 	: in std_logic_vector(DataWidth-1 downto 0);
		RegC 				: out std_logic_vector(DataWidth-1 downto 0);
		Cflag,Nflag,Zflag	: out std_logic
);
END component;

component control is
	PORT(
		shl,st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,Cflag,Nflag,Zflag						: in std_logic;
		clk, rst, ena 																				: in std_logic;
		DTCM_wr,DTCM_addr_out,DTCM_addr_in,DTCM_out,Ain,RFin,RFout,IRin,PCin,Imm1_in,Imm2_in,done_o	: out std_logic;     
		ALFUN 																						: out std_logic_vector (3 downto 0);	
		RFaddr_rd,RFaddr_wr,PCsel				 													: out std_logic_vector (1 downto 0);
		DTCM_addr_sel																				: out std_logic
		);
END component;

component Datapath is
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
		DTCM_addr_sel,TBactive										: in std_logic;
		ITCM_tb_wr,DTCM_tb_wr										: in std_logic;
		ITCM_tb_in													: in std_logic_vector (m-1 downto 0);
		DTCM_tb_in													: in std_logic_vector (Dwidth-1 downto 0);
		ITCM_tb_addr_in,DTCM_tb_addr_in,DTCM_tb_addr_out 			: in std_logic_vector (Awidth-1 downto 0);
		st,ld,mov,done,add,sub,jmp,jc,
		jnc,and_o,or_o,xor_o,shl,Cflag,Nflag,Zflag						: out std_logic;
		DTCM_tb_out 												: out std_logic_vector(Dwidth-1 downto 0)
		);
end component;

component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0));
end component;

component dataMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn        : in std_logic;	
		WmemData         : in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr: in std_logic_vector(Awidth-1 downto 0);
		RmemData         : out std_logic_vector(Dwidth-1 downto 0));
end component;

component ProgMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn:          in std_logic;	
		WmemData:	        in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	in std_logic_vector(Awidth-1 downto 0);
		RmemData:          	out std_logic_vector(Dwidth-1 downto 0));
end component;

component RF is
generic( Dwidth: integer:=16;
		 Awidth: integer:=4);
port(	clk,rst,WregEn:		in std_logic;	
		WregData:			in std_logic_vector(Dwidth-1 downto 0);
		WregAddr,RregAddr:	in std_logic_vector(Awidth-1 downto 0);
		RregData: 			out std_logic_vector(Dwidth-1 downto 0)
);
end component;

component PC is
generic(OffsetSize : integer := 8;
		WordSize   : integer := 16);
port(	IRoffset   : in std_logic_vector(OffsetSize-1 downto 0);
		PCsel	   : in std_logic_vector(1 downto 0);
		clk,PCin   : in std_logic;
		PCout	   : out std_logic_vector(WordSize-1 downto 0)
		);
END component;

component OPCdecoder is
port(	IRin : in std_logic_vector (3 downto 0);
		st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,shl : out std_logic
	);
end component;

component IR is
port( 	IRin 							: in std_logic;
		RFaddr_rd,RFaddr_wr 			: in std_logic_vector(1 downto 0);
		DataIn 							: in std_logic_vector(15 downto 0);
		OPC,RegOut_rd,RegOut_wr,imm2 	: out std_logic_vector (3 downto 0);
		imm1,IRoffset 					: out std_logic_vector(7 downto 0)
		);
end component;

component top is
	generic( BusSize: integer:=16;	-- Data Memory In Data Size
			RegSize	: integer:=4;  	-- Address Size
			m		: integer:=16;  -- Program Memory In Data Size
			Awidth	: integer:=6
			);
	port(
        done_o : out std_logic;
        clk, rst, ena  : in STD_LOGIC;	
        ITCM_tb_wr, DTCM_tb_wr : in std_logic;
		ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out : in std_logic_vector(Awidth-1 downto 0);
        ITCM_tb_in  : in std_logic_vector(m-1 downto 0);
		DTCM_tb_in  : in std_logic_vector(BusSize-1 downto 0);
		DTCM_tb_out : out std_logic_vector(BusSize-1 downto 0);
		TBactive	   : in std_logic
		);
end component;

component shifter is
	generic (n 			 : integer := 16 ;--- number of bits
		     shift_level : integer := 4 );
	port (x,y  : in std_logic_vector (n-1 downto 0);
		  dir  : in std_logic_vector (2 downto 0);--- direction vector : for "000" SHL, for "001" SHR
		  res  : out std_logic_vector (n-1 downto 0);--- result
		  cout : out std_logic);--- carry out
end component;
end aux_package;

