LIBRARY ieee;
USE ieee.std_logic_1164.all;


package aux_package is

	component top is
		generic ( n : positive := 8 ); 
		port( rst_i, clk_i, repeat_i : in std_logic;
		  upperBound_i : in std_logic_vector(n-1 downto 0);
		  count_o : out std_logic_vector(n-1 downto 0);
		  busy_o : out std_logic);
	end component;
  











 
end aux_package;

