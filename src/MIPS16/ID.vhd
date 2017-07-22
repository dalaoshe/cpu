----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:37:21 11/13/2016 
-- Design Name: 
-- Module Name:    ID - Behavioral 
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

entity ID is
port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;
		
		-- 流水线清除信号
		flush		: in std_logic;
		--	取值阶段暂停
		stall		: in std_logic;

		--译码阶段的指令地址和对应的指令
		pc_i :  in std_logic_vector(15 downto 0) := "0000000000000000";
		inst_i : in std_logic_vector(15 downto 0) := "0000000000000000";
		
		
		-- 立即数模块的控制信号
		--决定如何获得要扩展的立即数
		ImmSrc      : out  STD_LOGIC_VECTOR (1 downto 0);
		--决定符号扩展还是无符号扩展
		ImmExt      : out  STD_LOGIC;
		-- 立即数扩展器要用的扩展原数据
		imm: out std_logic_vector(10 downto 0);
		

		
		-- 寄存器堆模块的在ID时需要的控制信号
		-- EXE阶段会用到的rx,ry,rz寄存器地址
		rx: out std_logic_vector(2 downto 0);
		ry: out std_logic_vector(2 downto 0);
		rz: out std_logic_vector(2 downto 0);		

		-- 寄存器堆读取的数据和前推回的数据
		-- 寄存器堆
		A_i: in std_logic_vector(15 downto 0);
		B_i: in std_logic_vector(15 downto 0);
		S_i: in std_logic_vector(15 downto 0);		
		--上条指令的运算结果（ALU直接输出）
		ForwardData_ALU1: in std_logic_vector(15 downto 0);
		ForwardData_MEM1: in std_logic_vector(15 downto 0);
		--上上条指令的运算结果（EXE/MEM的ALU）
		ForwardData_ALU2: in std_logic_vector(15 downto 0);
		ForwardData_MEM2: in std_logic_vector(15 downto 0);
		--数据前推控制信号
		ForwardA_i         : in  std_logic_vector(2 downto 0);
		ForwardS_i         : in  std_logic_vector(2 downto 0);
		
		--EXE阶段会用到的寄存器操作数A、B值和特殊寄存器值(寄存器堆得输出结果和前推数据的选择结果)
		A_o: out std_logic_vector(15 downto 0);
		B_o: out std_logic_vector(15 downto 0);
		S_o: out std_logic_vector(15 downto 0);

		--传递给下个阶段的控制信号
		
		--ALU的第一个操作数选择
		ALUSrcA_o    : out  STD_LOGIC_VECTOR (1 downto 0);
		--ALU的第二个操作数选择
		ALUSrcB_o     : out  STD_LOGIC;		
		--ALU进行的运算类型
		ALUOp_o       : out  STD_LOGIC_VECTOR (3 downto 0);

		
	

		--访存阶段控制信号
		--该指令访存时是否要读取内存
		MemRead_o     : out  STD_LOGIC;
		--访存时是否要写入内存
		MemWrite_o    : out  STD_LOGIC;
		--要写入内存的数据选择自哪个寄存器
		MemData_o     : out  STD_LOGIC;
	
	
		-- 写回阶段控制信号
		-- 通用寄存器
		-- 要被写回的通用寄存器的地址(rx/ry/rz)
		RegDst_o		: out std_logic_vector(1 downto 0);
		--该指令是否要写回通用寄存器
		RegWrite_o    : out  STD_LOGIC;
		--要被写回的寄存器的数据是ALU结果还是MEM结果
		RegData_o     : out  STD_LOGIC;	
		-- 特殊寄存器
		--要写入的特殊寄存器的地址
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--要读取的特殊寄存器的地址
		SpRegRead_o    : out  STD_LOGIC_VECTOR (1 downto 0);
		--是否要写回特殊寄存器
		WriteSpReg_o  : out  STD_LOGIC;	
		
				
		
		
		--是否在中断
		IntModule_o   : out  STD_LOGIC;
		
		--控制下一条指令取指方式的信号		
		BType       : out  STD_LOGIC_VECTOR (1 downto 0);
		Branch        : out  STD_LOGIC;
		Jump        : out  STD_LOGIC
		

		);
