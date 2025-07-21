LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
use ieee.numeric_std.all;

---------------entity--------------
entity counter16bit is
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        enable : in  STD_LOGIC;
        count  : out STD_LOGIC_VECTOR (15 downto 0);
		EQUY   : in  STD_LOGIC
    );
end counter16bit;

architecture Behavioral of counter16bit is
    signal count_reg : unsigned(15 downto 0) := (others => '0');
begin

    process(clk, reset, EQUY)
    begin
        if ((reset = '0') or (EQUY = '1')) then
            count_reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
				count_reg <= count_reg + 1; 
            end if;
        end if;
    end process;

    count <= std_logic_vector(count_reg);
	



end Behavioral;

