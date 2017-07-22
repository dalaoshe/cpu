----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:37:01 11/13/2016 
-- Design Name: 
-- Module Name:    IF_ID - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IF_ID is
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号,插入nop
		flush		: in std_logic;
		--	取值阶段暂停（保持一个周期）
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash boot完毕
		flash_complete : in std_logic;
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC;
		
		if_pc  : in std_logic_vector(15 downto 0) := "0000000000000000";
		if_inst  : in std_logic_vector(15 downto 0) := "0000000000000000";

		id_pc :  out std_logic_vector(15 downto 0) := "0000000000000000";
		id_inst : out std_logic_vector(15 downto 0) := "0000000000000000"
		);
end IF_ID;

architecture Behavioral of IF_ID is
	type status is (s0,s1,s2,s3);
	--缓存地址和指令
	signal pc  : std_logic_vector(15 downto 0) := "0000000000000000";
	signal inst  : std_logic_vector(15 downto 0) := "0000000000000000";
	shared variable nop  : std_logic_vector(15 downto 0) := "0000100000000000";
	signal now_s: status := s0;
begin

	process(clk,rst)
	begin
		if rst = '0' then
			IntModule_o <= '0';
			id_pc	<= "0000000000000000";
			id_inst <= "0000000000000000";
			pc    <= "0000000000000000";
			inst  <= "0000000000000000";
			now_s <= s0;
		elsif clk'event and clk = '1' then			
			if flash_complete = '1' then		
				case now_s is
					when s0 =>
						if stall = '1' or mem_stall_i = '1' then
							--保持
							id_pc <= pc;
							id_inst <= inst;
						--elsif flush = '1' then
							--强制Nop插入气泡
					--		id_pc	<= pc;
					--		id_inst <= nop;
						else
							id_pc <= if_pc;-- + "0000000000000001";
							id_inst <= if_inst;
							pc <= if_pc;-- + "0000000000000001";
							inst <= if_inst;
						end if;
						IntModule_o <= IntModule_i;
						now_s <= s1;
					when s1 =>
						now_s <= s0;
					when others =>
						now_s <= s0;
				end case;						
			end if;
		end if;
	end process;
end Behavioral;

