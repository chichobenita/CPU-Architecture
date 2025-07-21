library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.aux_package.all;

entity shifter is
    generic (
        n           : integer := 8;
        shift_level : integer := 3
    );
    port (
        x    : in std_logic_vector(n-1 downto 0);  -- shift amount
        y    : in std_logic_vector(n-1 downto 0);            -- input vector
        dir  : in std_logic_vector(2 downto 0);              -- "000" = SHL, "001" = SHR
        res  : out std_logic_vector(n-1 downto 0);
        cout : out std_logic
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
  
  shift_val <= to_integer(unsigned(X(shift_level - 1 downto 0)));  -- Conversion to shift amount

  gen_shift: for i in 0 to n-1 generate
  begin
    RES(i) <= 
      Y(i - shift_val) when (DIR = "000" and i >= shift_val) else
      '0'            when (DIR = "000") else
      Y(i + shift_val) when (DIR = "001" and (i + shift_val) < n) else
      '0';
	  
  end generate gen_shift;
  cout <= Y(n - shift_val) when (DIR = "000" and shift_val > 0 and shift_val <= n) else
	   '0'                       when (DIR = "000") else
       Y(shift_val - 1)          when (DIR = "001" and shift_val > 0 and shift_val <= n) else
       '0';


end architecture;
