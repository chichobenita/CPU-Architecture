library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.aux_package.all;

entity SyncFifo is
  generic(
    WIDTH : positive := 24;
    DEPTH : positive := 8              -- power of 2
  );
  port(
    FIFOCLK     : in  std_logic;           -- FIFOFIFOCLK
    rst     	: in  std_logic;
    FIFOWEN  	: in  std_logic;
    FIFOIN      : in  std_logic_vector(WIDTH-1 downto 0);
    FIFOREN   	: in  std_logic;           -- must be FIFOFIFOCLK-synchronous
    DATAOUT    	: out std_logic_vector(WIDTH-1 downto 0);
    FIFOFULL    : out std_logic;
    FIFOEMPTY   : out std_logic
  );
end;

architecture rtl of SyncFifo is
  subtype idx_t is unsigned(2 downto 0); -- decimal to unsigned binary 
  type mem_t is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0); -- create a stuck

  signal mem        : mem_t;
  signal wptr, rptr : idx_t := (others=>'0');
  signal cnt        : unsigned(idx_t'range) := (others=>'0');
  -- Note: cnt width = ptr width, good for small FIFOs
begin
  FIFOFULL  <= '1' when cnt = to_unsigned(DEPTH, cnt'length) else '0';
  FIFOEMPTY <= '1' when cnt = ("000")                   else '0';
  DATAOUT  <= mem(to_integer(rptr));

  process(FIFOCLK)
  variable next_cnt : unsigned(cnt'range);
  begin
    if rising_edge(FIFOCLK) then
      if rst='1' then
        mem <= (others => (others => '0'));
		wptr <= (others=>'0'); rptr <= (others=>'0'); cnt <= (others=>'0');
      else
        -- write
        if (FIFOWEN='1' and FIFOFULL='0') then
          mem(to_integer(wptr)) <= FIFOIN;
          wptr <= wptr + 1;
          next_cnt := next_cnt + 1;
        end if;

        -- read
        if (FIFOREN='1' and FIFOEMPTY='0') then
          rptr <= rptr + 1;
          next_cnt := next_cnt - 1;
        end if;
		cnt <= next_cnt;
      end if;
    end if;
  end process;
end rtl;
