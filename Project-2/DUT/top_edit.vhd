LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.aux_package.all;
------------------------------------------------------------------
entity top is
	generic ( n : positive := 8 ); 
	port( rst_i, clk_i, repeat_i : in std_logic;
		  upperBound_i : in std_logic_vector(n-1 downto 0);
		  count_o : out std_logic_vector(n-1 downto 0);
		  busy_o : out std_logic);
end top;
------------------------------------------------------------------
architecture arc_sys of top is
	signal cnt_fast, cnt_slow : std_logic_vector(n-1 downto 0);
	signal control_fast, control_slow : std_logic;
	
begin
	----------------------------------------------------------------
	----------------------- fast counter process -------------------
	----------------------------------------------------------------
	proc1 : process(clk_i,rst_i,control_fast,cnt_fast,cnt_slow)
	begin
		if rst_i = '1' then
			cnt_fast <= (others => '0');
		elsif (rising_edge(clk_i)) then
			if ((repeat_i = '0')and(cnt_fast = cnt_slow)and(cnt_slow>=upperBound_i)) then
				cnt_fast <= cnt_fast;
			elsif cnt_fast < cnt_slow then
				cnt_fast <= cnt_fast + 1;
			elsif cnt_fast = cnt_slow then
				cnt_fast <= (others => '0');
			end if;
		end if;
	end process;
	----------------------------------------------------------------
	---------------------- slow counter process --------------------
	----------------------------------------------------------------
	proc2 : process(clk_i,rst_i,control_slow,cnt_slow,upperBound_i)
	begin
		if rst_i = '1' then
			cnt_slow <= (others => '0');
		elsif rising_edge(clk_i) then
			if (cnt_slow = cnt_fast) and (cnt_slow < upperBound_i) then
				cnt_slow <= cnt_slow + 1;
			elsif (repeat_i = '1') and (cnt_slow = upperBound_i) and(cnt_fast=cnt_slow) then
				cnt_slow <= (others => '0');
			end if;
		end if;
	end process;
	---------------------------------------------------------------
	--------------------- combinational part ----------------------
	---------------------------------------------------------------
	---control_fast <= '1' when (cnt_fast = cnt_slow)and(cnt_slow >= upperBound_i) else '0';
	---control_slow <= '1' when (cnt_slow = cnt_fast) else '0';
	count_o <= cnt_fast;
	busy_o <= '0' when ((repeat_i = '0')and(cnt_fast >= cnt_slow)and(cnt_slow>=upperBound_i)) else '1';
	
	
	
	
	
	----------------------------------------------------------------
end arc_sys;







