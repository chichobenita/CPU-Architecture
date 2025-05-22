LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE work.aux_package.all;
----------------------------------
entity IR is
port( 	IRin 							: in std_logic;
		RFaddr_rd,RFaddr_wr 			: in std_logic_vector(1 downto 0);
		DataIn 							: in std_logic_vector(15 downto 0);
		OPC,RegOut_rd,RegOut_wr,imm2 	: out std_logic_vector (3 downto 0);
		imm1,IRoffset 					: out std_logic_vector(7 downto 0)
		);
end IR;
----------------------------------
architecture behav of IR is
signal IRcur : std_logic_vector(15 downto 0);
begin
IRcur 		<= DataIn when IRin = '1' else unaffected;
OPC 		<= IRcur (15 downto 12);
IRoffset 	<= IRcur (7 downto 0);
imm1 		<= IRcur (7 downto 0);
imm2		<= IRcur (3 downto 0);

reg_mux1: with RFaddr_rd select
RegOut_rd <= 	IRcur(3 downto 0) when "00", 		---rc---
				IRcur(7 downto 4) when "01", 		---rb---
				IRcur(11 downto 8) when others;		---ra---
				
reg_mux2: with RFaddr_wr select
RegOut_wr <= 	IRcur(3 downto 0) when "00", 		---rc---
				IRcur(7 downto 4) when "01", 		---rb---
				IRcur(11 downto 8) when others;		---ra---
			
end behav;