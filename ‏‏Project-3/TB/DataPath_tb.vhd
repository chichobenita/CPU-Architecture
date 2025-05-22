library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity datapth_tb is
	generic(BusSize : integer := 16;
			Awidth:  integer:=6;  	-- Address Size
			RegSize: integer:=4; 	-- Register Size
			m: 	  integer:=16);  -- Program Memory In Data Size

    
	constant dataMemResult:	 	string(1 to 61) :=
	"C:\Users\ronib\Desktop\simulation\Lab3\TB_txt\DTCMcontent.txt";
	
	constant dataMemLocation: 	string(1 to 59) :=
	"C:\Users\ronib\Desktop\simulation\Lab3\TB_txt\DTCMinit1.txt";
	
	constant progMemLocation: 	string(1 to 59) :=
	"C:\Users\ronib\Desktop\simulation\Lab3\TB_txt\ITCMinit1.txt";
    end datapth_tb;
    
architecture tb of datapth_tb is

    signal		st, ld, mov, done, add, sub, jmp, jc, jnc, xor_o, or_o, and_o, Cflag, Zflag, Nflag:  std_logic;
	signal		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_out, DTCM_addr_in, DTCM_addr_out, DTCM_addr_sel : std_logic;
	signal		ALFUN :  std_logic_vector(3 downto 0);
	signal		PCsel, RFaddr_rd, RFaddr_wr : std_logic_vector(1 downto 0); 
	signal      done_FSM :  std_logic;
    signal 		TBactive, clk, rst : std_logic;
    signal 		ITCM_tb_wr, DTCM_tb_wr : std_logic;
    signal 		DTCM_tb_in    : std_logic_vector(BusSize-1 downto 0);
    signal 		ITCM_tb_in    : std_logic_vector(m-1 downto 0);
    signal 		ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out : std_logic_vector(Awidth-1 downto 0);
    signal 		DTCM_tb_out   : std_logic_vector(BusSize-1 downto 0);
    signal 	    donePmemIn, doneDmemIn:	 BOOLEAN;
    begin 

	
	DataPathUnit: Datapath generic map(BusSize)  port map(DTCM_wr=>DTCM_wr,DTCM_addr_out=>DTCM_addr_out,DTCM_addr_in=>DTCM_addr_in,DTCM_out=>DTCM_out,Ain=>Ain,RFin=>RFin
														,RFout=>RFout,IRin=>IRin,PCin=>PCin,Imm1_in=>Imm1_in,Imm2_in=>Imm2_in,clk=>clk,rst=>rst,ALFUN=>ALFUN
														,RFaddr_rd=>RFaddr_rd,RFaddr_wr=>RFaddr_wr,PCsel=>PCsel,ITCM_tb_wr=>ITCM_tb_wr,DTCM_tb_wr=>DTCM_tb_wr
														,DTCM_addr_sel=>DTCM_addr_sel,TBactive=>TBactive,ITCM_tb_in=>ITCM_tb_in,DTCM_tb_in=>DTCM_tb_in
														,ITCM_tb_addr_in=>ITCM_tb_addr_in,DTCM_tb_addr_in=>DTCM_tb_addr_in,DTCM_tb_addr_out=>DTCM_tb_addr_out,st=>st,ld=>ld
														,mov=>mov,done=>done,add=>add,sub=>sub,jmp=>jmp,jc=>jc,jnc=>jnc,and_o=>and_o,or_o=>or_o,xor_o=>xor_o
														,Cflag=>Cflag,Nflag=>Nflag,Zflag=>Zflag,DTCM_tb_out=>DTCM_tb_out);
--------- Clock
gen_clk : process
	begin
	  clk <= '0';
	  wait for 50 ns;
	  clk <= not clk;
	  wait for 50 ns;
	end process;

--------- Reset
gen_rst : process
        begin
		  rst <='1','0' after 100 ns;
		  wait;
        end process;	
--------- TB
gen_TB : process
	begin
	 TBactive <= '1';
	 wait until donePmemIn and doneDmemIn;  
	 TBactive <= '0';
	 wait until done_FSM = '1';  
	 TBactive <= '1';	
	end process;	
	
	
--------- Reading from text file and initializing the data memory data--------------
LoadDataMem:process 
	file inDmemfile : text open read_mode is dataMemLocation;
	variable    linetomem			: std_logic_vector(BusSize-1 downto 0);
	variable	good				: boolean;
	variable 	L 					: line;
	variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; 
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

