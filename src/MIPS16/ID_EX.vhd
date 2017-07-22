----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:37:45 11/13/2016 
-- Design Name: 
-- Module Name:    ID_EX - Behavioral 
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

entity ID_EX is
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
		
		--ID段传过来EXE阶段会用到的寄存器操作数A、B值和特殊寄存器值
		A_i: in std_logic_vector(15 downto 0);
		B_i: in std_logic_vector(15 downto 0);
		S_i: in std_logic_vector(15 downto 0);
		--EXE阶段会用到的寄存器操作数A、B值和特殊寄存器值
		A_o: out std_logic_vector(15 downto 0);
		B_o: out std_logic_vector(15 downto 0);
		S_o: out std_logic_vector(15 downto 0);
		
		--ID段传过来EXE阶段会用到的rx,ry,rz寄存器地址
		rx_i: in std_logic_vector(2 downto 0);
		ry_i: in std_logic_vector(2 downto 0);
		rz_i: in std_logic_vector(2 downto 0);
		--EXE阶段会用到的rx,ry,rz寄存器地址
		rx_o: out std_logic_vector(2 downto 0);
		ry_o: out std_logic_vector(2 downto 0);
		rz_o: out std_logic_vector(2 downto 0);
		
		--ID段传过来EXE阶段会用到的扩展后的立即数
		imm_i: in std_logic_vector(15 downto 0);
		--EXE阶段会用到的扩展后的立即数
		imm_o: out std_logic_vector(15 downto 0);
		
		
		--ID段传过来的控制信号
		
		
		
		--ALU的第一个操作数选择信号
		ALUSrcA_i     : in  STD_LOGIC_VECTOR (1 downto 0);
		ALUSrcA_o     : out  STD_LOGIC_VECTOR (1 downto 0);
		--ALU的第二个操作数选择信号
		ALUSrcB_i     : in  STD_LOGIC;	
		ALUSrcB_o    : out  STD_LOGIC;		
		--ALU进行的运算类型
		ALUOp_i       : in  STD_LOGIC_VECTOR (3 downto 0);
		ALUOp_o       : out  STD_LOGIC_VECTOR (3 downto 0);
		--要被写回的通用寄存器的地址选择信号(选择rx/ry/rz)		
		RegDst_i		: in std_logic_vector(1 downto 0);
		RegDst_o		: out std_logic_vector(1 downto 0);
		--该指令是否要写回通用寄存器
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--要被写回的寄存器的数据是ALU结果还是MEM结果
		RegData_i     : in  STD_LOGIC;	
		RegData_o     : out  STD_LOGIC;	

		--要写入的特殊寄存器的地址
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--要访问的特殊寄存器的地址
		SpRegRead_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegRead_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--是否要写回特殊寄存器
		WriteSpReg_i  : in  STD_LOGIC;	
		WriteSpReg_o  : out  STD_LOGIC;	
		--该指令访存时是否要读取内存
		MemRead_i     : in  STD_LOGIC;
		MemRead_o     : out  STD_LOGIC;
		--访存时是否要写入内存
		MemWrite_i    : in  STD_LOGIC;
		MemWrite_o    : out  STD_LOGIC;
		--要写入内存的数据选择自哪个寄存器
		MemData_i     : in  STD_LOGIC;
		MemData_o     : out  STD_LOGIC;
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC;
		
		--pc
		pc_i:in std_logic_vector(15 downto 0);
		pc_o:out std_logic_vector(15 downto 0)
		
	);
end ID_EX;

architecture Behavioral of ID_EX is
	type status is (s0,s1,s2,s3);
	signal now_s: status := s0;
begin
	process(clk,rst)
	begin
		if rst = '0' then
			now_s <= s0;
			A_o <= "0000000000000000";
			B_o<= "0000000000000000";
			S_o<= "0000000000000000";
			imm_o<= "0000000000000000";
			rx_o<="000";
			ry_o<="000";
			rz_o<="000";
			ALUSrcA_o     <= "00";
			ALUSrcB_o     <= '0';
			ALUOp_o       <= "0000";
			RegDst_o		  <= "00";
			RegWrite_o    <= '0';
			RegData_o     <= '0';
			SpRegWrite_o  <= "00";
			SpRegRead_o   <= "00";
			WriteSpReg_o  <= '0';
			MemRead_o     <= '0';
			MemWrite_o    <= '0';
			MemData_o     <= '0';
			pc_o				<= "0000000000000000";
			IntModule_o <= '0';	
		elsif clk'event and clk = '1' then			
			if flash_complete = '1' then	
				case now_s is
				when s0 =>
					if mem_stall_i = '0' then
						--操作数
						A_o <= A_i;
						B_o <= B_i;
						S_o <= S_i;
						pc_o <= pc_i;
						imm_o <= imm_i;
						--通用寄存器地址
						rx_o <= rx_i;
						ry_o <= ry_i;
						rz_o <= rz_i;
						--ALU控制信号
						ALUSrcA_o <= ALUSrcA_i;
						ALUSrcB_o <= ALUSrcB_i;
						ALUOp_o   <= ALUOp_i;
						--MEM控制信号
						MemRead_o <= MemRead_i;
						MemWrite_o <= MemWrite_i;
						MemData_o	<= MemData_i;
						--WB控制信号
							--通用寄存器
							RegDst_o <= RegDst_i;
							RegWrite_o <= RegWrite_i;
							RegData_o <= RegData_i;
							--特殊寄存器
							SpRegWrite_o <= SpRegWrite_i;
							SpRegRead_o <= SpRegRead_i;
							WriteSpReg_o <= WriteSpReg_i;
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

