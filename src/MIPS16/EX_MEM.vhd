----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:39:12 11/13/2016 
-- Design Name: 
-- Module Name:    EX_MEM - Behavioral 
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

entity EX_MEM is
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
		
		-- 通用寄存器的写回信号
		--要被写回的通用寄存器的地址		
		RegDst_i		: in std_logic_vector(2 downto 0);
		RegDst_o		: out std_logic_vector(2 downto 0);
		--该指令是否要写回通用寄存器
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--要被写回的寄存器的数据是ALU结果还是MEM结果
		RegData_i     : in  STD_LOGIC;				
		RegData_o     : out  STD_LOGIC;
		
		
		-- 特殊寄存器的写回信号
		--要写入的特殊寄存器的地址
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--是否要写回特殊寄存器
		WriteSpReg_i  : in  STD_LOGIC;
		WriteSpReg_o  : out  STD_LOGIC;	
		
		
		--该指令访存时是否要读取内存
		MemRead_i     : in  STD_LOGIC;
		MemRead_o     : out  STD_LOGIC;
		--访存时是否要写入内存
		MemWrite_i    : in  STD_LOGIC;		
		MemWrite_o    : out  STD_LOGIC;
		
		
		-- EXE段传来的ALU计算结果
		ALUOut_i	: in	std_logic_vector(15 downto 0);
		ALUOut_o	: out	std_logic_vector(15 downto 0);
		-- EXE段传来的要写回内存的值
		MEMData_i	: in	std_logic_vector(15 downto 0);					
		MEMData_o	: out	std_logic_vector(15 downto 0);

		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC
		
	);
end EX_MEM;

architecture Behavioral of EX_MEM is
	type status is (s0,s1,s2,s3);
	signal now_s: status := s0;
begin
	process(clk,rst)
	begin
		if rst = '0' then
			now_s <= s0;
			RegDst_o <= "000";
			RegWrite_o    <= '0';
			RegData_o     <= '0';
			SpRegWrite_o  <= "00";
			WriteSpReg_o  <= '0';
			MemRead_o     <= '0';
			MemWrite_o    <= '0';
			ALUOut_o		  <=  "0000000000000000";
			MEMData_o	  <=  "0000000000000000";
			IntModule_o   <= '0';
			
			
		elsif clk'event and clk = '1' then			
			if flash_complete = '1' then	
				case now_s is
					when s0 =>
						if mem_stall_i = '0' then
							--MEM控制信号
							MemRead_o <= MemRead_i;
							MemWrite_o <= MemWrite_i;
							MEMData_o <= MEMData_i;
							--ALU
							ALUOut_o <= ALUOut_i;
							--WB控制信号
								--通用寄存器
								RegDst_o <= RegDst_i;
								RegWrite_o <= RegWrite_i;
								--特殊寄存器
								SpRegWrite_o <= SpRegWrite_i;
								WriteSpReg_o <= WriteSpReg_i;
							--写回数据来源控制信号
							RegData_o <= RegData_i;
							IntModule_o <= IntModule_i;
						end if;
						now_s <= s1;											
					when s1 =>
						now_s <= s0;					
					when others=>
						now_s <= s0;
				end case;
			end if;
		end if;
	end process;
end Behavioral;

