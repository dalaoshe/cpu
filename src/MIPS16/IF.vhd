----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:41:58 11/13/2016 
-- Design Name: 
-- Module Name:    IF - Behavioral 
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

entity IF is
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- ram
		data_ram_1 : inout std_logic_vector(15 downto 0);
		addr_ram_1 : out std_logic_vector(17 downto 0);
		EN_ram_1   : out std_logic := '0';
		WE_ram_1   : out std_logic := '1';
		OE_ram_1   : out std_logic := '1';
		
		data_ram_2 : inout std_logic_vector(15 downto 0);
		addr_ram_2 : out std_logic_vector(17 downto 0);
		EN_ram_2   : out std_logic := '1';
		WE_ram_2   : out std_logic := '1';
		OE_ram_2   : out std_logic := '1';
		
		signal if_ins : out std_logic_vector(15 downto 0) := "0000000000000000";
		signal if_pc  : out std_logic_vector(15 downto 0) := "0000000000000000";
		);
end IF;

architecture Behavioral of IF is
	type status is (s0,s1,s2,s3);
	signal now_s: status := s0;
begin







end Behavioral;

