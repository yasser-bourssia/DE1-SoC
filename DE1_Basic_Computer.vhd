
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity DE1_Basic_Computer is

-------------------------------------------------------------------------------
--                             Port Declarations                             --
-------------------------------------------------------------------------------
port (
	-- Inputs
	CLOCK_50             : in std_logic;
	CLOCK_27             : in std_logic;
	KEY                  : in std_logic_vector (3 downto 0);
	SW                   : in std_logic_vector (9 downto 0);

	--  Communication
	UART_RXD             : in std_logic;

	-- Outputs
	--  Simple
	LEDG                 : out std_logic_vector (7 downto 0);
	LEDR                 : out std_logic_vector (9 downto 0);
	HEX0                 : out std_logic_vector (6 downto 0);
	HEX1                 : out std_logic_vector (6 downto 0);
	HEX2                 : out std_logic_vector (6 downto 0);
	HEX3                 : out std_logic_vector (6 downto 0);

	--  Memory (SRAM)
	SRAM_DQ              : inout std_logic_vector (15 downto 0);
	SRAM_ADDR            : out std_logic_vector (17 downto 0);
	SRAM_CE_N            : out std_logic;
	SRAM_WE_N            : out std_logic;
	SRAM_OE_N            : out std_logic;
	SRAM_UB_N            : out std_logic;
	SRAM_LB_N            : out std_logic;
	
	--  Communication
	UART_TXD             : out std_logic;
	
	-- Memory (SDRAM)
	DRAM_DQ				 : inout std_logic_vector (15 downto 0);
	DRAM_ADDR			 : out std_logic_vector (11 downto 0);
	DRAM_BA			 : buffer std_logic_vector(1 downto 0);
	--DRAM_BA_0			 : buffer std_logic;
	DRAM_CAS_N			 : out std_logic;
	DRAM_RAS_N			 : out std_logic;
	DRAM_CLK			 : out std_logic;
	DRAM_CKE			 : out std_logic;
	DRAM_CS_N			 : out std_logic;
	DRAM_WE_N			 : out std_logic;
	DRAM_UDQM			 : buffer std_logic;
	DRAM_LDQM			 : buffer std_logic;
	
	--
	GPIO_1 : inout std_logic_vector (35 downto 0)
	
	);
end DE1_Basic_Computer;


architecture DE1_Basic_Computer_rtl of DE1_Basic_Computer is

-------------------------------------------------------------------------------
--                           Subentity Declarations                          --
-------------------------------------------------------------------------------
	component nios_system
		port (
              -- 1) global signals:
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
              -- the_Green_LEDs
                 signal LEDG_from_the_Green_LEDs : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
              -- the_HEX3_HEX0
                 signal hex7seg_HEX0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal hex7seg_HEX1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal hex7seg_HEX2 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal hex7seg_HEX3 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
              -- the_Red_LEDs
                 signal LEDR_from_the_Red_LEDs : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			     -- the_Slider_switches
                 signal SW_to_the_Slider_switches : IN STD_LOGIC_VECTOR (9 DOWNTO 0);    
              -- the_SRAM
				     sram_wire_DQ                  : inout std_logic_vector(15 downto 0) := (others => 'X'); -- DQ
					  sram_wire_ADDR                : out   std_logic_vector(17 downto 0);                    -- ADDR
					  sram_wire_LB_N                : out   std_logic;                                        -- LB_N
					  sram_wire_UB_N                : out   std_logic;                                        -- UB_N
					  sram_wire_CE_N                : out   std_logic;                                        -- CE_N
					  sram_wire_OE_N                : out   std_logic;                                        -- OE_N
					  sram_wire_WE_N                : out   std_logic;                                        -- WE_N         
              -- the_sdram
                 signal zs_addr_from_the_sdram : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal zs_ba_from_the_sdram : BUFFER STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal zs_cas_n_from_the_sdram : OUT STD_LOGIC;
                 signal zs_cke_from_the_sdram : OUT STD_LOGIC;
                 signal zs_cs_n_from_the_sdram : OUT STD_LOGIC;
                 signal zs_dq_to_and_from_the_sdram : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal zs_dqm_from_the_sdram : BUFFER STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal zs_ras_n_from_the_sdram : OUT STD_LOGIC;
                 signal zs_we_n_from_the_sdram : OUT STD_LOGIC;
                                       -- TXD
					  signal i2c_reg_in_port             : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- in_port
                 signal i2c_reg_out_port            : out   std_logic_vector(7 downto 0)                      -- out_port
              );
	end component;
	
	component sdram_pll
		port (
				 signal inclk0 : IN STD_LOGIC;
				 signal c0 : OUT STD_LOGIC;
				 signal c1 : OUT STD_LOGIC
			 );
	end component;

