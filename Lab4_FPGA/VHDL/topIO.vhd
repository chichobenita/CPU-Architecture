LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
use ieee.numeric_std.all;

---------------entity--------------------
ENTITY topIO IS
  GENERIC (n : INTEGER := 16;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
  PORT (  
		SW                                    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		KEY                                   : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		CLK_50MHz                             : IN  STD_LOGIC ;
		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		LEDR                                  : OUT STD_LOGIC_VECTOR (9 downto 0);
		GPIO                                  : OUT STD_LOGIC 
		
        );
END topIO;
------------- topIO Architecture code --------------
ARCHITECTURE rtl OF topIO IS 
	signal y_sig, x_sig                   : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	signal ALUFN_sig                      : STD_LOGIC_VECTOR (4 DOWNTO 0)  ;
	signal N_FLAG_sig, C_FLAG_sig, Z_FLAG_sig, V_FLAG_sig : STD_LOGIC ;
	signal ALUout_sig                     : STD_LOGIC_VECTOR ((n/2)-1 DOWNTO 0);
	signal mux_to_hex32					  :	STD_LOGIC_VECTOR (7 DOWNTO 0); 
	signal mux_to_hex10					  :	STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal clk 							  : STD_LOGIC;
	
	
	
begin 

	porting :
	LEDR(9 DOWNTO 5) <= ALUFN_sig;
	LEDR(3) <= N_FLAG_sig;
	LEDR(2) <= C_FLAG_sig;
	LEDR(1) <= Z_FLAG_sig;
	LEDR(0) <= V_FLAG_sig;
	
	PLL_PORTING : PLL   port map (inclk0=>CLK_50MHz,c0=>clk);
	DIGIT_SYS   : top   generic map(n,k,m) port map (Y=>y_sig, X=>x_sig, ALUFN=>ALUFN_sig, ENA=>SW(8), RST=>KEY(3), CLK=>clk, ALUout=>ALUout_sig,
																   Nflag_o=>N_FLAG_sig, Cflag_o=>C_FLAG_sig, Zflag_o=>Z_FLAG_sig, Vflag_o=>V_FLAG_sig, PWM_out=>GPIO );

	decoder_to_hex0 : SevenSegDecoder generic map(4,7)    port map (mux_to_hex32(3 DOWNTO 0) , HEX2 );
	
	decoder_to_hex1	: SevenSegDecoder generic map(4,7)    port map (mux_to_hex32(7 DOWNTO 4) , HEX3 );
	
	decoder_to_hex2	: SevenSegDecoder generic map(4,7)    port map (mux_to_hex10(3 DOWNTO 0) , HEX0 );
	
	decoder_to_hex3	: SevenSegDecoder generic map(4,7)    port map (mux_to_hex10(7 DOWNTO 4) , HEX1 );
	
	decoder_to_hex4	: SevenSegDecoder generic map(4,7)    port map (ALUout_sig  (3 DOWNTO 0) , HEX4 );
	
	decoder_to_hex5	: SevenSegDecoder generic map(4,7)    port map (ALUout_sig  (7 DOWNTO 4) , HEX5 );
	
	MuxToHex32 : process(SW(9), y_sig, mux_to_hex32)
				 begin
					if SW(9) = '0' THEN 
						mux_to_hex32 <= y_sig(7 DOWNTO 0);
					else
						mux_to_hex32 <= y_sig(15 DOWNTO 8);
					end if;
				end process;
				
	MuxToHex10:  process(SW(9) , x_sig, mux_to_hex10) 
			     begin 
					if SW(9) = '0' THEN 
						mux_to_hex10 <= x_sig(7 DOWNTO 0);
					else
						mux_to_hex10 <= x_sig(15 DOWNTO 8);
					end if;
				 END process;
				 
	reg_low_y:  process(clk)
				begin
					if rising_edge(clk) THEN
						if KEY(0)='0' AND SW(9) = '0' THEN 
							y_sig(7 DOWNTO 0) <= SW(7 DOWNTO 0);
						end if ;
					end if;
				end process;
				
	reg_high_y: process(clk)
				begin
					if rising_edge(clk) THEN
						if KEY(0)='0' AND SW(9) = '1' THEN 
							y_sig(15 DOWNTO 8) <= SW(7 DOWNTO 0);
						end if; 
					end if;
				end process;	

	reg_ALUFN : process(clk)
				begin
					if rising_edge(clk) THEN
						if KEY(2) = '0' THEN 
							ALUFN_sig <= SW(4 DOWNTO 0);
						end if ;
					end if;
				end process	;				

	reg_low_x:  process(clk)
				begin
					if rising_edge(clk) THEN
						if KEY(1)='0' AND SW(9) = '0' THEN 
							x_sig(7 DOWNTO 0) <= SW(7 DOWNTO 0);
						end if; 
					end if;
				end process;

	reg_high_x: process(clk)
				begin
					if rising_edge(clk) THEN
						if KEY(1)='0' AND SW(9) = '1' THEN 
							x_sig(15 DOWNTO 8) <= SW(7 DOWNTO 0);
						end if ;
					end if;
				end process	;


END rtl;

