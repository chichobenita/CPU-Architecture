library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.all;

---------------------------------------------------------
entity top_tb is
	constant BusSize: integer:=16;
	constant RegSize: integer:=4;
	constant m		: integer:=16;
	constant Awidth : integer:=6;	 
	constant dept   : integer:=64;
	
	
	constant dataMemResult:	 	string(1 to 61) :=
	"C:\Users\ronib\Desktop\simulation\Lab3\TB_txt\DTCMcontent.txt";
	
	constant dataMemLocation: 	string(1 to 59) :=
	"C:\Users\ronib\Desktop\simulation\Lab3\TB_txt\DTCMinit5.txt";
	
	constant progMemLocation: 	string(1 to 59) :=
	"C:\Users\ronib\Desktop\simulation\Lab3\TB_txt\ITCMinit5.txt";
	
end top_tb;
---------------------------------------------------------
architecture rtb of top_tb is

	SIGNAL done_o:												STD_LOGIC := '0';
	SIGNAL rst, ena, clk, TBactive, DTCM_tb_wr, ITCM_tb_wr:     STD_LOGIC;	
	SIGNAL DTCM_tb_in, DTCM_tb_out: 							STD_LOGIC_VECTOR (BusSize-1 downto 0); -- n
	SIGNAL ITCM_tb_in: 											STD_LOGIC_VECTOR (BusSize-1 downto 0); -- m 
	SIGNAL DTCM_tb_addr_in, ITCM_tb_addr_in:  					STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0);
	SIGNAL DTCM_tb_addr_out:									STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0);
	SIGNAL donePmemIn, doneDmemIn:								BOOLEAN;
	
begin
	
	TopUnit: top port map(	done_o, clk, rst, ena, ITCM_tb_wr, DTCM_tb_wr, ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out, ITCM_tb_in, DTCM_tb_in,
							DTCM_tb_out, TBactive);
						
    
	--------- start of stimulus section ------------------	
	
	--------- Rst
	gen_rst : process
	begin
	  rst <='1','0' after 100 ns;
	  wait;
	end process;
	
	------------ Clock
	gen_clk : process
	begin
	  clk <= '0';
	  wait for 50 ns;
	  clk <= not clk;
	  wait for 50 ns;
	end process;
	
	--------- 	TB
	gen_TB : process
        begin
		 TBactive <= '1';
		 wait until donePmemIn and doneDmemIn;  
		 TBactive <= '0';
		 wait until done_o = '1';  
		 TBactive <= '1';	
        end process;	
	
				
				
	--------- --Reading from text file and initializing the data memory data--------
	LoadDataMem: process 
		file inDmemfile : text open read_mode is dataMemLocation;
		variable    linetomem			: std_logic_vector(BusSize-1 downto 0);
		variable	good				: boolean;
		variable 	L 					: line;
		variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; -- Awidth
	begin 
		doneDmemIn <= false;
		TempAddresses := (others => '0');
		while not endfile(inDmemfile) loop
			readline(inDmemfile,L);
			hread(L,linetomem,good);
			next when not good;
			DTCM_tb_wr <= '1';
			DTCM_tb_addr_in <= TempAddresses;
			DTCM_tb_in <= linetomem;
			wait until rising_edge(clk);
			TempAddresses := TempAddresses +1;
		end loop ;
		DTCM_tb_wr <= '0';
		doneDmemIn <= true;
		file_close(inDmemfile);
		wait;
	end process;
		
		
	--------- Reading from text file and initializing the program memory instructions ------
	LoadProgramMem: process 
		file inPmemfile : text open read_mode is progMemLocation;
		variable    linetomem			: std_logic_vector(BusSize-1 downto 0); 
		variable	good				: boolean;
		variable 	L 					: line;
		variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; -- Awidth
	begin 
		donePmemIn <= false;
		TempAddresses := (others => '0');
		while not endfile(inPmemfile) loop
			readline(inPmemfile,L);
			hread(L,linetomem,good);
			next when not good;
			ITCM_tb_wr <= '1';
			ITCM_tb_addr_in <= TempAddresses;
			ITCM_tb_in <= linetomem;
			wait until rising_edge(clk);
			TempAddresses := TempAddresses +1;
		end loop ;
		ITCM_tb_wr <= '0';
		donePmemIn <= true;
		file_close(inPmemfile);
		wait;
	end process;
	

	ena <= '1' when (doneDmemIn and donePmemIn) else '0';
	
		
	--------- Writing from Data memory to external text file, after the program ends (done_o = 1). -----
	WriteToDataMem: process 
		file outDmemfile : text open write_mode is dataMemResult;
		variable    linetomem			: std_logic_vector(BusSize-1 downto 0);
		variable	good				: boolean;
		variable 	L 					: line;
		variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; -- Awidth
		variable 	counter				: integer;
	begin 
		wait until done_o = '1';  
		TempAddresses := (others => '0');
		counter := 1;
		while counter < 43 loop	
			DTCM_tb_addr_out <= TempAddresses;
			wait until rising_edge(clk);
			wait until rising_edge(clk); 
			hwrite(L,DTCM_tb_out);
			writeline(outDmemfile,L);
			TempAddresses := TempAddresses +1;
			counter := counter +1;
		end loop ;
		file_close(outDmemfile);
		wait;
	end process;
		

end architecture rtb;