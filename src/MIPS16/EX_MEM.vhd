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
		-- ��ˮ������ź�
		flush		: in std_logic;
		--	ȡֵ�׶���ͣ
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash ���
		flash_complete : in std_logic;
		
		-- ͨ�üĴ�����д���ź�
		--Ҫ��д�ص�ͨ�üĴ����ĵ�ַ		
		RegDst_i		: in std_logic_vector(2 downto 0);
		RegDst_o		: out std_logic_vector(2 downto 0);
		--��ָ���Ƿ�Ҫд��ͨ�üĴ���
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--Ҫ��д�صļĴ�����������ALU�������MEM���
		RegData_i     : in  STD_LOGIC;				
		RegData_o     : out  STD_LOGIC;
		
		
		-- ����Ĵ�����д���ź�
		--Ҫд�������Ĵ����ĵ�ַ
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--�Ƿ�Ҫд������Ĵ���
		WriteSpReg_i  : in  STD_LOGIC;
		WriteSpReg_o  : out  STD_LOGIC;	
		
		
		--��ָ��ô�ʱ�Ƿ�Ҫ��ȡ�ڴ�
		MemRead_i     : in  STD_LOGIC;
		MemRead_o     : out  STD_LOGIC;
		--�ô�ʱ�Ƿ�Ҫд���ڴ�
		MemWrite_i    : in  STD_LOGIC;		
		MemWrite_o    : out  STD_LOGIC;
		
		
		-- EXE�δ�����ALU������
		ALUOut_i	: in	std_logic_vector(15 downto 0);
		ALUOut_o	: out	std_logic_vector(15 downto 0);
		-- EXE�δ�����Ҫд���ڴ��ֵ
		MEMData_i	: in	std_logic_vector(15 downto 0);					
		MEMData_o	: out	std_logic_vector(15 downto 0);

		--�Ƿ����ж�
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
							--MEM�����ź�
							MemRead_o <= MemRead_i;
							MemWrite_o <= MemWrite_i;
							MEMData_o <= MEMData_i;
							--ALU
							ALUOut_o <= ALUOut_i;
							--WB�����ź�
								--ͨ�üĴ���
								RegDst_o <= RegDst_i;
								RegWrite_o <= RegWrite_i;
								--����Ĵ���
								SpRegWrite_o <= SpRegWrite_i;
								WriteSpReg_o <= WriteSpReg_i;
							--д��������Դ�����ź�
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