-------------------------------------------------------------------------------
--                 Internal Wires and Registers Declarations                 --
-------------------------------------------------------------------------------
-- Internal Wires
-- Used to connect the Nios 2 system clock to the non-shifted output of the PLL
signal			 system_clock : STD_LOGIC;

-- Used to concatenate some SDRAM control signals
signal			 BA : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal			 DQM : STD_LOGIC_VECTOR(1 DOWNTO 0);

-------------------------------------------------------------------------------
-- You can add here your internal signals
-- Internal signals

-- CAN
signal conv_st		: STD_LOGIC:='1';
signal read_can, cs_can : std_logic:='1';
signal busy_can	: STD_LOGIC:='0';
signal DBIN : std_logic_vector (7 downto 0);

-- CNA

signal DBOUT : std_logic_vector (7 downto 0);
signal write_cna, cs_cna : std_logic:='1';

-- compteur pour latence
signal cpt : unsigned (3 downto 0);

signal reg_cna,reg_can : std_LOGIC_VECTOR(7 downto 0);

type automate_type is (ETAT0, ETAT1, ETAT2, ETAT3, ETAT4, ETAT5, ETAT6, ETAT7, ETAT8, ETAT9, ETAT10, ETAT11);
signal automate : automate_type:=ETAT0;

signal clavin, clavout : std_LOGIC_VECTOR(7 downto 0);
signal I2Cin,I2Cout : std_logic_vector( 7 downto 0);


begin
	
-------------------------------------------------------------------------------
--                            Combinational glue Logic for DRAM                            --
-------------------------------------------------------------------------------
DRAM_BA(1)  <= BA(1);
DRAM_BA(0)  <= BA(0);
DRAM_UDQM  <= DQM(1);
DRAM_LDQM  <= DQM(0);

-------------------------------------------------------------------------------
--                              Internal Modules                             --
-------------------------------------------------------------------------------

NiosII : nios_system
	port map(
	-- 1) global signals:
		clk       								=> system_clock,
		reset_n    								=> KEY(0),	
	-- the_Slider_switches
		SW_to_the_Slider_switches				=> SW,
	-- the_Green_LEDs
	--	LEDG_from_the_Green_LEDs 				=> LEDG,
	-- the_Red_LEDs
		LEDR_from_the_Red_LEDs 					=> LEDR,
	-- the_HEX3_HEX0
		hex7seg_HEX0 				=> HEX0,
		hex7seg_HEX1 				=> HEX1,
		hex7seg_HEX2 				=> HEX2,
		hex7seg_HEX3 				=> HEX3,
	-- the_SRAM
		sram_wire_DQ                  => SRAM_DQ,              --  sram_wire.DQ
		sram_wire_ADDR                => SRAM_ADDR,           -- .ADDR
		sram_wire_LB_N                => SRAM_LB_N,                --.LB_N
		sram_wire_UB_N                => SRAM_UB_N,                -- .UB_N
		sram_wire_CE_N                => SRAM_CE_N,            -- .CE_N
		sram_wire_OE_N                => SRAM_OE_N,                -- .OE_N
		sram_wire_WE_N                => SRAM_WE_N,                -- .WE_N
	-- the_sdram
		zs_addr_from_the_sdram				=> DRAM_ADDR,
		zs_ba_from_the_sdram					=> BA,
		zs_cas_n_from_the_sdram				=> DRAM_CAS_N,
		zs_cke_from_the_sdram				=> DRAM_CKE,
		zs_cs_n_from_the_sdram				=> DRAM_CS_N,
		zs_dq_to_and_from_the_sdram		=> DRAM_DQ,
		zs_dqm_from_the_sdram				=> DQM,
		zs_ras_n_from_the_sdram				=> DRAM_RAS_N,
		zs_we_n_from_the_sdram				=> DRAM_WE_N,

		i2c_reg_in_port             => I2Cin,             --                            i2c_reg.in_port
      i2c_reg_out_port            => I2Cout             --                                   .out_port
	);
	
neg_3ns : sdram_pll
	port map (
		inclk0 => CLOCK_50,
		c0		 => DRAM_CLK,
		c1		 => system_clock
	);
	
------------------------------------------------------------
---------------affectation signaux  ------------------------
------------------------------------------------------------

		  
---------------------------------------------------------------
--  I2C -------------------------------------------------------
---------------------------------------------------------------
I2Cin  <= "000000"&GPIO_1(11)&GPIO_1(12); -- SCL in et SDA in
GPIO_1(11) <= I2Cout(1);  --SCL out
GPIO_1(12) <= 'Z' when I2Cout(0)='1' else  --SDA out
				  '0';

---------------------------------------------------------------
------------------------------------------------------------
--------------- PROCESS ------------------------------------
------------------------------------------------------------
--	process(system_clock,KEY(0))


end DE1_Basic_Computer_rtl;

