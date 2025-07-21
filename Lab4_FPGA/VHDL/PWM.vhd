LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
use ieee.numeric_std.all;

---------------entity--------------
entity PWM is
    generic (n : integer := 16);
    port (
        x, y     : in std_logic_vector(n-1 downto 0);
        pwm_mode     : in std_logic_vector(2 downto 0);
        rst, en, clk : in std_logic;
		pwm_out      : out std_logic
       
    );
end PWM;

--------------architecture---------
architecture dataflow of PWM is
    

    signal x_sig, y_sig            : std_logic_vector(n-1 downto 0);
	signal pwm_out_sig             : std_logic;
	signal timer_to_digit_cir      : std_logic_vector(n-1 downto 0);
    signal pwm_mode_sig            : std_logic_vector(2 downto 0);
    signal rst_sig                 : std_logic;
    signal en_sig                  : std_logic;
    signal clk_sig                 : std_logic;
	signal EQUY                    : std_logic;
begin
-----port to signals--------------
    x_sig 		 <= x;
	y_sig 		 <= y;
	pwm_out      <= pwm_out_sig;
	pwm_mode_sig <= pwm_mode;
	rst_sig      <= rst;
	clk_sig      <= clk;
	en_sig       <= en;
	

    -- port 16 bit counter
    counter_port : counter16bit port map(clk=>clk_sig, reset=>rst_sig, enable=>en_sig, count=>timer_to_digit_cir, EQUY=>EQUY);
	
    -- port digit circuit----
    digital_circ : digital_circuit port map(x=>x_sig, y=>y_sig, pwm_mode=>pwm_mode_sig, counter_16_bit=>timer_to_digit_cir, clk=>clk_sig, enable=>en_sig, reset=>rst_sig, pwm_out=>pwm_out_sig, EQUY=>EQUY);


   
end dataflow;
