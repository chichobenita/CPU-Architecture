library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
entity logictb is
	generic (n : integer := 8);
end logictb;
---------------------------------------------------------
architecture ltb of logictb is
component logic
		port( xin, yin :in std_logic_vector(n-1 downto 0);
				op_mode: in std_logic_vector(2 downto 0);
				res : out std_logic_vector(n-1 downto 0)
				);
end component;

signal xin , yin : std_logic_vector(n-1 downto 0) := (others => '0');
signal op_mode : std_logic_vector(2 downto 0);
signal res : std_logic_vector(n-1 downto 0);

begin
test : logic port map (
		xin => xin , yin => yin , op_mode => op_mode , res => res
		);
		
		testbench : process
		begin
		---test1---
		xin <= "00000001"; yin <= "11111111"; op_mode <= "000";
		wait for 50 ns;
		assert(res = "00000000")
		report "test1 fail" severity error;
		---test2---
		xin <= "00100101"; yin <= "10110101"; op_mode <= "001";
		wait for 50 ns;
		assert(res = "10110101")
		report "test2 fail" severity error;
		---test3---
		xin <= "00100111"; yin <= "10110101"; op_mode <= "010";
		wait for 50 ns;
		assert(res = "00100101")
		report "test3 fail" severity error;
		---test4---
		xin <= "10100110"; yin <= "10100101"; op_mode <= "011";
		wait for 50 ns;
		assert(res = "00000011")
		report "test4 fail" severity error;
		---test5---
		xin <= "10100110"; yin <= "10100101"; op_mode <= "100";
		wait for 50 ns;
		assert(res = "01011000")
		report "test5 fail" severity error;
		---test6---
		xin <= "10100110"; yin <= "10100101"; op_mode <= "101";
		wait for 50 ns;
		assert(res = "01011011")
		report "test6 fail" severity error;
		---test7---
		xin <= "10100110"; yin <= "10100101"; op_mode <= "111";
		wait for 50 ns;
		assert(res = "11111100")
		report "test7 fail" severity error;
		---test8---
		xin <= "10100110"; yin <= "10100101"; op_mode <= "110";
		wait for 50 ns;
		assert(res = "11111100")
		report "test7 fail" severity error;
		
end process;
end ltb;