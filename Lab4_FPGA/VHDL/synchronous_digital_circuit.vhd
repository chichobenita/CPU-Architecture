LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
use ieee.numeric_std.all;

-------------entity----------------------------------
ENTITY synchronous_digital_circuit IS
  GENERIC (n : INTEGER := 16);

  PORT 
  (  
	      Y_i,X_i       : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  ALUFN_i       : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  ENA, RST, CLK : IN STD_LOGIC;
		  PWM_out       : OUT STD_LOGIC
		  
  );
END synchronous_digital_circuit;
------------- complete the synchronous_digital_circuit Architecture code --------------
ARCHITECTURE rtl OF synchronous_digital_circuit IS 
	signal y_in, x_in        				 : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	signal alufn_op          				 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	signal alufn_mode                        : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal Y_to_PWM, X_to_PWM                : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	signal EN_to_PWM, RST_to_PWM, CLK_to_PWM, PWM_out_sig : STD_LOGIC;
	constant zero_vector                     : STD_LOGIC_VECTOR(n-1 downto 0) := (others => '0');
	
begin 

	porting :
	alufn_op   <= ALUFN_i(4 DOWNTO 3);
	alufn_mode <= ALUFN_i(2 DOWNTO 0);
	x_in       <= X_i;
	y_in       <= Y_i;
	
	RST_to_PWM <= RST;
	CLK_to_PWM <= CLK;
	PWM_out    <= PWM_out_sig;
	
	X_to_PWM <= x_in when alufn_op = "00" else 
			zero_vector;
	
	Y_to_PWM <= y_in when alufn_op = "00" else 
			zero_vector;
	
	EN_to_PWM <= ENA when alufn_op = "00" else 
			'0';
	
			
	port_to_pwm :  PWM generic map(n)port map (x=>X_to_PWM, y=>Y_to_PWM, pwm_mode=>alufn_mode, rst=>RST_to_PWM, en=>EN_to_PWM, clk=>CLK_to_PWM, pwm_out=>PWM_out_sig);
	
END rtl;

