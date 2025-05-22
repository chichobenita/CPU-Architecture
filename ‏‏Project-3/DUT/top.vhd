library ieee;
use ieee.std_logic_1164.all;
use work.aux_package.all;

entity top is
	generic( 	BusSize: integer:=16;	-- Data Memory In Data Size
				RegSize: integer:=4;  	-- Address Size
				m: 	     integer:=16;  -- Program Memory In Data Size
				Awidth:  integer:=6);
	port(
        done_o 					: out std_logic;
        clk, rst, ena  			: in STD_LOGIC;	
		-- Test Bench
        ITCM_tb_wr, DTCM_tb_wr 	: in std_logic;
		ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out :	in std_logic_vector(Awidth-1 downto 0);
        ITCM_tb_in  			: in std_logic_vector(m-1 downto 0);
		DTCM_tb_in  			: in std_logic_vector(BusSize-1 downto 0);
		DTCM_tb_out 			: out std_logic_vector(BusSize-1 downto 0);
		TBactive	   			: in std_logic
	);
end top;
----------------------------------------------------------
architecture behav of top is
signal		shl,st, ld, mov, done, add, and_o, or_o, xor_o, sub, jmp, jc, jnc, Cflag, Zflag, Nflag:  std_logic;
signal		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_out, DTCM_addr_in, DTCM_addr_out,DTCM_addr_sel :  std_logic;
signal		ALFUN :  std_logic_vector(3 downto 0);
signal 		PCsel, RFaddr_rd,RFaddr_wr :  std_logic_vector(1 downto 0);
begin
ControlUnit: Control 	port map(	shl=>shl,st=>st,ld=>ld,mov=>mov,done=>done,add=>add,sub=>sub,jmp=>jmp,jc=>jc,jnc=>jnc,and_o=>and_o,or_o=>or_o,xor_o=>xor_o,
									Cflag=>Cflag,Nflag=>Nflag,Zflag=>Zflag,clk=>clk, rst=>rst, ena=>ena,DTCM_wr=>DTCM_wr,DTCM_addr_out=>DTCM_addr_out,
									DTCM_addr_in=>DTCM_addr_in,DTCM_out=>DTCM_out,Ain=>Ain,RFin=>RFin,RFout=>RFout,IRin=>IRin,PCin=>PCin,Imm1_in=>Imm1_in,
									Imm2_in=>Imm2_in,done_o=>done_o,ALFUN=>ALFUN,RFaddr_rd=>RFaddr_rd,RFaddr_wr=>RFaddr_wr,PCsel=>PCsel,DTCM_addr_sel=>DTCM_addr_sel);

DataPathUnit: Datapath generic map(BusSize)  port map(	DTCM_wr=>DTCM_wr,DTCM_addr_out=>DTCM_addr_out,DTCM_addr_in=>DTCM_addr_in,DTCM_out=>DTCM_out,Ain=>Ain,RFin=>RFin
														,RFout=>RFout,IRin=>IRin,PCin=>PCin,Imm1_in=>Imm1_in,Imm2_in=>Imm2_in,clk=>clk,rst=>rst,ALFUN=>ALFUN
														,RFaddr_rd=>RFaddr_rd,RFaddr_wr=>RFaddr_wr,PCsel=>PCsel,ITCM_tb_wr=>ITCM_tb_wr,DTCM_tb_wr=>DTCM_tb_wr
														,DTCM_addr_sel=>DTCM_addr_sel,TBactive=>TBactive,ITCM_tb_in=>ITCM_tb_in,DTCM_tb_in=>DTCM_tb_in
														,ITCM_tb_addr_in=>ITCM_tb_addr_in,DTCM_tb_addr_in=>DTCM_tb_addr_in,DTCM_tb_addr_out=>DTCM_tb_addr_out,st=>st,ld=>ld
														,mov=>mov,done=>done,add=>add,sub=>sub,jmp=>jmp,jc=>jc,jnc=>jnc,and_o=>and_o,or_o=>or_o,xor_o=>xor_o,shl=>shl
														,Cflag=>Cflag,Nflag=>Nflag,Zflag=>Zflag,DTCM_tb_out=>DTCM_tb_out);
								

end behav;
