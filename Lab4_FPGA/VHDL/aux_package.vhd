library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package aux_package is
--------------------------------------------------------
	component top is
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
	port( x,y  : in std_logic_vector (n-1 downto 0);
		  dir  : in std_logic_vector (2 downto 0);--- direction vector : for "000" SHL, for "001" SHR
		  res  : out std_logic_vector (n-1 downto 0);--- result
		  cout : out std_logic
		  );--- carry out
	end component;
---------------------------------------------------------	
    component AdderSub is
	
	generic (n : integer := 4);
	port(	xin, yin:in std_logic_vector(n-1 downto 0);
			op_mode: in std_logic_vector(2 downto 0);
			res: out std_logic_vector(n-1 downto 0);
			cout: out std_logic;
		    v   : out std_logic
			);
	end component;
---------------------------------------------------------	
	component logic is
	
	generic (n : integer := 4);
	port( xin, yin :in std_logic_vector(n-1 downto 0);
				op_mode: in std_logic_vector(2 downto 0);
				res : out std_logic_vector(n-1 downto 0)
		);
	end component;
---------------------------------------------------------	
    component digital_circuit is
	
	generic (n : integer := 16);
	port( x,y                  : in std_logic_vector(n-1 downto 0);
			pwm_mode           : in std_logic_vector(2 downto 0);
			counter_16_bit     : in std_logic_vector(15 downto 0);
			clk, enable, reset : in std_logic;
			pwm_out            : out std_logic;
			EQUY               : out  STD_LOGIC
		);
	end component;
---------------------------------------------------------	
	component counter16bit is
	
	Port (
		clk    : in  STD_LOGIC;
		reset  : in  STD_LOGIC;
		enable : in  STD_LOGIC;
		count  : out STD_LOGIC_VECTOR (15 downto 0);
        EQUY   : in  STD_LOGIC
		  );
	end component;
---------------------------------------------------------	
    component PWM is
	
    generic (n : integer := 16);
    port (
        x, y     : in std_logic_vector(n-1 downto 0);
        pwm_mode     : in std_logic_vector(2 downto 0);
        rst, en, clk : in std_logic;
		pwm_out      : out std_logic 
		 );
	end component;
---------------------------------------------------------	
    component synchronous_digital_circuit is
    
	generic (n : INTEGER := 16);
	port (  
	      Y_i,X_i       : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  ALUFN_i       : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  ENA, RST, CLK : IN STD_LOGIC;
		  PWM_out       : OUT STD_LOGIC
		  );
	end component;
---------------------------------------------------------	
    component combinatorial_digital_circuit is
    
	GENERIC (n : INTEGER := 8;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
	PORT (  
		  Y_i,X_i : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  ALUout_o: OUT STD_LOGIC_VECTOR(n-1 downto 0);
		  Nflag_o,Cflag_o,Zflag_o,Vflag_o: OUT STD_LOGIC
          );
	end component;
---------------------------------------------------------
	component SevenSegDecoder IS
    GENERIC (	n			: INTEGER := 4;
			    SegmentSize	: integer := 7
			);
    PORT (data		: in STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  seg       : out STD_LOGIC_VECTOR (SegmentSize-1 downto 0)
		  );
    END component;
---------------------------------------------------------
	component TB_TOP_DIGIT_SYS IS
	END component;
	
---------------------------------------------------------
	component topIO IS
	GENERIC (n : INTEGER := 16;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
	PORT (  
			SW                                    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
			KEY                                   : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			CLK_50MHz                             : IN  STD_LOGIC ;
			HEX                                   : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			LEDR                                  : OUT STD_LOGIC_VECTOR (9 downto 0);
			GPIO                                  : OUT STD_LOGIC 
		
          );
	END component;
	
---------------------------------------------------------
  component fmax_wrapper IS
  GENERIC (
    n : INTEGER := 16;
    k : INTEGER := 3;
    m : INTEGER := 4
  );
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    pwm_out : OUT STD_LOGIC;
    alu_out_reg : OUT STD_LOGIC_VECTOR((n/2)-1 DOWNTO 0);
    N_out, C_out, Z_out, V_out : OUT STD_LOGIC
  );
 END component;
 
	
--------------------------------------------------------- 

  component PLL IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		    : OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
  END component;
	
end aux_package;

