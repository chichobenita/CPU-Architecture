library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
entity tb_top is
	constant n : integer := 8;
	constant k : integer := 3;   -- k=log2(n)
	constant m : integer := 4;   -- m=2^(k-1)
end tb_top;
-------------------------------------------------------------------------------
architecture rtb_top of tb_top is
	type mem is array (0 to 19) of std_logic_vector(4 downto 0);
	SIGNAL Y,X:  STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	SIGNAL ALUFN :  STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUout:  STD_LOGIC_VECTOR(n-1 downto 0); -- ALUout[n-1:0]&Cflag
	SIGNAL Nflag,Cflag,Zflag,Vflag: STD_LOGIC; -- Zflag,Cflag,Nflag,Vflag
	SIGNAL cache : mem := (
							"01000","01001","01010","01000","01001","00010","01000","01001","10000","10001",
							"10010","10000","10001","10111","11001","11010","11101","11111","11011","00100");
	
begin
	L0 : top generic map (n,k,m) port map(Y,X,ALUFN,ALUout,Nflag,Cflag,Zflag,Vflag);
   
--------- start of stimulus section ----------------------------------------
        tb_top : process
        begin
------------------ case 1 -----------------------------
			ALUFN <= (others => '0');
			x <= (others => '0');
x(1) <= '1';
x(3) <= '1';
x(5) <= '1';
x(7) <= '1';

y <= (others => '0');
y(1) <= '1';
y(4) <= '1';
y(7) <= '1';

			wait for 10 ns;
			for j in 0 to 19 loop
				ALUFN <= cache(j);
				wait for 10 ns;
			end loop;		  					  
			
    end process tb_top;

end architecture rtb_top;