library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
------entity------
entity shifter is
	generic (n 			 : integer := 16 ;--- number of bits
		     shift_level : integer := 4 );
	port (x,y  : in std_logic_vector (n-1 downto 0);
		  dir  : in std_logic_vector (2 downto 0);--- direction vector : for "000" SHL, for "001" SHR
		  res  : out std_logic_vector (n-1 downto 0);--- result
		  cout : out std_logic);--- carry out
end shifter;
--------architecture-----
architecture dataflow of shifter is
	subtype row_vector is std_logic_vector (n-1 downto 0);
	type matrix is array (shift_level downto 0) of row_vector;--- array that each row is a vector after shifting
	signal arr : matrix;
	signal carry_vector : std_logic_vector (shift_level-1 downto 0);
	


begin

	set0 : for i in 0 to n-1 generate
		arr(0)(i) <= y(i)     when dir = "000" else
					 y(n-1-i) when dir = "001";
					 
	end generate;
			
	shifting : for i in 1 to shift_level generate
		arr(i)(2**(i-1)-1 downto 0) <= arr(i-1)(2**(i-1)-1 downto 0) 	 when x(i-1) = '0' else
									 (others => '0')                     when x(i-1) = '1';
		arr(i)(n-1 downto 2**(i-1)) <= arr(i-1)(n-1 downto 2**(i-1))     when x(i-1) = '0' else
									   arr(i-1)(n-1-2**(i-1) downto 0 )  when x(i-1) = '1';
		
		end generate;
		
	res_vector : for i in n-1 downto 0 generate
		res(i) <= arr(shift_level)(i)     when dir = "000" else
				  arr(shift_level)(n-1-i) when dir = "001" else
				  '0';
		end generate;
		
-------------------------------------
	
	carry_vector(0) <= arr(0)(n-1)  when x(0) = '1' else
						'0' 		when x(0) = '0';
	
	carry_out : for i in 1 to shift_level-1 generate
		carry_vector(i) <= arr(i)(n-2**(i))	when x(i) = '1' else
					   carry_vector(i-1) 		when x(i) = '0';
	end generate;
	
	cout <= carry_vector(shift_level-1) when (dir = "000" or dir = "001") else
			'0';
	
-------------------------------------
end dataflow;
			