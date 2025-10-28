library ieee;
use ieee.std_logic_1164.all;
USE work.aux_package.all;

entity PulseSync is
  port(
    rst      : in  std_logic;
    FIRCLK   : in  std_logic;
    FIRENA    : in  std_logic;   -- "pop one" request in FIR domain (gate with !empty)
    FIFOCLK  : in  std_logic;
    FIFOREN  : out std_logic    -- 1-cycle pulse in FIFOCLK domain
  );
end;

architecture rtl of PulseSync is
  signal req_tgl          : std_logic := '0'; -- FIR domain
  signal s1, s2, s2_d     : std_logic := '0'; -- FIFO domain sync + edge detect
begin
  -- Source domain: toggle on each request
  process(FIRCLK)
  begin
    if rising_edge(FIRCLK) then
      if rst='1' then
        req_tgl <= '0';
      elsif FIRENA='1' then
        req_tgl <= not req_tgl;
      end if;
    end if;
  end process;

  -- Destination domain: 2FF + XOR -> 1-cycle pulse
  process(FIFOCLK)
  begin
    if rising_edge(FIFOCLK) then
      if rst='1' then
        s1 <= '0'; s2 <= '0'; s2_d <= '0'; FIFOREN <= '0';
      else
        s1 <= req_tgl;
        s2 <= s1;
        FIFOREN <= s2 xor s2_d; -- one-cycle pulse
        s2_d <= s2;
      end if;
    end if;
  end process;
end rtl;
