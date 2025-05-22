LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
---------------------------------
entity Adder is
  generic ( N : positive := 16 );
port(		A,B : in std_logic_vector (N-1 downto 0);
			Cin : in std_logic;
			Sum : out std_logic_vector (N-1 downto 0);
			Cout: out std_logic
);
end Adder;
---------------------------------
architecture behav of Adder is
signal carry : std_logic_vector (N downto 0);
begin
carry(0) <= Cin;

gen: for i in 0 to N-1 generate
	Sum(i) <= A(i) xor B(i) xor carry(i);
	carry(i+1) <= (A(i) and B(i)) or (B(i) and  carry(i)) or (A(i) and carry(i));
end generate gen;
Cout <= carry(N);
end behav;