--------- Reading from text file and initializing the program memory instructions	
LoadProgramMem:process 
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

Tb : process
	begin
		wait until donePmemIn and doneDmemIn;  

    ------------- Reset ------------------------		
		wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "1111";  -- unaffected
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout	     <= '0';
		RFaddr_rd	 <= "00";   
		RFaddr_wr    <= "00";
		IRin	     <= '0';
		PCin	     <= '1';
		PCsel	     <= "00";   -- PC = zeros
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
    ---------------- Fetch ---------------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "1111"; -- unaffected
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout	     <= '0';
		RFaddr_rd	 <= "00";   
		RFaddr_wr    <= "00";
		IRin	     <= '1';    -- IR  Output
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
    ---------------- Decode -----D303 ld 3,2-------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		Ain	 	     <= '0'; 
		RFin	     <= '0';
		RFout	     <= '0';  
		RFaddr_rd	 <= "01";   -- rb out
		RFaddr_wr	 <= "00";   
		IRin 	     <= '0';
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1			
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
		Ain	 	 	 <= '1'; -- saves to reg a
		ALFUN    	 <= "0101"; -- c = b
		RFout		 <= '1';	
    -------------- ItypeState0-----ld 3,2----------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "0000"; 	
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout		 <= '0';
		RFaddr_rd	 <= "00";
		RFaddr_wr	 <= "00";				
		IRin		 <= '0';
		PCin		 <= '0';
		PCsel		 <= "01";	
		Imm1_in		 <= '0';
		Imm2_in		 <= '1';
		DTCM_out	 <= '0';			
		done_FSM  	 <= '0';
		DTCM_addr_sel<= '1';
		DTCM_addr_in	 <= '0';
		DTCM_addr_out	 <= '1';
		---------- ItypeState1-----ld 3,2-----------
        wait until rising_edge(clk);
		Ain	 	 	<= '0';				
		RFaddr_rd	<= "10";  --ra
		RFaddr_wr	<= "10";  --ra
		IRin	 	<= '0';
		PCin		<= '0';
		PCsel	 	<= "01";	
		Imm1_in	 	<= '0';
		Imm2_in	 	<= '0';	
		DTCM_addr_sel<='0';
		done_FSM    <= '0';
		DTCM_addr_in	 <= '0'; 
		DTCM_addr_out	 <= '0'; 
		DTCM_wr	 <= '0'; 
		DTCM_out <= '1';  
		RFin	 <= '0';
		ALFUN    <= "0101";
		RFout    <= '0';
    -------------- ItypeState2-------ld 3,2---------
        wait until rising_edge(clk);                	
		Ain	 	 	 <= '0';				
		RFaddr_rd	 <= "10";  --ra
		RFaddr_wr	 <= "10";  --ra
		IRin	 	 <= '0';
		PCin		 <= '1';
		PCsel	 	 <= "01";	
		Imm1_in	 	 <= '0';
		Imm2_in	 	 <= '0';	
		DTCM_addr_sel<='0';
		done_FSM     <= '0';
		DTCM_addr_in	 <= '0'; 
		DTCM_addr_out	 <= '0';
		DTCM_wr	     <= '0'; 
		DTCM_out     <= '1';  
		RFin	     <= '1';
		ALFUN        <= "0101";
		RFout        <= '0';          
