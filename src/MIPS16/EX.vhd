----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:38:39 11/13/2016 
-- Design Name: 
-- Module Name:    EX - Behavioral 
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

entity EX is
	port(
	   -- clk, rst
		clk	   : in std_logic;
		--ID/EXE保存的寄存器操作数A、B值和特殊寄存器值
		pc_i: in std_logic_vector(15 downto 0);
		A_i: in std_logic_vector(15 downto 0);
		B_i: in std_logic_vector(15 downto 0);
		S_i: in std_logic_vector(15 downto 0);
		--ID段传过来EXE阶段会用到的扩展后的立即数
		imm_i: in std_logic_vector(15 downto 0);
		--上条指令的运算结果
		ForwardData1_alu: in std_logic_vector(15 downto 0);
		--上条指令的内存结果
		ForwardData1_mem: in std_logic_vector(15 downto 0);
		--上上条指令的运算结果
		ForwardData2: in std_logic_vector(15 downto 0);
		
		--ID/EXE保存的rx,ry,rz寄存器地址
		rx_i: in std_logic_vector(2 downto 0);
		ry_i: in std_logic_vector(2 downto 0);
		rz_i: in std_logic_vector(2 downto 0);

		
		--ALU的第一个操作数选择信号
		ALUSrcA_i     : in  STD_LOGIC_VECTOR (1 downto 0);
		--ALU的第二个操作数选择信号
		ALUSrcB_i     : in  STD_LOGIC;		
		--数据前推控制信号
		ForwardA_i         : in  std_logic_vector(1 downto 0);
		ForwardB_i         : in  std_logic_vector(1 downto 0);
		--数据前推控制信号
		ForwardMemDataA_i         : in  std_logic_vector(1 downto 0);
		ForwardMemDataB_i         : in  std_logic_vector(1 downto 0);		
		--ALU进行的运算类型
		ALUOp_i       : in  STD_LOGIC_VECTOR (3 downto 0);
		-- ALU的计算结果
		ALUOut	: out	std_logic_vector(15 downto 0);
		


		-- 要写回通用寄存器的选择
		--	要被写回的通用寄存器的地址选择信号(选择rx/ry/rz)		
		RegDst_i		: in std_logic_vector(1 downto 0);
		-- 选择的地址 000,001...
		RegDst_o		: out std_logic_vector(2 downto 0);

		

		
		-- 要写入内存的数据选择自哪个寄存器
		MemData_i     : in  STD_LOGIC;
		-- 要写入内存的数据
		MemData_o	: out	std_logic_vector(15 downto 0)
		
	);
end EX;

architecture Behavioral of EX is
	signal input_A:std_logic_vector(15 downto 0):="0000000000000000";
	signal input_B:std_logic_vector(15 downto 0):="0000000000000000";
