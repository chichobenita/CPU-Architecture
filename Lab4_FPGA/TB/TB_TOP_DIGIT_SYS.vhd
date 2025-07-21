LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.aux_package.all;

ENTITY TB_TOP_DIGIT_SYS IS
END TB_TOP_DIGIT_SYS;

ARCHITECTURE rtl OF TB_TOP_DIGIT_SYS IS

  CONSTANT n : INTEGER := 16;
  CONSTANT k : INTEGER := 3;
  CONSTANT m : INTEGER := 4;

	type mem is array (0 to 20) of std_logic_vector(4 downto 0);
	SIGNAL Y_i,X_i						  : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	SIGNAL ALUFN_i 						  : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUout_o                       : STD_LOGIC_VECTOR((n/2)-1 downto 0); 
	SIGNAL Nflag_o,Cflag_o,Zflag_o,Vflag_o: STD_LOGIC; 
    SIGNAL PWM_o                          : STD_LOGIC;
    SIGNAL clk, rst, ENA                  : STD_LOGIC;
	---SIGNAL cache : mem := ("01000","01001","01010","01011","01100","01101","10000","10001","11000","11001",
						---	"11010","11011","11100","11101","11110","00000","00001","00010","00011","00100","00101");  
	CONSTANT cache : mem := (
    0  => "01000",
    1  => "01001",
    2  => "01010",
    3  => "01011",
    4  => "01100",
    5  => "01101",
    6  => "10000",
    7  => "10001",
    8  => "11000",
    9  => "11001",
    10 => "11010",
    11 => "11011",
    12 => "11100",
    13 => "11101",
    14 => "11110",
    15 => "00000",
    16 => "00001",
    17 => "00010",
    18 => "00011",
    19 => "00100",
    20 => "00101"
);

  
  
  

  ---SIGNAL clk         : std_logic := '0';
  ---SIGNAL rst         : std_logic := '1';
  ---SIGNAL ENA         : std_logic := '0';
  ---SIGNAL X_i, Y_i    : std_logic_vector(n-1 DOWNTO 0) := (others => '0');
  ---SIGNAL ALUFN_i     : std_logic_vector(4 DOWNTO 0) := (others => '0');
  ---SIGNAL PWM_o       : std_logic;
  ---SIGNAL ALUout_o    : std_logic_vector(7 DOWNTO 0);
  ---SIGNAL Nflag_o     : std_logic;
  ---SIGNAL Cflag_o     : std_logic;
  ---SIGNAL Zflag_o     : std_logic;
  ---SIGNAL Vflag_o     : std_logic;

BEGIN

  -- Instantiate the DUT
  PortToEntity : top
    GENERIC MAP (n , k , m )
    PORT MAP (
      CLK        => clk,
      RST        => rst,
      ENA        => ENA,
      X          => X_i,
      Y          => Y_i,
      ALUFN      => ALUFN_i,
      PWM_out    => PWM_o,
      ALUout     => ALUout_o,
      Nflag_o    => Nflag_o,
      Cflag_o    => Cflag_o,
      Zflag_o    => Zflag_o,
      Vflag_o    => Vflag_o
    );


    -- Clock generation process
   gen_clk : process
   begin
       clk <= '1';
       wait for 50 ns;
       clk <= '0';
       wait for 50 ns;
   end process;

   -- Reset process
   gen_rst : process
   begin
       rst <= '1', '0' after 100 ns;
       wait;
   end process;
--------- start of stimulus section ----------------------------------------
        TB_TOP_DIGIT_SYS : process
        begin
------------------ Edge case 1: All ones-----------------------------
			ALUFN_i <= (others => '0');
			X_i <= (others => '1');
			Y_i <= (others => '1');
			wait for 100 ns;
			for j in 0 to 17 loop
				ALUFN_i <= cache(j);
				wait for 25 ns;
			end loop;		  					  
 			
----------------- Edge case 2: single bit is set-------------------
			ALUFN_i <= (others => '0');
			Y_i <= (others => '0');	
			X_i <= (others => '0');
		    Y_i((n/2)-1) <= '1'; 
			X_i(0) <= '1';
			wait for 25 ns;
			for j in 0 to 17 loop
				ALUFN_i <= cache(j);
				wait for 25 ns;
			end loop;
			
----------------- Edge case 2 -------------------------------
			ALUFN_i <= (others => '0');
			X_i <= (others => '0');
			Y_i <= "0000000010100101";
			wait for 25 ns;
			for j in 0 to 17 loop
				ALUFN_i <= cache(j);
				wait for 25 ns;
			end loop;
			
----------------- Edge case PMW: mode 0---------------------------------
			ENA <= '1';

			
            ---ALUFN
            ALUFN_i <= (others => '0');
            -----X
            X_i <= "0000000000000100";
			Y_i <= "0000000000001000";
            wait for 1000 ns;


            -- Edge case PMW: mode 1
            
            ALUFN_i(4 downto 0) <= (others => '0');
            ALUFN_i(0) <= '1';

            
            X_i <= "0000000000000100";
			Y_i <= "0000000000001000";
            wait for 1000 ns;
			
			-- Edge case PMW: mode 3
            
            ALUFN_i <= "00010";

            
            X_i <= "0000000000000100";
			Y_i <= "0000000000001000";
			wait for 1000 ns;
                wait; -- Wait indefinitely after all edge cases are tested
    end process TB_TOP_DIGIT_SYS;    



END rtl;
