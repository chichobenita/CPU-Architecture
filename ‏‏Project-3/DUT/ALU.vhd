LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE work.aux_package.all;
--------------------------------
entity ALU is
generic (DataWidth : integer := 16);
port(	Ain,clk 			: in std_logic;
		ALFUN 				: in std_logic_vector(3 downto 0);
		RegA_in,RegB_in	 	: in std_logic_vector(DataWidth-1 downto 0);
		RegC 				: out std_logic_vector(DataWidth-1 downto 0);
		Cflag,Nflag,Zflag	: out std_logic
		);
end ALU;
--------------------------------
architecture behav of ALU is
signal RegA,RegB : std_logic_vector(DataWidth-1 downto 0);
signal Carry_in : std_logic;
signal Carry_out,shifter_cout: std_logic;
signal SumAdder : std_logic_vector (DataWidth-1 downto 0);
signal shift_out : std_logic_vector (DataWidth-1 downto 0);
constant zero : std_logic_vector(DataWidth-1 downto 0) := (others => '0');
signal And_out,Or_out,Xor_out : std_logic_vector(DataWidth-1 downto 0);
begin

RegA <= RegA_in;
And_out <= (RegA and RegB_in) when ALFUN = "0010" else (others=>'0');
Or_out  <= (RegA or RegB_in) when ALFUN = "0011" else (others=>'0');
Xor_out <= (RegA xor RegB_in) when ALFUN = "0100" else (others=>'0');

RegB <= not(RegB_in) when ALFUN = "1001" else RegB_in; --oprate neg for create (-B)
Carry_in <= '1' when ALFUN = "1001" else '0';


Adder_Sub: Adder generic map(N => DataWidth) port map (
			A => RegA,
			B => RegB,
			Cin => Carry_in,
			Cout => Carry_out,
			Sum => SumAdder
			);


RegC <= And_out when ALFUN = "0010" else
		Or_out when ALFUN = "0011" else
		Xor_out when ALFUN = "0100" else
		RegB_in when ALFUN = "0111"	else
		shift_out when ALFUN = "0101"	else
		SumAdder;

shifter_real : shifter generic map(DataWidth, 4) port map (
			x => RegB,
			y => RegA,
			dir => "000",
			res => shift_out,
			cout => shifter_cout
			);



		
Zflag <= unaffected when (ALFUN = "0000") ELSE '1' WHEN (SumAdder = zero) ELSE '0';
Nflag <= unaffected when (ALFUN = "0000") ELSE SumAdder(DataWidth-1);
CFlag <= Carry_out when (ALFUN = "1000" or ALFUN = "1001") else unaffected;
		
--Cflag <= '1' when (Carry_out='1') else '0';
--Zflag <= '1' when (RegC=zero) else '0';
--Nflag <= '1' when (RegC(DataWidth-1)='1') else '0';
end behav;

			
			
