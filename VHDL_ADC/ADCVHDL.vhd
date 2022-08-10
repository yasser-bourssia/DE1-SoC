LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;


library work;
use work.all;


entity ADCv is 

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

end ADCv;

architecture interface of ADCv is 



component Clock_Divider is 

port ( clk,reset: in std_logic;
clock_out: out std_logic);

end component;



type state_t is (startup, ready, conv_start, start, data_r);

signal state: state_t;
signal clk_80ns,reset : std_logic;
signal add2,add1,add0 : std_logic;
signal count : integer range 0 to 50 := 0;
signal i: integer range 0 to 20000:= 0;
signal index : integer range 0 to 11:=0;
--signal add2,add1,add0 : std_logic;


begin

divi: Clock_Divider 
port map(
clk => clks,
reset => resets,
clock_out => clk_80ns);



--add0 <= '0';
--add1 <= '1';
--add2 <= '1';
--clock_out <= clk_80ns;



ADC_CTRL: process(clk_80ns) is



begin


if (resets = '0') then 
		state <= startup;
		count <= 0;
		--din <= '0';

elsif falling_edge	(clk_80ns) then
				
		case state is

			when startup =>  -- Startup time, MODE '01' => Waiting time = 1ùs for startup
				if count < 24 then
					count <= count + 1;
					state <= startup;
				else 
				
					state <= ready;
					count <= 0;
				end if;
				
			
			when ready =>
				count <= 0;
				index <= 0;
				add2 <= add(2);
				add1 <= add(1);
				add0 <= add(0);
				
				if (start_signal ='1') then -- Start signal
					state <= conv_start;
					end if;
					
			when conv_start =>
						data (11 downto 0) <= "000000000000";
						count <= 0;
						index <= 0;
						state <= start;
						i <= 0;
						fin <= '0';
						

			when start => -- DIN - DOUT Manipulation
--			if count = 1 or count = 2 or count = 6 or count = 8 or count = 9 or count = 10 then
--				din <= '0';
--			elsif count = 0 or count = 7 or count = 11 then
--				din <= '1';
--			else 
--				din <='0';
--			end if;	
			
--			if count = 3 then
--				din <= add2;
--			elsif count = 4 then
--				din <= add1;
--			elsif count = 5 then
--				din <= add0;
--			end if;
		
			if count > 3 and count < 17 then -- DOUT BITS PUT INTO DATA
				data(11-index) <= dout;
				index <= index+1;
				--count <= count +1;
				state <= start;
			end if;
			if count = 16 then
				count <= 0;
				state <= data_r;
				
			end if;
			count <= count + 1;
			if count = 15 then
				data(0) <= dout;
			end if;
			
			when data_r =>
			fin <= '1';
				if (start_signal = '1') then
					
						if i < 12 then
							i <= i + 1;
								else 
									state <= conv_start;
						end if;
				else 
				
					state <= ready;
					
				end if;
				
		end case;
	end if;
	
end process ADC_CTRL;

			

with state select
		sclk <= (clk_80ns) when start|ready,
				'1' when conv_start|data_r, -- Clock for start & stop conditions 
				'0' when others;
				
				
with state select
		convst <= '1' when conv_start, -- Start conditionx
					'1' when data_r, -- Stop condition
					'0' when others;
					
with count select
		din <= '1' when 0,
				'1' when 6,
				'1' when 7,
				'1' when 11,
				'0' when 10,
			add2 when 3,
			add1 when 4,
			add0 when 5,
			'0' when others;
					

end interface;