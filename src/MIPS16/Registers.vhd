----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:40:27 11/19/2016 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
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

entity Registers is
	Port (
			clk        : in  STD_LOGIC;
			rst		  : in STD_LOGIC;
			--�Ƿ�Ҫд��ͨ�üĴ���
			WriteReg   : in  STD_LOGIC;
			--Ҫ��ȡ��ͨ�üĴ�����ַ
			Rx         : in  STD_LOGIC_VECTOR (2 downto 0);
			Ry         : in  STD_LOGIC_VECTOR (2 downto 0);
			--Ҫд�ص�ͨ�üĴ����ĵ�ַ
			RegWrite   : in  STD_LOGIC_VECTOR (2 downto 0);
			--Ҫд��ͨ�üĴ���������
			WriteData  : in  STD_LOGIC_VECTOR (15 downto 0);
			
			--Ҫд�������Ĵ����ĵ�ַ
			SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
			--Ҫ��ȡ������Ĵ����ĵ�ַ
			SpRegRead_i    : in  STD_LOGIC_VECTOR (1 downto 0);
			--�Ƿ�Ҫд������Ĵ���
			WriteSpReg_i  : in  STD_LOGIC;	
			
			--�жϻָ��ź�
			int_recover_i : in STD_LOGIC := '0';
			--�жϱ����ֳ��ź�
			mem_wb_int_module_i : in STD_LOGIC := '0';
			--��������
			int_signal_i  : in  STD_LOGIC_VECTOR (15 downto 0);
			int_buffer_pc_i  : in  STD_LOGIC_VECTOR (15 downto 0);
			
			-- �Ĵ���Ҫ���͸�ID/EXE��A��B��S
			A_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			B_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			r0_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			r1_o          : out  STD_LOGIC_VECTOR (15 downto 0);	
			r2_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			r3_o          : out  STD_LOGIC_VECTOR (15 downto 0);	
			r4_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			r5_o          : out  STD_LOGIC_VECTOR (15 downto 0);	
			r6_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			r7_o          : out  STD_LOGIC_VECTOR (15 downto 0);	
			T_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			IH_o          : out  STD_LOGIC_VECTOR (15 downto 0);
			SP_o          : out  STD_LOGIC_VECTOR (15 downto 0);			
			S_o          : out  STD_LOGIC_VECTOR (15 downto 0)
		);
end Registers;

architecture Behavioral of Registers is
	subtype array16 is STD_LOGIC_VECTOR(15 downto 0);
	
	constant zero16 : array16 := "0000000000000000";

	signal r0 : array16 := zero16;
	signal r1 : array16 := zero16;
	signal r2 : array16 := zero16;
	signal r3 : array16 := zero16;
	signal r4 : array16 := zero16;
	signal r5 : array16 := zero16;
	signal r6 : array16 := zero16;
	signal r7 : array16 := zero16;
	
	signal int_buffer_r0 : array16 := zero16;
	signal int_buffer_r1 : array16 := zero16;
	
	signal T : array16 := zero16;
	signal IH : array16 := zero16;
	signal SP : array16 := zero16;
	type status is (s0,s1,s2,s3);
	signal now_s: status := s0;
begin
	r0_o <= r0;
	r1_o <= r1;
	r2_o <= r2;
	r3_o <= r3;
	r4_o <= r4;
	r5_o <= r5;
	r6_o <= r6;
	r7_o <= r7;
	T_o <= T;
	IH_o <= IH;
	SP_o <= SP;
	process(clk,rst,WriteReg,WriteData,WriteSpReg_i,RegWrite)
	begin
		if rst = '0' then
			r0 <= zero16;
			r1 <= zero16;
			r2 <= zero16;
			r3 <= zero16;
			r4 <= zero16;
			r5 <= zero16;
			r6 <= zero16;
			r7 <= zero16;
			T <= zero16;
			IH <= zero16;
			SP <= zero16;
			int_buffer_r0 <= zero16;
			int_buffer_r1 <= zero16;
		elsif clk'event and clk = '1' then
			--дͨ�üĴ���
			case now_s is
			when s0 =>
				now_s <= s1;
				--�ָ��ж�ʱҪд��r0,r1
				if int_recover_i = '1' then
					r0 <= int_buffer_r0;
					r1 <= int_buffer_r1;
				end if;
			when s1 =>				
				if WriteReg = '1' then
					case RegWrite is
						when "000" =>
							r0 <= WriteData;
						when "001" =>
							r1 <= WriteData;
						when "010" =>
							r2 <= WriteData;
						when "011" =>
							r3 <= WriteData;
						when "100" =>
							r4 <= WriteData;
						when "101" =>
							r5 <= WriteData;
						when "110" =>
							r6 <= WriteData;
						when "111" =>
							r7 <= WriteData;
						when others =>
							-- do nothing
					end case;
				end if;
				
				--�ָ��ж�ʱҪд��r0,r1
				if int_recover_i = '1' then
					r0 <= int_buffer_r0;
					r1 <= int_buffer_r1;
				end if;
				--�����жϱ����ֳ�
				if mem_wb_int_module_i = '1' then
					int_buffer_r0 <= r0;
					int_buffer_r1 <= r1;
					SP <= "1011111100010000";
					r0 <= int_signal_i;
					r1 <= int_buffer_pc_i;
				end if;
				
				--д����Ĵ���
				if WriteSpReg_i = '1' then
					case SpRegWrite_i is
						when "00" =>
							T <= WriteData;
						when "01" =>
							IH <= WriteData;
						when "10" =>
							SP <= WriteData;
						when others =>
							--do nothing
					end case;
				end if;
				now_s <= s0;
			when others =>
				now_s <= s0;
			end case;
		end if;
	end process;
	
	
	process(clk,T,IH,SP,SpRegRead_i)
	begin
		--������Ĵ�����S
		case SpRegRead_i is
			when "00" =>
				S_o <= T;
			when "01" =>
				S_o <= IH;
			when "10" =>
				S_o <= SP;
			when others =>
				S_o <= zero16;
		end case;	
		if (SpRegRead_i = SpRegWrite_i and WriteSpReg_i = '1') then
			S_o <= WriteData;
		end if;
	end process;
	
	
	process(clk,Rx,r0,r1,r2,r3,r4,r5,r6,r7)
	begin
		--��Rx��A
		case Rx is
			when "000" =>
				A_o <= r0;
			when "001" =>
				A_o <= r1;
			when "010" =>
				A_o <= r2;
			when "011" =>
				A_o <= r3;
			when "100" =>
				A_o <= r4;
			when "101" =>
				A_o <= r5;
			when "110" =>
				A_o <= r6;
			when "111" =>
				A_o <= r7;
			when others =>
				A_o <= zero16;
		end case;

		if RegWrite = Rx and WriteReg = '1' then
			A_o <= WriteData;
		end if;
		
	end process;
	
	
	process(clk,Ry,r0,r1,r2,r3,r4,r5,r6,r7)
	begin
		--��Ry��B
		case Ry is
			when "000" =>
				B_o <= r0;
			when "001" =>
				B_o <= r1;
			when "010" =>
				B_o <= r2;
			when "011" =>
				B_o <= r3;
			when "100" =>
				B_o <= r4;
			when "101" =>
				B_o <= r5;
			when "110" =>
				B_o <= r6;
			when "111" =>
				B_o <= r7;
			when others =>
				B_o <= zero16;
		end case;
		
		if (RegWrite = Ry and WriteReg = '1') then
			B_o <= WriteData;
		end if;
		
	end process;
end Behavioral;

