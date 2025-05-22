library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;            -- משתמשים ב‐numeric_std במקום ב‐synopsys
use work.aux_package.all;

entity tb_top is
  -- אין הרבה צורך בגנריקים כאן, נעביר אותם לארכיטקטורה
end entity tb_top;

architecture testbench of tb_top is
  -- הפרמטרים של ה-ALU
  constant n : integer := 8;
  constant k : integer := 3;   -- k = log2(n)
  constant m : integer := 4;   -- m = 2**(k-1)

  -- טיפוס וקאש של פקודות ALU
  type cache_t is array (0 to 19) of std_logic_vector(4 downto 0);
  constant cache : cache_t := (
    "01000","01001","01010","01000","01001","00010","01000","01001","10000","10001",
    "10010","10000","10001","10111","11001","11010","11101","11111","11011","00100"
  );

  -- האותות שלנו
  signal X, Y        : std_logic_vector(n-1 downto 0) := (others => '0');
  signal ALUFN       : std_logic_vector(4 downto 0) := (others => '0');
  signal ALUout      : std_logic_vector(n-1 downto 0);
  signal Nflag, Cflag, Zflag, Vflag : std_logic;

begin
  -- Instantiate the top-level ALU under test
  UUT: entity work.top
    generic map (
      n  => n,
      k  => k,
      m  => m
    )
    port map (
      Y      => Y,
      X      => X,
      ALUFN  => ALUFN,
      ALUout => ALUout,
      Nflag  => Nflag,
      Cflag  => Cflag,
      Zflag  => Zflag,
      Vflag  => Vflag
    );

  -- Stimulus process
  stimulus: process
  begin
    -- initialize inputs at time 0
    X     <= (others => '0');
    X(1)  <= '1';
    X(3)  <= '1';
    X(5)  <= '1';
    X(7)  <= '1';

    Y     <= (others => '0');
    Y(1)  <= '1';
    Y(4)  <= '1';
    Y(7)  <= '1';

    ALUFN <= (others => '0');
    wait for 10 ns;

    -- loop through all functions in cache
    for j in cache'range loop
      ALUFN <= cache(j);
      wait for 10 ns;
    end loop;

    wait;  -- עצור כאן בסוף
  end process stimulus;

end architecture testbench;
