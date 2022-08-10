library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity bindechex is
				port (vin : in STD_LOGIC_VECTOR (3 DOWNTO 0);
				fins : in std_logic;
				      hexout : out STD_LOGIC_VECTOR (6 DOWNTO 0)
				);
end bindechex;

architecture A1 of bindechex is
type hexlut is array ( integer range <>) of  STD_LOGIC_VECTOR (7 DOWNTO 0);
signal tabhex : hexlut( 0 to 15):=(X"3F",X"06",X"5B",X"4F",
														X"66",X"6D",X"7D",X"07",
														X"7F",X"6F",X"77",X"7C",
														X"39",X"5E",X"79",X"71");
														
-- signal tabhex : hexlut( 0 to 15):=(X"40",X"79",X"24",X"30",
														-- X"19",X"12",X"02",X"78",
														-- X"00",X"10",X"08",X"03",
														-- X"27",X"21",X"04",X"0E");
	
signal   local : std_LOGIC_VECTOR (7 downto 0);
begin
affich: process(fins) is
begin 
	if (fins = '1') then
		local <= tabhex(to_integer(unsigned(vin)));
		hexout <= not(local(6 downto 0));
	end if;
end process;
end A1;
