LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
------entity------
entity logic is
		generic (n : integer := 8);
		port( xin     : in std_logic_vector  (n-1 downto 0);
			  yin     : in std_logic_vector  (n-1 downto 0);
			  op_mode : in std_logic_vector  (2 downto 0);
			  res     : out std_logic_vector (n-1 downto 0)
			);
end logic;

--------architecture-----
architecture dataflow of logic is
signal y_xor_sig :std_logic_vector(3 downto 0);
signal x_xor_sig :std_logic_vector(3 downto 0);
signal merge_sig :std_logic_vector(7 downto 0);

begin

y_xor_sig <= yin(7 downto 4) xor yin(3 downto 0);
x_xor_sig <= xin(7 downto 4) xor xin(3 downto 0);
merge_sig <= y_xor_sig & x_xor_sig;
running : for i in 0 to n-1 generate
	res(i) <=   not yin(i) when op_mode = "000" else 
				yin(i) or xin(i) when op_mode = "001" else
				yin(i) and xin(i) when op_mode ="010" else
				yin(i) xor xin(i) when op_mode ="011" else
				yin(i) nor xin(i) when op_mode ="100" else
				yin(i) nand xin(i) when op_mode ="101" else
				yin(i) xnor xin(i) when op_mode ="110" else
				merge_sig(i) when op_mode = "111" else
				'0';
				end generate;
end dataflow;