---------------- Fetch ---------------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "1111"; -- unaffected
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout	     <= '0';
		RFaddr_rd	 <= "00";   
		RFaddr_wr    <= "00";
		IRin	     <= '1';    -- IR  Output
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
    ---------------- Decode ---C205 mov 2,5--------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		Ain	 	     <= '0'; 
		RFout	     <= '0';  
		RFaddr_rd	 <= "01";   
		IRin 	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1			
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
		RFin	 <= '1';
		PCin	 <= '1';	
		RFaddr_wr<= "10";   --Ra
		Imm1_in	 <= '1';
		ALFUN    <="0101";
    ---------------- Fetch ---------------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "1111"; -- unaffected
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout	     <= '0';
		RFaddr_rd	 <= "00";   
		RFaddr_wr    <= "00";
		IRin	     <= '1';    -- IR  Output
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
    ---------------- Decode ----0432 add 4,3,2 --------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		RFin	     <= '0';
		RFaddr_rd	 <= "01";   -- rb out
		RFaddr_wr	 <= "00";   
		IRin 	     <= '0';
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1			
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
		Ain 	<= '1';
		ALFUN   <= "0101";
		RFout	<= '1';
    -------------- RtypeState0-----add 4,3,2-----------
        wait until rising_edge(clk);
		DTCM_wr	 	 <= '0';
		Ain	 		 <= '0';
		RFin	     <= '1';
		RFout	     <= '1';  
		RFaddr_rd	 <= "00";  -- Rc out to  BUS B  
		RFaddr_wr	 <= "10";  -- write to Ra 
		IRin	     <= '0';
		PCin	     <= '1';
		PCsel	     <= "01";	
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0'; 
		ALFUN <= "0000";
    ---------------- Fetch ---------------------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "1111"; -- unaffected
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout	     <= '0';
		RFaddr_rd	 <= "00";   
		RFaddr_wr    <= "00";
		IRin	     <= '1';    -- IR  Output
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0'; 
    ---------------- Decode -----E401 --st 4,1--------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		Ain	 	     <= '0'; 
		RFin	     <= '0';
		RFout	     <= '0';  
		RFaddr_rd	 <= "01";   -- rb out
		RFaddr_wr	 <= "00";   
		IRin 	     <= '0';
		PCin	     <= '0';
		PCsel	     <= "01";	-- PC = PC + 1			
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM     <= '0';
		Ain	 	 	 <= '1'; -- saves to reg a
		ALFUN    	 <= "0101"; -- c = b
		RFout		 <= '1';	
    -------------- ItypeState0-----st 4,1----------
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "0000"; 	
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout		 <= '0';
		RFaddr_rd	 <= "00";
		RFaddr_wr	 <= "00";				
		IRin		 <= '0';
		PCin		 <= '0';
		PCsel		 <= "01";	
		Imm1_in		 <= '0';
		Imm2_in		 <= '1';
		DTCM_out	 <= '0';			
		done_FSM  	 <= '0';
		DTCM_addr_sel<= '1';
		DTCM_addr_in	 <= '1'; 
		DTCM_addr_out	 <= '0';
    -------------- ItypeState1-----st 4,1-----------
        wait until rising_edge(clk);
		Ain	 	 	<= '0';				
		RFaddr_rd	<= "10";  --ra
		RFaddr_wr	<= "10";  --ra
		IRin	 	<= '0';
		PCsel	 	<= "01";	
		Imm1_in	 	<= '0';
		Imm2_in	 	<= '0';	
		DTCM_addr_sel<='0';
		done_FSM    <= '0';
		DTCM_addr_in	 <= '0'; 
		DTCM_addr_out	 <= '0';
		PCin	 <= '1';
		DTCM_wr	 <= '1'; 
		DTCM_out <= '0';	
		RFout    <= '1'; 
		RFin	 <= '0';
		ALFUN    <= "1111"; -- unaffected		  
    ------------- Reset -------FINISH-------------		
        wait until rising_edge(clk);
		DTCM_wr	     <= '0';
		ALFUN	 	 <= "1111";  -- unaffected
		Ain	 	     <= '0';
		RFin	     <= '0';
		RFout	     <= '0';
		RFaddr_rd	 <= "00";   
		RFaddr_wr    <= "00";
		IRin	     <= '1';
		PCin	     <= '1';
		PCsel	     <= "00";   -- PC = zeros
		Imm1_in	     <= '0';
		Imm2_in	     <= '0';
		DTCM_out	 <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_out<= '0';
		DTCM_addr_sel<= '0';
		done_FSM  <= '1';
		wait;
		
	end process;

    WriteToDataMem:process 
		file outDmemfile : text open write_mode is dataMemResult;
		variable    linetomem			: STD_LOGIC_VECTOR(BusSize-1 downto 0);
		variable	good				: BOOLEAN;
		variable 	L 					: LINE;
		variable	TempAddresses		: STD_LOGIC_VECTOR(Awidth-1 downto 0) ; 
	begin 

		wait until done_FSM = '1';  
		TempAddresses := (others => '0');
		while TempAddresses < 3 loop	--3 lines in file
			DTCM_tb_addr_out <= TempAddresses;
			wait until rising_edge(clk);   -- 
			wait until rising_edge(clk); -- 
			linetomem := DTCM_tb_out;   --
			hwrite(L,linetomem);
			writeline(outDmemfile,L);
			TempAddresses := TempAddresses +1;
		end loop ;
		file_close(outDmemfile);
		wait;
	end process;

end tb;