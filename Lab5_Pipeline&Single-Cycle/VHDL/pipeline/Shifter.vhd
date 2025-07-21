library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

USE work.aux_package.all;

entity shifter is
    generic (
        n           : integer := 32;
        shift_level : integer := 5
    );
    port (
        x    : in std_logic_vector(shift_level-1 downto 0);  -- shift amount
        y    : in std_logic_vector(n-1 downto 0);            -- input vector
        dir  : in std_logic;              -- "0" = SHL, "1" = SHR
        res  : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture rtl of shifter is
    signal y_int     : unsigned(n-1 downto 0);
    signal shifted   : unsigned(n-1 downto 0);
    signal shift_amt : integer range 0 to 2**shift_level - 1;
    signal temp_cout : std_logic := '0';
	signal shift_val : integer range 0 to n-1;
begin

  -- Convert X to an integer shift value (range 0 to n-1)
  
  shift_val <= to_integer(unsigned(x));  -- Conversion to shift amount

  gen_shift: for i in 0 to n-1 generate
  begin
    RES(i) <= 
      Y(i - shift_val) when (DIR = '0' and i >= shift_val) else
      '0'            when (DIR = '0') else
      Y(i + shift_val) when (DIR = '1' and (i + shift_val) < n) else
      '0';
	  
  end generate gen_shift;


end architecture;
