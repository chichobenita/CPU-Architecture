library IEEE;
use ieee.std_logic_1164.all;

package aux_package is
--------------------------------------------------------
	component top is
	GENERIC (n : INTEGER := 8;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
	PORT 
	(  
		Y_i,X_i: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		ALUout_o: OUT STD_LOGIC_VECTOR(n-1 downto 0);
		Nflag_o,Cflag_o,Zflag_o,Vflag_o: OUT STD_LOGIC 
	); -- Zflag,Cflag,Nflag,Vflag
	end component;
---------------------------------------------------------  
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
---------------------------------------------------------	
    component shifter is
	
	generic (n : integer := 8;--- number of bits
		     shift_level : integer :=3 );
	port (x,y  : in std_logic_vector (n-1 downto 0);
		  dir  : in std_logic_vector (2 downto 0);--- direction vector : for "000" SHL, for "001" SHR
		  res  : out std_logic_vector (n-1 downto 0);--- result
		  cout : out std_logic);--- carry out
	end component;
---------------------------------------------------------	
    component AdderSub is
	
	generic (n : integer := 4);
	port(xin, yin:in std_logic_vector(n-1 downto 0);
			op_mode: in std_logic_vector(2 downto 0);
			res: out std_logic_vector(n-1 downto 0);
			cout , v : out std_logic);
	end component;
---------------------------------------------------------	
	component logic is
	generic (n : integer := 4);
	port( xin, yin :in std_logic_vector(n-1 downto 0);
				op_mode: in std_logic_vector(2 downto 0);
				res : out std_logic_vector(n-1 downto 0));
	end component;
---------------------------------------------------------	
end aux_package;

