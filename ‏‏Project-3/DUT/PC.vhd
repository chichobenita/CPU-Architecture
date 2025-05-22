LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE work.aux_package.all;
----------------------------------
entity PC is
generic(OffsetSize : integer := 8;
		WordSize   : integer := 16);
port(	IRoffset   : in std_logic_vector(OffsetSize-1 downto 0);
		PCsel	   : in std_logic_vector(1 downto 0);
		clk,PCin   : in std_logic;
		PCout	   : out std_logic_vector(5 downto 0)
		);
end PC;
----------------------------------
architecture behav of PC is
signal PCcur,PCnext : std_logic_vector(WordSize-1 downto 0);

begin
		next_PC: with PCsel select
		PCnext <= 	PCcur + 1 when "01",
					PCcur + 1 + IRoffset when "10",
					(others => '0') when "00",
					unaffected when others;

PC_process: process (clk)
begin 
	if (clk'event and clk = '1' and PCin = '1') then
		PCcur <= PCnext;
		end if;
end process;

PCout <= PCcur(5 downto 0);
end behav;
	
		