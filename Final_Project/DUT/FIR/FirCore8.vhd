library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.aux_package.all;

entity FirCore8 is
  generic(
    W : positive := 24;  -- sample width
    Q : positive := 8    -- coef fractional bits (Q0.Q)
  );
  port(
    clk      : in  std_logic;                           -- FIRCLK
    rst      : in  std_logic;                           -- FIRRST
    step     : in  std_logic;                           -- accept one new sample (1 clk) FIRENA
    x_in     : in  std_logic_vector(W-1 downto 0);      -- new sample (popped from FIFO)
    coef     : in  std_logic_vector(8*Q-1 downto 0);    -- {c7,c6,...,c0}, each Q bits
    y_out    : out std_logic_vector(W-1 downto 0);		-- FIROUT
    y_valid  : out std_logic                            -- 1 when y_out updated FIRFIG
  );
end;

architecture rtl of FirCore8 is
  type tap_arr is array(0 to 7) of unsigned(W-1 downto 0);
  signal x           : tap_arr := (others=>(others=>'0')); -- delay line
  type coef_arr is array(0 to 7) of unsigned(Q-1 downto 0);
  signal c : coef_arr;
  signal y_reg       : unsigned(W-1 downto 0) := (others=>'0');
  signal yv          : std_logic := '0';
begin
  -- unpack coefficients (when you write COEF3_0/COEF7_4 in the top, byte 0 is tap 0, byte 1 is tap 1)
  c(0) <= unsigned(coef(1*Q-1 downto 0*Q));
  c(1) <= unsigned(coef(2*Q-1 downto 1*Q));
  c(2) <= unsigned(coef(3*Q-1 downto 2*Q));
  c(3) <= unsigned(coef(4*Q-1 downto 3*Q));
  c(4) <= unsigned(coef(5*Q-1 downto 4*Q));
  c(5) <= unsigned(coef(6*Q-1 downto 5*Q));
  c(6) <= unsigned(coef(7*Q-1 downto 6*Q));
  c(7) <= unsigned(coef(8*Q-1 downto 7*Q));
process(clk)
  -- next-state taps and the accumulator are VARIABLES
  variable taps : tap_arr;
  variable acc  : unsigned(W+Q-1 downto 0);
begin
  if rising_edge(clk) then
    if rst='1' then
      x     <= (others=>(others=>'0'));
      y_reg <= (others=>'0');
      yv    <= '0';
    else
      yv <= '0';

      if step='1' then
        -- 1) build next-state taps (immediate variable updates)
        taps(7):= x(6); taps(6):= x(5); taps(5):= x(4); taps(4):= x(3);
        taps(3):= x(2); taps(2):= x(1); taps(1):= x(0);
        taps(0):= unsigned(x_in);  -- <-- include new sample this cycle

        -- 2) MAC over next-state taps (includes x_in)
        acc := (others=>'0');
        for k in 0 to 7 loop
          acc := acc + (taps(k) * c(k));  -- 32-bit Q24.8
        end loop;

        -- 3) commit taps to registers
        x(7) <= taps(7); x(6) <= taps(6); x(5) <= taps(5); x(4) <= taps(4);
        x(3) <= taps(3); x(2) <= taps(2); x(1) <= taps(1); x(0) <= taps(0);

        -- 4) quantize & flag valid in the same cycle
        y_reg <= acc(W+Q-1 downto Q);  -- drop 8 LSBs (Q0.8 -> Q24.0)
        yv    <= '1';
      end if;
    end if;
  end if;
end process;
  y_out   <= std_logic_vector(y_reg);
  y_valid <= yv;
end rtl;