begin
	--ALU
	process(clk,ALUOp_i,input_A,input_B)
	begin
	case ALUOp_i is
			when "0000" =>
				ALUOut <= input_A + input_B;
			when "0001" =>
				ALUOut <= input_A - input_B;
			when "0010" =>
				ALUOut <= input_A AND input_B;
			when "0011" =>
				ALUOut <= input_A OR input_B;
			when "0100" =>
				ALUOut <= NOT input_B;
			when "0101" =>
				ALUOut <= input_A;
			when "0110" =>
				ALUOut <= input_B;
			when "0111" =>
				if input_A /= input_B then
					ALUOut <= "0000000000000001";
				else
					ALUOut <= "0000000000000000";
				end if;
			when "1000" =>
				--SLTU
				if input_A < input_B then
					ALUOut <= "0000000000000001";
				else
					ALUOut <= "0000000000000000";
				end if;
				
			when "1001" =>
				-- SLL
				if input_A(4 downto 2) = "000" then
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SLL 8);
				else
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SLL conv_integer(input_A(4 downto 2)));
				end if;
			when "1010" =>
				-- SRL
				if input_A(4 downto 2) = "000" then
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SRL 8);
				else
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SRL conv_integer(input_A(4 downto 2)));
				end if;
			when "1011" =>
				-- SRA
				if input_A(4 downto 2) = "000" then
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SRA 8);
				else
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SRA conv_integer(input_A(4 downto 2)));
				end if;
			when "1100" =>
				-- SRAV
					ALUOut <= to_stdlogicvector(to_bitvector(input_B) SRA conv_integer(input_A));
			when others =>
				ALUOut <= input_A;
		end case;
	end process;

	--InputA MUX
	process(clk,ForwardA_i,ALUSrcA_i,ForwardData1_alu,ForwardData1_mem,ForwardData2)
	begin
		case ForwardA_i is
			-- 使用id/exe
			when "00" =>
				case ALUSrcA_i is
					when "00" =>
						input_A <= A_i;
					when "01" =>
						input_A <= S_i;
					when "10" =>
						input_A <= imm_i;
					when "11" =>
						input_A <= pc_i;
					when others =>
						input_A <= "0000000000000000";
				end case;
			-- 上条指令的alu结果
			when "01" =>
				input_A <= ForwardData1_alu;
			-- 上条指令的mem读结果
			when "10" =>
				input_A <= ForwardData1_mem;
				-- 上上条指令结果
			when "11" =>
				input_A <= ForwardData2;
			when others =>
				input_A <= "0000000000000000";
		end case;
		
	end process;
	
	--InputB MUX
	process(clk,ForwardB_i,ALUSrcB_i,ForwardData1_alu,ForwardData1_mem,ForwardData2)
	begin
		case ForwardB_i is
			-- 使用id/exe
			when "00" =>
				case ALUSrcB_i is
					when '0' =>
						input_B <= B_i;
					when '1' =>
						input_B <= imm_i;
					when others =>
						input_B <= "0000000000000000";
				end case;
			-- 上条指令的alu结果
			when "01" =>
				input_B <= ForwardData1_alu;
			-- 上条指令的mem读结果
			when "10" =>
				input_B <= ForwardData1_mem;
				-- 上上条指令结果
			when "11" =>
				input_B <= ForwardData2;
			when others =>
				input_B <= "0000000000000000";
		end case;
	end process;
	
	--Register MUX
	process(clk,RegDst_i)
	begin
		case RegDst_i is
			when "00" =>
				RegDst_o <= rx_i;
			when "01" =>
				RegDst_o <= ry_i;
			when "10" =>
				RegDst_o <= rz_i;
			when others =>
				RegDst_o <= "000";
		end case;
	end process;
	
	--MemData Mux
	process(clk,MemData_i,ForwardMemDataA_i,ForwardMemDataB_i,ForwardData1_mem,ForwardData1_alu,ForwardData2)
	begin
		case MemData_i is
			-- A_i
			when '0' =>
				-- 是否前推
				case ForwardMemDataA_i is
					-- 使用id/exe
					when "00" =>
						MemData_o <= A_i;
					-- 上条指令的alu结果
					when "01" =>
						MemData_o <= ForwardData1_alu;
					-- 上条指令的mem读结果
					when "10" =>
						MemData_o <= ForwardData1_mem;
						-- 上上条指令结果
					when "11" =>
						MemData_o <= ForwardData2;
					when others =>
						MemData_o <= "0000000000000000";
				end case;
			-- B_i	
			when '1' =>
				-- 是否前推
				case ForwardMemDataB_i is
					-- 使用id/exe
					when "00" =>
						MemData_o <= B_i;
					-- 上条指令的alu结果
					when "01" =>
						MemData_o <= ForwardData1_alu;
					-- 上条指令的mem读结果
					when "10" =>
						MemData_o <= ForwardData1_mem;
						-- 上上条指令结果
					when "11" =>
						MemData_o <= ForwardData2;
					when others =>
						MemData_o <= "0000000000000000";
				end case;
			when others =>
				MemData_o <= "0000000000000000";
		end case;		
	end process;
	
end Behavioral;

