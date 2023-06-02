
library IEEE;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstructionReg is
    Port ( input : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0);
           sig : in  STD_LOGIC;
			  CLK : in STD_LOGIC);
end InstructionReg;

architecture Behavioral of InstructionReg is

begin

process(input, sig, CLK)

begin
if rising_edge(CLK) and sig='1' then
output<=input;
end if;
end process;

end Behavioral;

