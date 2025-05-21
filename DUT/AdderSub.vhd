LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;

---------------entity--------------
entity AdderSub is
    generic (n : integer := 8);
    port (
        xin, yin : in std_logic_vector(n-1 downto 0);
        op_mode  : in std_logic_vector(2 downto 0);
        res      : out std_logic_vector(n-1 downto 0);
        cout     : out std_logic;
		v        : out std_logic
    );
end AdderSub;

--------------architecture---------
architecture dataflow of AdderSub is
    constant zero_vec : std_logic_vector(n-1 downto 0) := (others => '0');
    constant one_vec  : std_logic_vector(n-1 downto 0) := (0 => '1', others => '0');

    signal x, y, s     : std_logic_vector(n-1 downto 0);
    signal xi          : std_logic_vector(n-1 downto 0);
    signal xi0         : std_logic;
    signal sub         : std_logic;
    signal reg         : std_logic_vector(n-1 downto 0);
begin

    -- Control logic
    x <= xin when (op_mode = "000" or op_mode = "001" or op_mode = "010") else
         one_vec when (op_mode = "011" or op_mode = "100")
			else zero_vec;

    y <= yin when (op_mode = "000" or op_mode = "001" or op_mode = "011" or op_mode = "100")
         else zero_vec;

    sub <= '1' when (op_mode = "001" or op_mode = "010" or op_mode = "100")
           else '0';

    -- Precompute xor inputs
    xi0 <= x(0) xor sub;
    gen_xi : for i in 1 to n-1 generate
        xi(i) <= x(i) xor sub;
    end generate;

    -- First FA
    first : FA port map(
        xi   => xi0,
        yi   => y(0),
        cin  => sub,
        s    => s(0),
        cout => reg(0)
    );

    -- Remaining FAs
    rest : for i in 1 to n-1 generate
        chain : FA port map(
            xi   => xi(i),
            yi   => y(i),
            cin  => reg(i-1),
            s    => s(i),
            cout => reg(i)
        );
    end generate;

    -- Output assignments
    res  <= s;
    cout <= reg(n-1);
	v <= reg(n-1) xor reg(n-2);

end dataflow;
