library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
entity tb is
	constant n : integer := 8;
end tb;
---------------------------------------------------------
architecture rtb of tb is
	signal rst, clk, repeat : std_logic;
	signal upperBound : std_logic_vector(n-1 downto 0);
	signal count : std_logic_vector(n-1 downto 0);
	signal busy	: std_logic;
begin
	L0 : top generic map (n) port map(rst,clk,repeat,upperBound,count,busy);
    
	--------- start of stimulus section ------------------	
        gen_clk : process
        begin
		  clk <= '0';
		  wait for 50 ns;
		  clk <= not clk;
		  wait for 50 ns;
        end process;
				
		gen_upperBound : process
        begin
		  upperBound <= (1=>'1',0=>'0',others => '0');
		  for i in 0 to 2 loop
			wait for 500 ns;
				upperBound <= upperBound+1;
		  end loop;
		  
		  for i in 0 to 1 loop
			wait for 500 ns;
				upperBound <= upperBound-1;
		  end loop;
		  
		  for i in 0 to 2 loop
			wait for 800 ns;
				upperBound <= upperBound+3;
		  end loop;
        end process;
		  
		gen_rst : process
        begin
		  rst <='1'; wait for 250 ns;
		  rst <='0'; wait for 600 ns;
		  rst <='1'; wait for 800 ns;
		  rst <='0'; wait;
        end process;
		
		gen_repeat : process
        begin
		  repeat <=	'1',
					'0' after 1000 ns;
		  wait;
        end process;
		
end architecture rtb;
