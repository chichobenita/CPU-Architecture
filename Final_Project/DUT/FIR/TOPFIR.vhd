library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.aux_package.all;

entity FIR_Top is
  generic(
    W      : positive := 24;
    Q      : positive := 8;
    DEPTH  : positive := 8
  );
  port(
    Data_Bus		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	address		 	: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- A11,A6-A0
	MemRead	 		: IN 	STD_LOGIC;
	MemWrite	 	: IN 	STD_LOGIC;
	-- clocks & resets
    FIFOCLK   : in  std_logic;
    FIFORST   : in  std_logic;
    FIRCLK    : in  std_logic;
    FIRRST    : in  std_logic;

    -- write-side (CPU -> FIFO)
    fifo_full : out std_logic;
    fifo_empty: out std_logic;
	
    -- output
    firout    : out std_logic_vector(31 downto 0);      -- {8'h00, y[23:0]}
    firifg    : out std_logic                           -- 1 when new y available
  );
end;

architecture rtl of FIR_Top is
	signal CS											: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	signal Dout, Din									: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal en											: STD_LOGIC;
  
  
  -- FIFO
	signal fifo_dout      			: std_logic_vector(W-1 downto 0);
	signal fiforen        			: std_logic;
	signal wr_en_bus 				: std_logic;
	signal din_bus 					: std_logic_vector(W-1 downto 0);
	
  -- sync FIFOEMPTY into FIR domain (for gating requests)
	signal empty_meta, empty_fir 	: std_logic;

  -- request & one-cycle aligner so x_in is sampled after pop
	signal step_req_fir   			: std_logic;
	signal step_fir_d1    			: std_logic;

  -- coef pack
	signal coef_pack      			: std_logic_vector(8*Q-1 downto 0);

  -- registered sample captured in FIRCLK domain
	signal x_sample_fir   			: std_logic_vector(W-1 downto 0);
  
  	-- coefficient registers owned by this block (bus side)
	signal coef3_0_reg_bus 			: std_logic_vector(31 downto 0) := (others=>'0'); -- {c3,c2,c1,c0}
	signal coef7_4_reg_bus 			: std_logic_vector(31 downto 0) := (others=>'0'); -- {c7,c6,c5,c4}
	
	-- CS bit indices (handy)
	constant IDX_FIRCTL  			: integer := 0;
	constant IDX_FIRIN   			: integer := 1;
	constant IDX_FIROUT  			: integer := 2;
	constant IDX_COEF3_0 			: integer := 3;
	constant IDX_COEF7_4 			: integer := 4;
	
	-- FIR result capture (FIRCLK → FIFOCLK)
	signal y_out_fir       : std_logic_vector(W-1 downto 0);
	signal y_valid_fir     : std_logic := '0';
	signal ycap_pulse      : std_logic := '0';                -- FIFOCLK 1-cycle pulse
	signal firout_reg_bus  : std_logic_vector(31 downto 0) := (others => '0');

	
---------- FIRCTL signals maybe would be hara doubled signals ------------
-- FIRCTL fields (bus/FIFOCLK domain)
signal firctl_uu7    : std_logic := '0';
signal firctl_uu6    : std_logic := '0';
signal firctl_fifowen_req : std_logic := '0';  -- one-shot request
signal firctl_fiforst    : std_logic := '0';
signal firctl_firrst     : std_logic := '0';
signal firctl_firena     : std_logic := '0';

signal firctl_rd      : std_logic_vector(7 downto 0);

-- effective resets (allow external pins if you still want them)
signal FIFORST_eff    : std_logic;
signal FIRRST_eff_bus : std_logic;  -- bus-domain copy before sync

-- FIRIN holding register (what the CPU writes)
signal firin_reg_bus  : std_logic_vector(31 downto 0) := (others=>'0');

-- FIRCLK sync of FIRENA / FIRRST
signal firena_meta, firena_sync : std_logic := '0';
signal firrst_meta, firrst_sync : std_logic := '0';
----------------------------------------------------------------------------

begin
  FIR2BUS: BidirPin generic map(width => 32) port map(Dout => Dout, en => en, Din => Din, IOpin => Data_Bus);
  
  	WITH address SELECT
	CS <= "00001" WHEN "10101100", -- FIRCTL Address
		  "00010" WHEN "10110000", -- FIRIN Address
		  "00100" WHEN "10110100", -- FIROUT Address
		  "01000" WHEN "10111000", -- COEF3_0 Address
		  "10000" WHEN "10111100", -- COEF7_4 Address
		  "00000" WHEN OTHERS;
  
	-- who can drive the bus on reads
	en <= '1' when (MemRead = '1') and (CS(IDX_FIRCTL) = '1' or
										CS(IDX_FIROUT) = '1' or
										CS(IDX_COEF3_0) = '1' or
										CS(IDX_COEF7_4) = '1')
		   else '0';

	-- readback mux (we’ll fill FIRCTL/FIROUT later; for now add the COEF regs)
	Dout <= X"000000" & firctl_rd 	when (MemRead='1' and CS(IDX_FIRCTL)='1') else
			firout_reg_bus          when (MemRead='1' and CS(IDX_FIROUT)='1') else
			coef3_0_reg_bus 		when (MemRead='1' and CS(IDX_COEF3_0)='1') else
			coef7_4_reg_bus 		when (MemRead='1' and CS(IDX_COEF7_4)='1') else
			(others => '0');

	wr_en_bus 	<= firctl_fifowen_req and (not fifo_full);
	din_bus		<= firin_reg_bus(W-1 downto 0);


	-- FIRCTL read value
		firctl_rd(7) <= firctl_uu7;
		firctl_rd(6) <= firctl_uu6;
		firctl_rd(5) <= '0';            -- FIFOWEN reads as 0 (self-clearing pulse)
		firctl_rd(4) <= firctl_fiforst;
		firctl_rd(3) <= fifo_full;      -- RO
		firctl_rd(2) <= fifo_empty;     -- RO
		firctl_rd(1) <= firctl_firrst;
		firctl_rd(0) <= firctl_firena;

	
	
	Bus_Regs : process(FIFOCLK)
	begin
	  if rising_edge(FIFOCLK) then
		if FIFORST = '1' then
		  -- async/global reset path if you still use the external pin
		  firctl_uu7 <= '0'; firctl_uu6 <= '0';
		  firctl_fifowen_req <= '0';
		  firctl_fiforst <= '0';
		  firctl_firrst  <= '0';
		  firctl_firena  <= '0';
		  coef3_0_reg_bus <= (others=>'0');
		  coef7_4_reg_bus <= (others=>'0');
		  firin_reg_bus   <= (others=>'0');
		else
		  -- default: auto-clear the one-shot request
		  firctl_fifowen_req <= '0';

		  if MemWrite='1' then
			-- FIRCTL write
			if CS(IDX_FIRCTL)='1' then
			  firctl_uu7    <= Din(7);
			  firctl_uu6    <= Din(6);
			  if Din(5)='1' then      -- W1P: request one FIFO write
				firctl_fifowen_req <= '1';
			  end if;
			  firctl_fiforst <= Din(4);
			  -- live flags [3:2] are RO, ignored on write
			  firctl_firrst  <= Din(1);
			  firctl_firena  <= Din(0);
			end if;

			-- COEF registers
			if CS(IDX_COEF3_0)='1' then
			  coef3_0_reg_bus <= Din;
			elsif CS(IDX_COEF7_4)='1' then
			  coef7_4_reg_bus <= Din;
			end if;

			-- FIRIN holding register
			if CS(IDX_FIRIN)='1' then
			  firin_reg_bus <= Din;
			end if;
		  end if;
		end if;
	  end if;
	end process;


  -- Pack coefficients into 64b {c7..c0}
	coef_pack <= coef7_4_reg_bus & coef3_0_reg_bus;  -- {c7..c4, c3..c0}

	FIFORST_eff <= FIFORST or firctl_fiforst;

  -- FIFO (single clock in FIFOCLK domain)
  u_fifo : entity work.SyncFifo
    generic map(WIDTH=>W, DEPTH=>DEPTH)
    port map(
      FIFOCLK   => FIFOCLK,
      rst 	=> FIFORST_eff,
      FIFOWEN => wr_en_bus,
      FIFOIN   => din_bus,       -- lower 24 bits only
      FIFOREN => fiforen,
      DATAOUT  => fifo_dout,
      FIFOFULL  => fifo_full,
      FIFOEMPTY => fifo_empty
    );

	-- Bus-level FIR reset bit (you can OR with external if desired)
	FIRRST_eff_bus <= FIRRST or firctl_firrst;

	-- 2-FF synchronize FIRENA into FIRCLK
	process(FIRCLK)
	begin
	  if rising_edge(FIRCLK) then
		firena_meta <= firctl_firena;
		firena_sync <= firena_meta;
	  end if;
	end process;

	-- 2-FF synchronize FIRRST into FIRCLK
	process(FIRCLK)
	begin
	  if rising_edge(FIRCLK) then
		firrst_meta <= FIRRST_eff_bus;
		firrst_sync <= firrst_meta;
	  end if;
	end process;

	-- FIFO empty flag synchronized into FIRCLK (reset by firrst_sync)
	process(FIRCLK)
	begin
	  if rising_edge(FIRCLK) then
		if firrst_sync = '1' then
		  empty_meta <= '1';
		  empty_fir  <= '1';
		else
		  empty_meta <= fifo_empty;
		  empty_fir  <= empty_meta;
		end if;
	  end if;
	end process;

	-- FIR side request to pop one sample
	step_req_fir <= firena_sync and (not empty_fir);
	
	-- FIRCLK→FIFOCLK pulse synchronizer for rd_en
	u_sync : entity work.PulseSync
	  port map(
		rst     => FIFORST_eff,
		FIRCLK  => FIRCLK,
		FIRENA   => step_req_fir,
		FIFOCLK => FIFOCLK,
		FIFOREN => fiforen
	  );
	  
	  
	-- New: y_valid → capture pulse (FIRCLK → FIFOCLK)
	u_sync_yvalid : entity work.PulseSync
	  port map(
		rst     => FIFORST_eff,
		FIRCLK  => FIRCLK,
		FIRENA   => y_valid_fir,   -- FIRCLK 1-cycle valid from core
		FIFOCLK => FIFOCLK,
		FIFOREN => ycap_pulse     -- FIFOCLK 1-cycle pulse -> latch FIROUT
	  );

  -- Align data capture: capture FIFO dout on the cycle AFTER we asked for a pop
  process(FIRCLK)
  begin
    if rising_edge(FIRCLK) then
      if firrst_sync ='1' then
        step_fir_d1 <= '0';
        x_sample_fir <= (others=>'0');
      else
        step_fir_d1 <= step_req_fir;          -- one-cycle delay
        if step_fir_d1 ='1' then
          -- by next FIRCLK edge the FIFO has already popped (FIFOCLK >> FIRCLK)
          x_sample_fir <= fifo_dout;
        end if;
      end if;
    end if;
  end process;


  -- FIR core
	u_core: entity work.FirCore8
	  port map(
		clk     => FIRCLK,
		rst     => firrst_sync,
		step    => step_fir_d1,
		x_in    => x_sample_fir,
		coef    => coef_pack,
		y_out   => y_out_fir,      -- internal 24-bit
		y_valid => y_valid_fir     -- internal valid (FIRCLK)
	);
	
	
	-- Capture the newest FIR output word when ycap_pulse arrives
	process(FIFOCLK)
	begin
	  if rising_edge(FIFOCLK) then
		if FIFORST_eff = '1' then
		  firout_reg_bus <= (others => '0');
		elsif ycap_pulse = '1' then
		  firout_reg_bus <= X"00" & y_out_fir;  -- zero-extend 24→32
		end if;
	  end if;
	end process;

	-- Export an interrupt-friendly pulse (to your IC)
	firifg <= ycap_pulse;
	
	-- keep the external 32-bit output for probes/visibility
	firout(23 downto 0)  <= y_out_fir;
	firout(31 downto 24) <= (others => '0');

end rtl;
