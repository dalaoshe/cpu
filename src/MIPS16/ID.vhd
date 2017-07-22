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
		
		-- ��ˮ������ź�
		flush		: in std_logic;
		--	ȡֵ�׶���ͣ
		stall		: in std_logic;

		--����׶ε�ָ���ַ�Ͷ�Ӧ��ָ��
		pc_i :  in std_logic_vector(15 downto 0) := "0000000000000000";
		inst_i : in std_logic_vector(15 downto 0) := "0000000000000000";
		
		
		-- ������ģ��Ŀ����ź�
		--������λ��Ҫ��չ��������
		ImmSrc      : out  STD_LOGIC_VECTOR (1 downto 0);
		--����������չ�����޷�����չ
		ImmExt      : out  STD_LOGIC;
		-- ��������չ��Ҫ�õ���չԭ����
		imm: out std_logic_vector(10 downto 0);
		

		
		-- �Ĵ�����ģ�����IDʱ��Ҫ�Ŀ����ź�
		-- EXE�׶λ��õ���rx,ry,rz�Ĵ�����ַ
		rx: out std_logic_vector(2 downto 0);
		ry: out std_logic_vector(2 downto 0);
		rz: out std_logic_vector(2 downto 0);		

		-- �Ĵ����Ѷ�ȡ�����ݺ�ǰ�ƻص�����
		-- �Ĵ�����
		A_i: in std_logic_vector(15 downto 0);
		B_i: in std_logic_vector(15 downto 0);
		S_i: in std_logic_vector(15 downto 0);		
		--����ָ�����������ALUֱ�������
		ForwardData_ALU1: in std_logic_vector(15 downto 0);
		ForwardData_MEM1: in std_logic_vector(15 downto 0);
		--������ָ�����������EXE/MEM��ALU��
		ForwardData_ALU2: in std_logic_vector(15 downto 0);
		ForwardData_MEM2: in std_logic_vector(15 downto 0);
		--����ǰ�ƿ����ź�
		ForwardA_i         : in  std_logic_vector(2 downto 0);
		ForwardS_i         : in  std_logic_vector(2 downto 0);
		
		--EXE�׶λ��õ��ļĴ���������A��Bֵ������Ĵ���ֵ(�Ĵ����ѵ���������ǰ�����ݵ�ѡ����)
		A_o: out std_logic_vector(15 downto 0);
		B_o: out std_logic_vector(15 downto 0);
		S_o: out std_logic_vector(15 downto 0);

		--���ݸ��¸��׶εĿ����ź�
		
		--ALU�ĵ�һ��������ѡ��
		ALUSrcA_o    : out  STD_LOGIC_VECTOR (1 downto 0);
		--ALU�ĵڶ���������ѡ��
		ALUSrcB_o     : out  STD_LOGIC;		
		--ALU���е���������
		ALUOp_o       : out  STD_LOGIC_VECTOR (3 downto 0);

		
	

		--�ô�׶ο����ź�
		--��ָ��ô�ʱ�Ƿ�Ҫ��ȡ�ڴ�
		MemRead_o     : out  STD_LOGIC;
		--�ô�ʱ�Ƿ�Ҫд���ڴ�
		MemWrite_o    : out  STD_LOGIC;
		--Ҫд���ڴ������ѡ�����ĸ��Ĵ���
		MemData_o     : out  STD_LOGIC;
	
	
		-- д�ؽ׶ο����ź�
		-- ͨ�üĴ���
		-- Ҫ��д�ص�ͨ�üĴ����ĵ�ַ(rx/ry/rz)
		RegDst_o		: out std_logic_vector(1 downto 0);
		--��ָ���Ƿ�Ҫд��ͨ�üĴ���
		RegWrite_o    : out  STD_LOGIC;
		--Ҫ��д�صļĴ�����������ALU�������MEM���
		RegData_o     : out  STD_LOGIC;	
		-- ����Ĵ���
		--Ҫд�������Ĵ����ĵ�ַ
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--Ҫ��ȡ������Ĵ����ĵ�ַ
		SpRegRead_o    : out  STD_LOGIC_VECTOR (1 downto 0);
		--�Ƿ�Ҫд������Ĵ���
		WriteSpReg_o  : out  STD_LOGIC;	
		
				
		
		
		--�Ƿ����ж�
		IntModule_o   : out  STD_LOGIC;
		
		--������һ��ָ��ȡָ��ʽ���ź�		
		BType       : out  STD_LOGIC_VECTOR (1 downto 0);
		Branch        : out  STD_LOGIC;
		Jump        : out  STD_LOGIC
		

		);
end ID;

architecture Behavioral of ID is

begin

	--A_o MUX �Ƿ�ѡ��ǰ��
	process(ForwardA_i,inst_i,A_i,ForwardData_ALU1,ForwardData_MEM1,ForwardData_ALU2,ForwardData_MEM2)
	begin
		case ForwardA_i is
			-- ʹ��id/exe
			when "000" =>
				A_o <= A_i;
				
			-- ����ָ���alu���
			when "001" =>
				A_o <= ForwardData_ALU1;
				
			-- ����ָ���mem�����
			when "010" =>
				A_o <= ForwardData_MEM1;
		
			-- ������ָ��ALU���
			when "011" =>
				A_o <= ForwardData_ALU2;
			when "100" =>
				A_o <= ForwardData_MEM2;
			when others =>
				A_o <= A_i;
		end case;		
	end process;
	
	--S_o MUX �Ƿ�ѡ��ǰ��
	process(ForwardS_i,inst_i,S_i,ForwardData_ALU1,ForwardData_MEM1,ForwardData_ALU2,ForwardData_MEM2)
	begin
		case ForwardS_i is
			-- ʹ��id/exe
			when "000" =>
				S_o <= S_i;
				
			-- ����ָ���alu���
			when "001" =>
				S_o <= ForwardData_ALU1;
				
			-- ����ָ���mem�����
			when "010" =>
				S_o <= ForwardData_MEM1;
		
			-- ������ָ��ALU���
			when "011" =>
				S_o <= ForwardData_ALU2;
			
			when "100" =>
				S_o <= ForwardData_MEM2;
			when others =>
				S_o <= S_i;
		end case;		
	end process;
	
	--B_o MUX �Ƿ�ѡ��ǰ��
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
					case inst(1 downto 0) is --���ݹ�����ѡ��
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

