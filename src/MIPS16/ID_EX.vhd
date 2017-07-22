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
		-- ��ˮ������ź�
		flush		: in std_logic;
		--	ȡֵ�׶���ͣ
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash ���
		flash_complete : in std_logic;
		
		--ID�δ�����EXE�׶λ��õ��ļĴ���������A��Bֵ������Ĵ���ֵ
		A_i: in std_logic_vector(15 downto 0);
		B_i: in std_logic_vector(15 downto 0);
		S_i: in std_logic_vector(15 downto 0);
		--EXE�׶λ��õ��ļĴ���������A��Bֵ������Ĵ���ֵ
		A_o: out std_logic_vector(15 downto 0);
		B_o: out std_logic_vector(15 downto 0);
		S_o: out std_logic_vector(15 downto 0);
		
		--ID�δ�����EXE�׶λ��õ���rx,ry,rz�Ĵ�����ַ
		rx_i: in std_logic_vector(2 downto 0);
		ry_i: in std_logic_vector(2 downto 0);
		rz_i: in std_logic_vector(2 downto 0);
		--EXE�׶λ��õ���rx,ry,rz�Ĵ�����ַ
		rx_o: out std_logic_vector(2 downto 0);
		ry_o: out std_logic_vector(2 downto 0);
		rz_o: out std_logic_vector(2 downto 0);
		
		--ID�δ�����EXE�׶λ��õ�����չ���������
		imm_i: in std_logic_vector(15 downto 0);
		--EXE�׶λ��õ�����չ���������
		imm_o: out std_logic_vector(15 downto 0);
		
		
		--ID�δ������Ŀ����ź�
		
		
		
		--ALU�ĵ�һ��������ѡ���ź�
		ALUSrcA_i     : in  STD_LOGIC_VECTOR (1 downto 0);
		ALUSrcA_o     : out  STD_LOGIC_VECTOR (1 downto 0);
		--ALU�ĵڶ���������ѡ���ź�
		ALUSrcB_i     : in  STD_LOGIC;	
		ALUSrcB_o    : out  STD_LOGIC;		
		--ALU���е���������
		ALUOp_i       : in  STD_LOGIC_VECTOR (3 downto 0);
		ALUOp_o       : out  STD_LOGIC_VECTOR (3 downto 0);
		--Ҫ��д�ص�ͨ�üĴ����ĵ�ַѡ���ź�(ѡ��rx/ry/rz)		
		RegDst_i		: in std_logic_vector(1 downto 0);
		RegDst_o		: out std_logic_vector(1 downto 0);
		--��ָ���Ƿ�Ҫд��ͨ�üĴ���
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--Ҫ��д�صļĴ�����������ALU�������MEM���
		RegData_i     : in  STD_LOGIC;	
		RegData_o     : out  STD_LOGIC;	

		--Ҫд�������Ĵ����ĵ�ַ
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--Ҫ���ʵ�����Ĵ����ĵ�ַ
		SpRegRead_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegRead_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--�Ƿ�Ҫд������Ĵ���
		WriteSpReg_i  : in  STD_LOGIC;	
		WriteSpReg_o  : out  STD_LOGIC;	
		--��ָ��ô�ʱ�Ƿ�Ҫ��ȡ�ڴ�
		MemRead_i     : in  STD_LOGIC;
		MemRead_o     : out  STD_LOGIC;
		--�ô�ʱ�Ƿ�Ҫд���ڴ�
		MemWrite_i    : in  STD_LOGIC;
		MemWrite_o    : out  STD_LOGIC;
		--Ҫд���ڴ������ѡ�����ĸ��Ĵ���
		MemData_i     : in  STD_LOGIC;
		MemData_o     : out  STD_LOGIC;
		--�Ƿ����ж�
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
						--������
						A_o <= A_i;
						B_o <= B_i;
						S_o <= S_i;
						pc_o <= pc_i;
						imm_o <= imm_i;
						--ͨ�üĴ�����ַ
						rx_o <= rx_i;
						ry_o <= ry_i;
						rz_o <= rz_i;
						--ALU�����ź�
						ALUSrcA_o <= ALUSrcA_i;
						ALUSrcB_o <= ALUSrcB_i;
						ALUOp_o   <= ALUOp_i;
						--MEM�����ź�
						MemRead_o <= MemRead_i;
						MemWrite_o <= MemWrite_i;
						MemData_o	<= MemData_i;
						--WB�����ź�
							--ͨ�üĴ���
							RegDst_o <= RegDst_i;
							RegWrite_o <= RegWrite_i;
							RegData_o <= RegData_i;
							--����Ĵ���
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

