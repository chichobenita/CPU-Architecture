LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE work.aux_package.all;
------------------------------------
entity OPCdecoder is
port(	IRin : in std_logic_vector (3 downto 0);
		st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,shl : out std_logic
	);
end OPCdecoder;
------------------------------------
architecture behav of OPCdecoder is
begin
add <= '1' when IRin = "0000" else '0';
sub <= '1' when IRin = "0001" else '0';
and_o <= '1' when IRin = "0010" else '0';
or_o <= '1' when IRin = "0011" else '0';
xor_o <= '1' when IRin = "0100" else '0';
shl <= '1' when IRin = "0101" else '0';
--add <= '1' when IRin = "0110" else '0';
jmp <= '1' when IRin = "0111" else '0';
jc <= '1' when IRin = "1000" else '0';
jnc <= '1' when IRin = "1001" else '0';
--add <= '1' when IRin = "1010" else '0';
--sub <= '1' when IRin = "1011" else '0';
mov <= '1' when IRin = "1100" else '0';
ld <= '1' when IRin = "1101" else '0';
st <= '1' when IRin = "1110" else '0';
done <= '1' when IRin = "1111" else '0';
end behav;