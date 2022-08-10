LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY ADC IS
PORT (
CLOCK_50 : IN STD_LOGIC;
KEY : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
SW : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
LEDR : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
ADC_CS_N : out std_logic;
ADC_DIN : out std_logic;
ADC_SCLK : out std_logic;
	HEX0 : OUT STD_LOGIC_VECTOR(6 downto 0);
	HEX1 : OUT STD_LOGIC_VECTOR(6 downto 0);
	HEX2 : OUT STD_LOGIC_VECTOR(6 downto 0);
	HEX3 : OUT STD_LOGIC_VECTOR(6 downto 0);
ADC_DOUT : in std_logic

);
END ADC;
ARCHITECTURE ADC_int OF ADC IS

signal bintohex : std_logic_vector(11 DOWNTO 0);
signal finx : std_logic;


component bindechex is 

port ( vin : in STD_LOGIC_VECTOR (3 DOWNTO 0);
		fins : in std_logic;
				      hexout : out STD_LOGIC_VECTOR (6 DOWNTO 0));

end component;

    component unsaved is
        port (
            clk_clk        : in std_logic                     := 'X';             -- clk
            reading_export : in std_logic_vector(12 downto 0) := (others => 'X')  -- export
        );
    end component unsaved;


COMPONENT ADCv
PORT (
		clks : in std_logic;
		resets : in  std_logic;
		sclk  : buffer std_logic;
		convst: out std_logic;
		dout  : in  std_logic;
		din   : out std_logic;
		start_signal : in std_logic;
		add : in std_logic_vector(2 downto 0);
		data : out std_logic_vector (11 downto 0);
		fin : out std_logic
);
END COMPONENT;
BEGIN


NiosII : ADCv
PORT MAP(
add => SW(3 downto 1),
clks => CLOCK_50,
resets => KEY(0),
start_signal => SW(0),
convst => ADC_CS_N,
sclk => ADC_SCLK,
dout => ADC_DOUT,
din => ADC_DIN,
data => bintohex,
fin => finx
--dout => LEDR(7 DOWNTO 0)
);



block1: bindechex 
port map(
vin => bintohex(3 downto 0),
fins => finx,
hexout => HEX0
);


block2: bindechex 
port map(
vin => bintohex(7 downto 4),
fins => finx,
hexout => HEX1
);


block3: bindechex 
port map(
vin => bintohex(11 downto 8),
fins => finx,
hexout => HEX2
);


HEX3 <= "1000000";


    u0 : component unsaved
        port map (
            clk_clk        => CLOCK_50,        --     clk.clk
            reading_export(11 downto 0) => bintohex,  -- reading.export
				reading_export(12) => finx
				
        );

END ADC_int;