LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;
use ieee.numeric_std.all;

---------------entity--------------
ENTITY combinatorial_digital_circuit IS
  GENERIC (n : INTEGER := 8;
		   k : integer := 3;  -- k=log2(n)
		   m : integer := 4); -- m=2^(k-1)
  PORT 
  (  
	      Y_i,X_i    : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  ALUFN_i    : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  ALUout_o   : OUT STD_LOGIC_VECTOR(n-1 downto 0);
		  Nflag_o,Cflag_o,Zflag_o,Vflag_o : OUT STD_LOGIC
  ); 
END combinatorial_digital_circuit;
------------- complete the top Architecture code --------------
ARCHITECTURE rtl OF combinatorial_digital_circuit IS 
	signal y_in, x_in            : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	signal alufn_op              : STD_LOGIC_VECTOR (1 DOWNTO 0);
	signal alufn_mode            : STD_LOGIC_VECTOR (2 DOWNTO 0);
	signal x_ad,y_ad,x_log,y_log,x_shift,y_shift : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	signal ad_out,log_out,shift_out : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	signal ad_c,ad_v,shift_c     : STD_LOGIC;
	signal ALUout_sig            : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	constant zero_vector         : STD_LOGIC_VECTOR (n-1 downto 0) := (others => '0');
	
begin 

	porting :
	alufn_op   <= ALUFN_i(4 DOWNTO 3);
	alufn_mode <= ALUFN_i(2 DOWNTO 0);
	x_in       <= X_i;
	y_in       <= Y_i;
	ALUout_o   <= ALUout_sig ;
	
	x_ad <= x_in when alufn_op = "01" else 
			zero_vector;
	
	y_ad <= y_in when alufn_op = "01" else 
			zero_vector;
	
	x_log <= x_in when alufn_op = "11" else 
			zero_vector;
	
	y_log <= y_in when alufn_op = "11" else 
			zero_vector;
			
			
	x_shift <= x_in when alufn_op = "10" else 
			zero_vector;
	
	y_shift <= y_in when alufn_op = "10" else 
			zero_vector;
			
	
	ad :  AdderSub generic map(n)port map (xin=>x_ad,yin=>y_ad,op_mode=>alufn_mode,res=>ad_out,cout=>ad_c,v=>ad_v);
	log : Logic generic map(n)port map (xin => x_log, yin => y_log, op_mode => alufn_mode, res => log_out);
	shift :  Shifter generic map(n,k)port map (x=>x_shift,y=>y_shift,dir=>alufn_mode,res=>shift_out,cout=>shift_c);
	
	ALUout_sig <= ad_out when alufn_op = "01" else
				log_out when alufn_op = "11" else
				shift_out when alufn_op = "10" else 
				zero_vector;
	Vflag_o <= ad_v when alufn_op = "01" else 
				'0';
	Zflag_o <= '1' when (ALUout_sig = zero_vector OR alufn_op = "00") else
				'0';
	Cflag_o <= ad_c when alufn_op = "01" else
			   shift_c when alufn_op = "10" else
			   '0';
	Nflag_o <= '1' when ALUout_sig(n-1) = '1' else 
			   '0';

END rtl;