end ID;

architecture Behavioral of ID is

begin

	--A_o MUX 是否选择前推
	process(ForwardA_i,inst_i,A_i,ForwardData_ALU1,ForwardData_MEM1,ForwardData_ALU2,ForwardData_MEM2)
	begin
		case ForwardA_i is
			-- 使用id/exe
			when "000" =>
				A_o <= A_i;
				
			-- 上条指令的alu结果
			when "001" =>
				A_o <= ForwardData_ALU1;
				
			-- 上条指令的mem读结果
			when "010" =>
				A_o <= ForwardData_MEM1;
		
			-- 上上条指令ALU结果
			when "011" =>
				A_o <= ForwardData_ALU2;
			when "100" =>
				A_o <= ForwardData_MEM2;
			when others =>
				A_o <= A_i;
		end case;		
	end process;
	
	--S_o MUX 是否选择前推
	process(ForwardS_i,inst_i,S_i,ForwardData_ALU1,ForwardData_MEM1,ForwardData_ALU2,ForwardData_MEM2)
	begin
		case ForwardS_i is
			-- 使用id/exe
			when "000" =>
				S_o <= S_i;
				
			-- 上条指令的alu结果
			when "001" =>
				S_o <= ForwardData_ALU1;
				
			-- 上条指令的mem读结果
			when "010" =>
				S_o <= ForwardData_MEM1;
		
			-- 上上条指令ALU结果
			when "011" =>
				S_o <= ForwardData_ALU2;
			
			when "100" =>
				S_o <= ForwardData_MEM2;
			when others =>
				S_o <= S_i;
		end case;		
	end process;
	
	--B_o MUX 是否选择前推
	process(inst_i,B_i)
	begin
		B_o <= B_i;
	end process;
	
	process(clk, inst_i)
	variable inst : STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";	
	begin		
				inst := inst_i;
			case inst(15 downto 11) is
				when "00001" =>
					-- NOP
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0000"; --XXXX

					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "00"  ; --XX
					ImmExt     <= '0'   ; --X
					imm		   <= inst(10 downto 0);
					

					
					IntModule_o  <= '0';
				when "00010" =>
					-- B
					-- PC <-- PC + Sign_extend(immediate)
					Branch     <= '1'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "11"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);

					IntModule_o  <= '0';
				when "00100" =>
					-- BEQZ
					-- if (B[x] = 0) then PC <-- PC + Sign_extend(immediate)
					Branch     <= '1'   ;
					BType      <= "01"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);

					
					IntModule_o  <= '0';
				when "00101" =>
					-- BNEZ
					-- if (B[x] != 0) then PC <-- PC + Sign_extend(immediate)
					Branch     <= '1'   ;
					BType      <= "10"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
					

					
					IntModule_o  <= '0';
				when "00110" =>
					-- SLL SRA SRL
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "10"  ; --XX
					ALUSrcB_o    <= '0'   ; --X
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "01"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
					

					
					IntModule_o  <= '0';
					case inst(1 downto 0) is --根据功能码选择
						when "00" =>
							-- SLL
							-- if (immediate = 0) then R[x] <-- R[y] << 8
							-- if (immediate != 0) then R[x] <-- R[y] << immediate(unsigned)
							ALUOp_o      <= "1001"; --XXXX
						when "10" =>
							-- SRL
							-- if (immediate = 0) then R[x] <-- R[y] >> 8 (logic)
							-- if (immediate != 0) then R[x] <-- R[y] >> immediate (logic)
							ALUOp_o      <= "1010"; --XXXX
						when "11" =>
							-- SRA
							-- if (immediate = 0) then R[x] <-- R[y] >> 8 (arithmetic)
							-- if (immediate != 0) then R[x] <-- R[y] >> immediate (arithmetic)
							ALUOp_o      <= "1011"; --XXXX
						when others =>
							ALUOp_o      <= "1010"; --XXXX
					end case;
				when "01000" =>
					-- ADDIU3
					-- R[y] <-- R[x] + Sign_extend(immediate)
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "01"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "00"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
	
					
					IntModule_o  <= '0';
				when "01001" =>
					-- ADDIU
					-- R[x] <-- R[x] + Sign_extend(immediate)
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);

					
					IntModule_o  <= '0';
				when "01100" =>
					-- MTSP ADDSP BTEQZ
					case inst(10 downto 8) is
						when "100" =>
							-- MTSP
							-- SP <-- R[y]
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "10"  ; --XX
							WriteSpReg_o <= '1'   ;
							
							ALUSrcA_o    <= "00"  ; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0101"; --XXXX
							
							
							rx			<= inst(7 downto 5);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

							
							IntModule_o  <= '0';
						when "011" =>
							-- ADDSP
							-- SP <-- SP + Sign_extend(immediate)
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "10"  ; --XX
							SpRegWrite_o <= "10"  ; --XX
							WriteSpReg_o <= '1'   ;
							
							ALUSrcA_o    <= "01"  ; --XX
							ALUSrcB_o    <= '1'   ; --X
							ALUOp_o      <= "0000"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "10"  ; --XX
							ImmExt     <= '1'   ; --X
							imm		   <= inst(10 downto 0);
							

							
							IntModule_o  <= '0';
						when "000" =>
							-- BTEQZ
							-- if (T == 0) then PC <-- PC + Sign_extend(immediate)
							Branch     <= '1'   ;
							BType      <= "11"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"  ; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0000"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "10"  ; --XX
							ImmExt     <= '1'   ; --X
							imm		   <= inst(10 downto 0);
							

							
							IntModule_o  <= '0';
						when others =>
							Branch     <= '1'   ;
							BType      <= "11"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"  ; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0000"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

							
							IntModule_o  <= '0';
					end case;
				when "01101" =>
					-- LI
					-- R[x] <-- Zero_extend(immediate)
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "10"; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0101"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '0'   ; --X
					imm		   <= inst(10 downto 0);

					
					IntModule_o  <= '0';
				when "01110" =>
					-- CMPI
					-- if (R[x] = Sign_extend(immediate)) then T <-- 0
					-- if (R[x] != Sign_extend(immediate)) then T <-- 1
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '1'   ;
					
					ALUSrcA_o    <= "00"  ; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0111"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
					

					
					IntModule_o  <= '0';
				when "10010" =>
					-- LW_SP
					-- R[x] <-- MEM[SP + Sign_extend(immediate)]
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '1'   ; --X
					
					SpRegRead_o   <= "10"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "01"; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '1'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
	
					
					IntModule_o  <= '0';
				when "10011" =>
					-- LW
					-- R[y] <-- MEM[R[x] + Sign_extend(immediate)]
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "01"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '1'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '1'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "01"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
					

					
					IntModule_o  <= '0';
				when "11010" =>
					-- SW_SP
					-- MEM[SP + Sign_extend(immediate)] <-- R[x]
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "10"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "01"; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '1'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "10"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
					
	
					IntModule_o  <= '0';
				when "11011" =>
					-- SW
					-- MEM[R[x] + Sign_extend(immediate)] <-- R[y]
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"; --XX
					ALUSrcB_o    <= '1'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '1'   ;
					MemData_o    <= '1'   ; --X
					
					ImmSrc     <= "01"  ; --XX
					ImmExt     <= '1'   ; --X
					imm		   <= inst(10 downto 0);
					

					IntModule_o  <= '0';
				when "11100" =>
					-- ADDU SUBU-- X
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "10"  ; --XX
					RegWrite_o   <= '1'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"; --XX
					ALUSrcB_o    <= '0'   ; --X
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "00"  ; --XX
					ImmExt     <= '0'   ; --X
					imm		   <= inst(10 downto 0);
					

					IntModule_o  <= '0';
					case inst(1 downto 0) is
						when "01" =>
							-- ADDU
							-- R[z] <-- R[x] + R[y]
							ALUOp_o      <= "0000"; --XXXX
						when "11" =>
							-- SUBU
							-- R[z] <-- R[x] - R[y]
							ALUOp_o      <= "0001"; --XXXX
						when others =>
							ALUOp_o      <= "0001"; --XXXX
					end case;
				when "11101" =>
					-- AND OR NOT CMP SLT MFPC JR SRAV
					case inst(4 downto 0) is
						when "01100" =>
							-- AND
							-- R[x] <-- R[x] & R[y]
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '1'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0010"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

							IntModule_o  <= '0';
						when "01101" =>
							-- OR
							-- R[x] <-- R[x] | R[y]
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '1'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0011"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);

							IntModule_o  <= '0';
						when "01111" => 
							-- NOT
							-- R[x] <-- ~R[y]
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '1'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0100"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);

							IntModule_o  <= '0';
						when "01010" =>
							-- CMP
							-- if (R[x] = R[y]) then T <-- 0
							-- if (R[x] != R[y]) then T <-- 1
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '1'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0111"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);

							IntModule_o  <= '0';							
						when "00011" =>
							--  SLTU
							-- if (R[x] < R[y]) then T <-- 1 (unsigned)
							-- if (R[x] >= R[y]) then T <-- 0 (unsigned)
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '1'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "1000"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

							IntModule_o  <= '0';
						when "00000" =>
							-- MFPC JR
							IntModule_o  <= '0';
							case inst(7 downto 5) is
								when "010" =>
									-- MFPC
									-- R[x] <-- PC
									Branch     <= '0'   ;
									BType      <= "00"  ; --XX
									Jump       <= '0'   ;
									
									RegDst_o     <= "00"  ; --XX
									RegWrite_o   <= '1'   ;
									RegData_o    <= '0'   ; --X
									
									SpRegRead_o   <= "00"  ; --XX
									SpRegWrite_o <= "00"  ; --XX
									WriteSpReg_o <= '0'   ;
									
									ALUSrcA_o    <= "11"; --XX
									ALUSrcB_o    <= '0'   ; --X
									ALUOp_o      <= "0101"; --XXXX
									
									
									rx			<= inst(10 downto 8);
									ry			<= inst(7 downto 5);
									rz			<= inst(4 downto 2);
									
									MemRead_o    <= '0'   ;
									MemWrite_o   <= '0'   ;
									MemData_o    <= '0'   ; --X
									
									ImmSrc     <= "00"  ; --XX
									ImmExt     <= '0'   ; --X
									imm		   <= inst(10 downto 0);
									
								when "000" =>
									-- JR
									-- PC <-- R[x]
									Branch     <= '0'   ;
									BType      <= "00"  ; --XX
									Jump       <= '1'   ;
									
									RegDst_o     <= "00"  ; --XX
									RegWrite_o   <= '0'   ;
									RegData_o    <= '0'   ; --X
									
									SpRegRead_o   <= "00"  ; --XX
									SpRegWrite_o <= "00"  ; --XX
									WriteSpReg_o <= '0'   ;
									
									ALUSrcA_o    <= "00"; --XX
									ALUSrcB_o    <= '0'   ; --X
									ALUOp_o      <= "0000"; --XXXX
									
									
									rx			<= inst(10 downto 8);
									ry			<= inst(7 downto 5);
									rz			<= inst(4 downto 2);
									
									MemRead_o    <= '0'   ;
									MemWrite_o   <= '0'   ;
									MemData_o    <= '0'   ; --X
									
									ImmSrc     <= "00"  ; --XX
									ImmExt     <= '0'   ; --X
									imm		   <= inst(10 downto 0);
									

								when others =>
									Branch     <= '0'   ;
									BType      <= "00"  ; --XX
									Jump       <= '1'   ;
									
									RegDst_o     <= "00"  ; --XX
									RegWrite_o   <= '0'   ;
									RegData_o    <= '0'   ; --X
									
									SpRegRead_o   <= "00"  ; --XX
									SpRegWrite_o <= "00"  ; --XX
									WriteSpReg_o <= '0'   ;
									
									ALUSrcA_o    <= "00"; --XX
									ALUSrcB_o    <= '0'   ; --X
									ALUOp_o      <= "0000"; --XXXX
									
									
									rx			<= inst(10 downto 8);
									ry			<= inst(7 downto 5);
									rz			<= inst(4 downto 2);
									
									MemRead_o    <= '0'   ;
									MemWrite_o   <= '0'   ;
									MemData_o    <= '0'   ; --X
									
									ImmSrc     <= "00"  ; --XX
									ImmExt     <= '0'   ; --X
									imm		   <= inst(10 downto 0);

							end case;
						when "00111" =>
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "01"  ; --XX
							RegWrite_o   <= '1'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"  ; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "1100";
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

							
							IntModule_o  <= '0';							
						when others =>
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'  ; --X
							ALUOp_o      <= "0000"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);

					end case;
					IntModule_o  <= '0';
				when "11110" =>
					-- MFIH MTIH
					IntModule_o  <= '0';
					case inst(7 downto 0) is
						when "00000000" =>
							-- MFIH
							-- R[x] <-- IH
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '1'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "01"  ; --XX
							SpRegWrite_o <= "00"  ; --XX
							WriteSpReg_o <= '0'   ;
							
							ALUSrcA_o    <= "01"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0101"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);

						when "00000001" =>
							-- MTIH
							-- IH <-- R[x]
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "01"  ; --XX
							WriteSpReg_o <= '1'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0101"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

						when others =>
							Branch     <= '0'   ;
							BType      <= "00"  ; --XX
							Jump       <= '0'   ;
							
							RegDst_o     <= "00"  ; --XX
							RegWrite_o   <= '0'   ;
							RegData_o    <= '0'   ; --X
							
							SpRegRead_o   <= "00"  ; --XX
							SpRegWrite_o <= "01"  ; --XX
							WriteSpReg_o <= '1'   ;
							
							ALUSrcA_o    <= "00"; --XX
							ALUSrcB_o    <= '0'   ; --X
							ALUOp_o      <= "0101"; --XXXX
							
							
							rx			<= inst(10 downto 8);
							ry			<= inst(7 downto 5);
							rz			<= inst(4 downto 2);
							
							MemRead_o    <= '0'   ;
							MemWrite_o   <= '0'   ;
							MemData_o    <= '0'   ; --X
							
							ImmSrc     <= "00"  ; --XX
							ImmExt     <= '0'   ; --X
							imm		   <= inst(10 downto 0);
							

					end case;
				when "11111" =>
					-- INT
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "00"  ; --XX
					ImmExt     <= '0'   ; --X
					imm		   <= inst(10 downto 0);

					IntModule_o <= '1';
				when others =>
					Branch     <= '0'   ;
					BType      <= "00"  ; --XX
					Jump       <= '0'   ;
					
					RegDst_o     <= "00"  ; --XX
					RegWrite_o   <= '0'   ;
					RegData_o    <= '0'   ; --X
					
					SpRegRead_o   <= "00"  ; --XX
					SpRegWrite_o <= "00"  ; --XX
					WriteSpReg_o <= '0'   ;
					
					ALUSrcA_o    <= "00"; --XX
					ALUSrcB_o    <= '0'   ; --X
					ALUOp_o      <= "0000"; --XXXX
					
					
					rx			<= inst(10 downto 8);
					ry			<= inst(7 downto 5);
					rz			<= inst(4 downto 2);
					
					MemRead_o    <= '0'   ;
					MemWrite_o   <= '0'   ;
					MemData_o    <= '0'   ; --X
					
					ImmSrc     <= "00"  ; --XX
					ImmExt     <= '0'   ; --X
					imm		   <= inst(10 downto 0);
					
					IntModule_o  <= '0';
			end case;
	end process;
end Behavioral;

