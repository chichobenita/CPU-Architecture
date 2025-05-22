LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE work.aux_package.all;
---------------------------------------
entity control is
port( 	shl,st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,Cflag,Nflag,Zflag						: in std_logic;
		clk, rst, ena 																				: in std_logic;
		DTCM_wr,DTCM_addr_out,DTCM_addr_in,DTCM_out,Ain,RFin,RFout,IRin,PCin,Imm1_in,Imm2_in,done_o	: out std_logic;     
		ALFUN 																						: out std_logic_vector (3 downto 0);	
		RFaddr_rd,RFaddr_wr,PCsel				 													: out std_logic_vector (1 downto 0);
		DTCM_addr_sel																				: out std_logic
		);
end control;
---------------------------------------
architecture behav of control is
type state is (reset,fetch,ID,R_EX,I_EX,I_MEM,R_WB,I_MEM_2,I_MEM_3);
signal cur_state,next_state : state;

begin
----------change state on clock rising-------------------------
state_process : process(clk, rst)
begin 
	if (rst = '1') then
		cur_state <= reset;
	elsif ((clk'EVENT AND clk='1') and ena = '1') then
            cur_state <= next_state;
			report "cur state = " & to_string(cur_state)
			& LF & "time =       " & to_string(now) ;
        end if;
    end process;
-----------------FSM logic-------------------
control_unit : process (cur_state,st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,Cflag,Nflag,Zflag)
begin
	case cur_state is
		---------------- Reset ---------------------
		when reset =>
			if done = '0' then
				DTCM_wr	     	<= '0';
				ALFUN	 		<= "0000";  -- unaffected
				Ain	 	    	<= '0';
				RFin	    	<= '0';
				RFout	     	<= '0';
				RFaddr_rd	 	<= "00";   
				RFaddr_wr	 	<= "00";
				IRin	     	<= '0';
				PCin	     	<= '1';
				PCsel	     	<= "00";   -- PC = "0...0...0"
				Imm1_in	     	<= '0';
				Imm2_in	     	<= '0';
				DTCM_out	 	<= '0';
				DTCM_addr_in 	<= '0';
				DTCM_addr_out	<= '0';
				DTCM_addr_sel	<= '0';
				done_o     		<= '0';
				next_state    	<= fetch;
				end if;
		---------------- fetch(IF) ---------------------
		when fetch =>
				DTCM_wr	     	<= '0';
				ALFUN	 		<= "0000";  -- unaffected
				Ain	 	    	<= '0';
				RFin	    	<= '0';
				RFout	     	<= '0';
				RFaddr_rd	 	<= "00";   
				RFaddr_wr	 	<= "00";
				IRin	     	<= '1';
				PCin	     	<= '0';
				PCsel	     	<= "00";   -- PC = "0...0...0"
				Imm1_in	     	<= '0';
				Imm2_in	     	<= '0';
				DTCM_out	 	<= '0';
				DTCM_addr_in 	<= '0';
				DTCM_addr_out	<= '0';
				DTCM_addr_sel	<= '0';
				done_o     		<= '0';
				next_state    	<= ID;
		---------------- decode(ID) ---------------------
		when ID =>
				DTCM_wr	     	<= '0';
				IRin	     	<= '0';
				DTCM_out	 	<= '0';
				DTCM_addr_in 	<= '0';
				DTCM_addr_out	<= '0';
				DTCM_addr_sel	<= '0';
				done_o     		<= '0';
				RFaddr_rd		<= "01";   -- choose rb
				RFaddr_wr		<= "00";
				RFout			<= '0';	   -- BusB <- R[rb]
				ALFUN			<= "0111"; -- C=B
				Ain				<= '1';	   -- regA = B
				Imm1_in			<= '0';
				Imm2_in			<= '0';
				RFin			<= '0';	
				PCsel			<= "00";
				PCin			<= '0';
				
				-------R-type-----regA <- R[rb]-----
				if (add = '1' or sub = '1' or and_o = '1' or or_o = '1' or xor_o = '1'or shl = '1') then
					RFaddr_rd	<= "01";   -- choose rb
					RFaddr_wr	<= "00";
					RFout		<= '1';	   -- BusB <- R[rb]
					ALFUN		<= "0111"; -- C=B
					Ain			<= '1';	   -- regA = B
					Imm1_in		<= '0';
					Imm2_in		<= '0';
					RFin		<= '0';	
					PCsel		<= "00";
					PCin		<= '0';
					next_state  <= R_EX;
				-------J-type-----PC+1+offset-----
				elsif (jmp = '1' or jc = '1' or jnc = '1') then
					RFaddr_rd	<= "01";   	-- choose rb
					RFaddr_wr	<= "00";
					RFout		<= '0';	   
					ALFUN		<= "0000"; 	-- unaffected
					Ain			<= '0';				
					Imm1_in		<= '0';
					Imm2_in		<= '0';
					RFin		<= '0';
					next_state  <= fetch;
					if (jmp = '1' or (jc = '1' and Cflag = '1') or (jnc = '1' and Cflag = '0'))then
						PCsel		<= "10";	-- choose PC+1+offset
						PCin		<= '1';		-- Allows the PC_reg to receive
					else
						PCsel		<= "01";	-- choose PC+1
						PCin		<= '1';		-- Allows the PC_reg to receive
					end if;
				-------I-type-----R[ra] <- imm / regA <- imm -----
				elsif (mov = '1' or ld = '1' or st = '1') then
									
									--R[ra] <- imm--
					if (mov = '1') then			
						RFaddr_rd	<= "00";   
						RFaddr_wr	<= "10";   	-- write to R[ra] 
						RFout		<= '0';	   
						ALFUN		<= "0111"; 	-- C=B
						Ain			<= '0';	   
						Imm1_in		<= '1';		-- BusB <- imm1
						Imm2_in		<= '0';
						RFin		<= '1';		-- Allows the RF to receive
						PCsel		<= "01";	-- choose PC+1
						PCin		<= '1';		-- Allows the PC_reg to receive
						next_state  <= fetch;
					
									--regA <- imm --
					else
						RFaddr_rd	<= "01";   
						RFaddr_wr	<= "00";   	 
						RFout		<= '0';	   
						ALFUN		<= "0111"; 	-- C=B
						Ain			<= '1';	   
						Imm1_in		<= '0';		
						Imm2_in		<= '1';		-- BusB <- imm2
						RFin		<= '0';		-- Allows the RF to receive
						PCsel		<= "01";	-- choose PC+1
						PCin		<= '0';		
						next_state  <= I_EX;
					end if;
				-----done---
				elsif done = '1' then
					PCin	 	<= '0';
					done_o 		<= '1';
					next_state 	<= reset;
				else
					next_state 	<= fetch;
				end if;
		
		---------------- R_EX(R-type excute) ---------------------		
			when R_EX =>
				DTCM_wr	     	<= '0'; 
				Ain	 	    	<= '0';
				RFin	    	<= '1';
				RFout	     	<= '1';		-- BusB <- R[rc]		
				RFaddr_rd	 	<= "00"; 	-- reading rc  
				RFaddr_wr	 	<= "10";	-- writing to ra
				IRin	     	<= '0';
				PCin	     	<= '1';
				PCsel	     	<= "01";   	-- choose PC+1
				Imm1_in	     	<= '0';
				Imm2_in	     	<= '0';
				DTCM_out	 	<= '0';
				DTCM_addr_in 	<= '0';
				DTCM_addr_out	<= '0';
				DTCM_addr_sel	<= '0';
				done_o     		<= '0';
				next_state    	<= fetch;
				
				if (add = '1') then
					ALFUN <= "1000";
				elsif(sub = '1') then
					ALFUN <= "1001";
				elsif(and_o = '1') then
					ALFUN <= "0010";
				elsif(or_o = '1') then
					ALFUN <= "0011";
				elsif(xor_o = '1') then
					ALFUN <= "0100";
				elsif(shl = '1') then
					ALFUN <= "0101";
				end if;
			
			
				---------------- I_EX(I-type excute) ---------------------
			when I_EX =>
				DTCM_wr	     	<= '0';
				ALFUN			<= "1000"; 	
				Ain	 	    	<= '0';
				RFin	    	<= '0';		
				RFout	     	<= '1';		-- BusB <- R[rb]	
				RFaddr_rd	 	<= "01"; 	-- reading rb
				RFaddr_wr	 	<= "00";	 
				IRin	     	<= '0';
				PCin	     	<= '0';		
				PCsel	     	<= "00";   	
				Imm1_in	     	<= '0';
				Imm2_in	     	<= '0';
				DTCM_out	 	<= '0';
				done_o     		<= '0';
				next_state    	<= I_MEM;
				
				if (ld = '1') then
					DTCM_addr_out	<= '1';
					DTCM_addr_in 	<= '0';
					DTCM_addr_sel	<= '0'; -- reading from BusA
				elsif (st = '1') then
					DTCM_addr_out	<= '0';
					DTCM_addr_in 	<= '1';
					DTCM_addr_sel	<= '0'; -- reading from BusA
				end if;
				
			---------------- I_MEM(I-type Write to Memory) ---------------------
			when I_MEM =>
				Ain	 	    	<= '0';
				IRin	     	<= '0';
				
				PCsel	     	<= "01";   	-- choose PC+1
				Imm1_in	     	<= '0';
				Imm2_in	     	<= '0';
				DTCM_addr_in 	<= '0';
				
				done_o     		<= '0';
				
				
				if (ld = '1') then
					DTCM_wr	     	<= '0';
					PCin	     	<= '1';		-- DONT Allows the PC_reg to receive
					ALFUN	 		<= "0111";  -- B=C
					RFaddr_rd	 	<= "00";   
					RFaddr_wr	 	<= "10";	-- writing to R[ra]
					RFin	    	<= '1';		-- Allows the RF to receive
					RFout	     	<= '0';
					DTCM_addr_out	<= '1';
					DTCM_out	 	<= '1';		-- BusB <- MemDataOut
					DTCM_addr_sel	<= '0';
					next_state    	<= fetch;
				
				elsif(st = '1') then
					DTCM_wr	     	<= '0';		-- enable for writing to DataMemory
					PCin	     	<= '0';		-- Allows the PC_reg to receive
					ALFUN	 		<= "0000";  -- unaffected
					RFaddr_rd	 	<= "10";   	-- reading ra
					RFaddr_wr	 	<= "10";	
					RFin	    	<= '0';		
					RFout	     	<= '0';		-- BusB <- R[ra]
					DTCM_out	 	<= '0';		
					DTCM_addr_sel	<= '1';	-- reading from BusB
					next_state    	<= I_MEM_2;
				end if;
			when I_MEM_2 =>
				Ain	 	    	<= '0';
				IRin	     	<= '0';
				PCsel	     	<= "01";   	-- choose PC+1
				Imm1_in	     	<= '0';
				Imm2_in	     	<= '0';
				DTCM_addr_in 	<= '0';
				DTCM_addr_out	<= '0';
				done_o     		<= '0';
				DTCM_wr	     	<= '1';
				PCin	     	<= '1';		-- Allows the PC_reg to receive
				ALFUN	 		<= "0000";  
				RFaddr_rd	 	<= "10";   
				RFaddr_wr	 	<= "10";	-- writing to R[ra]
				RFin	    	<= '0';		-- Allows the RF to receive
				RFout	     	<= '1';
				DTCM_out	 	<= '0';		-- BusB <- MemDataOut
				DTCM_addr_sel	<= '0';
				next_state    	<= fetch;
				
			end case;
	    end process;
end behav;