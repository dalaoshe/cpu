----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:39:54 11/13/2016 
-- Design Name: 
-- Module Name:    MEM_WB - Behavioral 
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

entity MEM_WB is
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号
		flush		: in std_logic;
		--	取值阶段暂停
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash 完成
		flash_complete : in std_logic;
	
		-- MEM段传来的ALU计算结果数据
		ALUOut_i	: in	std_logic_vector(15 downto 0);
		ALUOut_o	: out	std_logic_vector(15 downto 0);
		-- MEM段传来的数据内存读取数据
		MEMData_i	: in	std_logic_vector(15 downto 0);		
		MEMData_o	: out	std_logic_vector(15 downto 0);
		
		
		
		-- 通用寄存器的写回
		--要被写回的通用寄存器的地址		
		RegDst_i		: in std_logic_vector(2 downto 0);
		RegDst_o		: out std_logic_vector(2 downto 0);
		--该指令是否要写回通用寄存器
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--要被写回的寄存器的数据是ALU结果还是MEM结果
		RegData_i     : in  STD_LOGIC;			
		RegData_o     : out  STD_LOGIC;
		
		
		-- 特殊寄存器的写回
		--要写入的特殊寄存器的地址
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--是否要写回特殊寄存器
		WriteSpReg_i  : in  STD_LOGIC;
		WriteSpReg_o  : out  STD_LOGIC;		
		
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC;		
		
		-- 要写回的数据
		WB_Data :out	std_logic_vector(15 downto 0)
	);
end MEM_WB;

architecture Behavioral of MEM_WB is
	type status is (s0,s1,s2,s3);
	signal now_s: status := s0;
begin
	process(clk)
	begin
		if rst = '0' then
				ALUOut_o	<= "0000000000000000";
				MEMData_o	<= "0000000000000000";
				RegDst_o		<= "000";
				RegWrite_o   <= '0';
				RegData_o     <= '0';
				SpRegWrite_o  <= "00";
				WriteSpReg_o  <= '0';
				IntModule_o   <= '0';
				WB_Data 			<= "0000000000000000";
				now_s <= s0;
		elsif clk'event and clk = '1' then			
			if flash_complete = '1' then	
				case now_s is
					when s0 =>
						if mem_stall_i = '0' then
							--通用寄存器控制信号						
							RegDst_o  <= RegDst_i;
							RegWrite_o <= RegWrite_i;
							--特殊寄存器控制信号
							SpRegWrite_o  <= SpRegWrite_i;
							WriteSpReg_o  <= WriteSpReg_i;
							--写回数据
							ALUOut_o <= ALUOut_i;
							MEMData_o <= MEMData_i;
							case RegData_i is
							when '0' =>
								WB_Data <= ALUOut_i;
							when '1' =>
								WB_Data <= MEMData_i;
							when others =>
								WB_Data <= ALUOut_i;
							end case;
							IntModule_o <= IntModule_i;
						end if;
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

