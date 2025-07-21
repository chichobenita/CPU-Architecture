LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
use ieee.numeric_std.all;

---------------entity--------------------
ENTITY top IS
  GENERIC (n : INTEGER := 16;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
  PORT (  
		Y, X                                    : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		ALUFN                                   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		ENA, RST, CLK                           : IN STD_LOGIC;
		ALUout                                  : OUT STD_LOGIC_VECTOR((n/2)-1 downto 0);
		Nflag_o,Cflag_o,Zflag_o,Vflag_o,PWM_out : OUT STD_LOGIC
        );
END top;
------------- top Architecture code --------------
ARCHITECTURE rtl OF top IS 
	signal y_sig, x_sig   : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	signal alufn_op       : STD_LOGIC_VECTOR (1 DOWNTO 0);
	signal alufn_mode     : STD_LOGIC_VECTOR (2 DOWNTO 0);
	
	
begin 

	porting :
	alufn_op   <= ALUFN(4 DOWNTO 3);
	alufn_mode <= ALUFN(2 DOWNTO 0);
	x_sig      <= X;
	y_sig      <= Y;
	
	combinatorial : combinatorial_digital_circuit generic map(n/2, k, m)port map (Y_i=>y_sig((n/2)-1 DOWNTO 0) ,X_i=>x_sig((n/2)-1 DOWNTO 0), ALUFN_i=>ALUFN, ALUout_o=>ALUout, Nflag_o=>Nflag_o, Cflag_o=>Cflag_o, Zflag_o=>Zflag_o, Vflag_o=>Vflag_o);
	synchronous   : synchronous_digital_circuit   generic map(n)port map (Y_i=>y_sig, X_i=>x_sig, ALUFN_i=>ALUFN, ENA=>ENA, RST=>RST, CLK=>CLK, PWM_out=>PWM_out);

END rtl;

