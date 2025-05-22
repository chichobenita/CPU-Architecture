library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
entity addertb is
	generic (n : integer := 8);
end addertb;
---------------------------------------------------------
architecture astb of addertb is
component AdderSub 
	port(xin, yin:in std_logic_vector(n-1 downto 0);
			op_mode: in std_logic_vector(2 downto 0);
			res: out std_logic_vector(n-1 downto 0);
			cout: out std_logic;
			v   : out std_logic
			);
end component;

signal xin , yin : std_logic_vector(n-1 downto 0) := (others => '0');
signal op_mode : std_logic_vector(2 downto 0);
signal res : std_logic_vector(n-1 downto 0);
signal cout : std_logic;
signal v    : std_logic;

begin
test : AdderSub port map (
		xin => xin , yin => yin , op_mode => op_mode , res => res , cout => cout , 
		v    => v
		);
		
		testbench : process
		begin
		---y+x test---
		xin <= "01010101"; yin <= "00110110"; op_mode <= "000";
		wait for 50 ns;
		assert(res = "10001011" and cout = '0')
		report "test1 fail" severity error;
		---y-x test---
		xin <= "01010101"; yin <= "00110110"; op_mode <= "001";
		wait for 50 ns;
		assert(res = "11100001" and cout = '0')
		report "test2 fail" severity error;
		--- (-x) test---
		xin <= "01010101"; yin <= "00110110"; op_mode <= "010";
		wait for 50 ns;
		assert(res = "10101011" and cout = '0')
		report "test3 fail" severity error;
		---y+1 test---
		xin <= "01010101"; yin <= "11111111"; op_mode <= "011";
		wait for 50 ns;
		assert(res = "00000000" and cout = '1')
		report "test4 fail" severity error;
		---y-1 test---
		xin <= "01010101"; yin <= "00110110"; op_mode <= "100";
		wait for 50 ns;
		assert(res = "00110101" and cout = '1')
		report "test5 fail" severity error;
		---wrong op_mode test---
		xin <= "01010101"; yin <= "00110110"; op_mode <= "111";
		wait for 50 ns;
		assert(res = "00000000" and cout = '0')
		report "test6 fail" severity error;
		end process;
end astb;
		