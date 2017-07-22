----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:35:36 11/13/2016 
-- Design Name: 
-- Module Name:    PC - Behavioral 
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

entity PC is
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号
		flush		: in std_logic;
		--	pc保持信号
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash 完成
		flash_complete : in std_logic;		
		--	分支跳转信号
		branch_flag_i	: in std_logic;
		-- jump
		jump_i	: in std_logic;
		-- 执行分支或跳转时的目标地址
		branch_target_addr_i: in std_logic_vector(15 downto 0) := "0000000000000000";	
		
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		int_recover_o : out STD_LOGIC;
		int_signal_o  : out std_logic_vector(15 downto 0) := "0000000000000000";
		-- 中断时缓存指令
		int_pc_o  : out std_logic_vector(15 downto 0) := "0000000000000000";	
		
		-- 取值阶段的指令地址		
		if_pc  : out std_logic_vector(15 downto 0) := "0000000000000000";
		-- if_id段输出指令
		if_id_ins_i : in std_logic_vector(15 downto 0) := "0000000000000000"
		);
end PC;

architecture Behavioral of PC is
	type status is (s0,s1,s2,s3);
	-- 输出本条指令的地址，保存下一条指令的地址
	signal pc  : std_logic_vector(15 downto 0) := "0000000000000000";
	signal int_buffer_pc  : std_logic_vector(15 downto 0) := "0000000000000000";
	signal int_state  : std_logic := '0';
	signal int_signal  : std_logic_vector(15 downto 0) := "0000000000000000";
	signal now_s: status := s0;
begin
	process(clk,rst)
	begin		
		if rst = '0' then
			pc <= "0000000000000000";
			int_buffer_pc <= "0000000000000000";
			int_state <= '0';
			
			int_recover_o <= '0';			
			int_signal_o <= "0000000000000000";
			int_pc_o     <= "0000000000000000";
			if_pc   <= "0000000000000000";
			now_s <= s0;
		elsif clk'event and clk = '1' then			
			if flash_complete = '1' then	
				case now_s is
					when s0 =>
							
							now_s <= s1;
					when s1 =>
						-- INT恢复，ID段为JR R6
						if jump_i = '1' and if_id_ins_i(10 downto 8) = "110" and int_state = '1' then
							int_recover_o <= '1';
							int_state <= '0';
						else
							int_recover_o <= '0';
						end if;
						
						--准备下一条指令
						if stall = '0' and mem_stall_i = '0' then
							if branch_flag_i = '1' then
								pc <= branch_target_addr_i + 1;
								if_pc <= branch_target_addr_i;
							--INT
							elsif IntModule_i = '1' then
								--标志int状态
								int_state <= '1';
								--获取中断信号
								int_signal_o <= "000000000000" & if_id_ins_i(3 downto 0);
								--缓存pc
								int_buffer_pc <= pc ;--+ "0000000000000001";
								int_pc_o		  <= pc ;--+ "0000000000000001";							
								--准备好中断指令地址
								pc <= "0000000000000110";
								if_pc <= "0000000000000101";
							else
								pc <= pc + "0000000000000001";
								if_pc <= pc;
							end if;
						end if;
						
						now_s <= s0;
					when others =>
						now_s <= s0;
						pc <= "0000000000000000";
				end case;
			end if;
		end if;
	end process;

end Behavioral;

