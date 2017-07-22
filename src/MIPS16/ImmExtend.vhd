----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:19:43 11/14/2016 
-- Design Name: 
-- Module Name:    ImmExtend - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ImmExtend is
	Port (
		ImmSrc : in  std_logic_vector(1 downto 0) := "00";
		ImmExt : in  std_logic := '0';
		ImmInput : in  std_logic_vector(10 downto 0) := "00000000000";
		ImmOutput : out  std_logic_vector(15 downto 0) := "0000000000000000");		
end ImmExtend;

architecture Behavioral of ImmExtend is
	subtype array16 is std_logic_vector(15 downto 0);

	function zero_extend4(Imm : std_logic_vector(3 downto 0)) return array16 is
	begin
		return "000000000000" & Imm;
	end function;
	
	function zero_extend5(Imm : std_logic_vector(4 downto 0)) return array16 is
	begin
		return "00000000000" & Imm;
	end function;
	
	function zero_extend8(Imm : std_logic_vector(7 downto 0)) return array16 is
	begin
		return "00000000" & Imm;
	end function;
	
	function zero_extend11(Imm : std_logic_vector(10 downto 0)) return array16 is
	begin
		return "00000" & Imm;
	end function;

	function sign_extend4(Imm : std_logic_vector(3 downto 0)) return array16 is
	begin
		if Imm(3) = '1' then
			return "111111111111" & Imm;
		else
			return "000000000000" & Imm;
		end if;
	end function;
	
	function sign_extend5(Imm : std_logic_vector(4 downto 0)) return array16 is
	begin
		if Imm(4) = '1' then
			return "11111111111" & Imm;
		else
			return "00000000000" & Imm;
		end if;
	end function;
	
	function sign_extend8(Imm : std_logic_vector(7 downto 0)) return array16 is
	begin
		if Imm(7) = '1' then
			return "11111111" & Imm;
		else
			return "00000000" & Imm;
		end if;
	end function;
	
	function sign_extend11(Imm : std_logic_vector(10 downto 0)) return array16 is
	begin
		if Imm(10) = '1' then
			return "11111" & Imm;
		else
			return "00000" & Imm;
		end if;
	end function;

begin
	process (ImmSrc, ImmExt, ImmInput)
	begin
		case ImmSrc is
			when "00" =>
				-- Imm3_0
				case ImmExt is
					when '1' =>
						ImmOutput <= sign_extend4(ImmInput(3 downto 0));
					when '0' =>
						ImmOutput <= zero_extend4(ImmInput(3 downto 0));
					when others =>
						ImmOutput <= zero_extend4(ImmInput(3 downto 0));
				end case;
			when "01" =>
				-- Imm4_0
				case ImmExt is
					when '1' =>
						ImmOutput <= sign_extend5(ImmInput(4 downto 0));
					when '0' =>
						ImmOutput <= zero_extend5(ImmInput(4 downto 0));
					when others =>
						ImmOutput <= zero_extend5(ImmInput(4 downto 0));
				end case;
			when "10" =>
				-- Imm7_0
				case ImmExt is
					when '1' =>
						ImmOutput <= sign_extend8(ImmInput(7 downto 0));
					when '0' =>
						ImmOutput <= zero_extend8(ImmInput(7 downto 0));
					when others =>
						ImmOutput <= zero_extend8(ImmInput(7 downto 0));
				end case;
			when "11" =>
				-- Imm10_0
				case ImmExt is
					when '1' =>
						ImmOutput <= sign_extend11(ImmInput(10 downto 0));
					when '0' =>
						ImmOutput <= zero_extend11(ImmInput(10 downto 0));
					when others =>
						ImmOutput <= zero_extend11(ImmInput(10 downto 0));
				end case;
			when others =>	
				ImmOutput <= "00000" & ImmInput;
		end case;
	end process;

end Behavioral;

