----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:02:15 11/14/2016 
-- Design Name: 
-- Module Name:    BranchControl - Behavioral 
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

entity BranchControl is
	port(
		--if/id��ָ���ַ
		pc_i: in STD_LOGIC_VECTOR (15 downto 0);
		--��ǰָ���Ƿ���B�ͻ���j��ָ��
		Branch: in std_logic;
		-- ��һ��B��ָ��		
		BType : in  STD_LOGIC_VECTOR (1 downto 0);
		Rx : in  STD_LOGIC_VECTOR (15 downto 0);
		T : in  STD_LOGIC_VECTOR (15 downto 0);
		imm : in  STD_LOGIC_VECTOR (15 downto 0);
		-- ��ת���� 
		Jump: in std_logic;
		-- �Ƿ���ת
		branch_flag_o : out  STD_LOGIC;
		-- ��ת��Ŀ���ַ
		branch_target_addr_o: out std_logic_vector(15 downto 0)
	);
end BranchControl;

architecture Behavioral of BranchControl is
	subtype array16 is std_logic_vector(15 downto 0);
	signal zero16 : array16 := "0000000000000000";
begin
	process(Branch, BType, Rx, T, imm, Jump, pc_i)
	begin
		--�ж�if_id�ε�ָ��
		if	Jump = '1' then
			--JRָ��
			branch_target_addr_o <= Rx;
			branch_flag_o <= '1';
		elsif Branch = '1' then
			--B��ָ��
			case BType is
				when "00" =>
					-- B
					branch_target_addr_o <= pc_i + imm;
					branch_flag_o <= '1';
				when "01" =>
					-- BEQZ
					if Rx = zero16 then
						branch_target_addr_o <= pc_i + imm;
						branch_flag_o <= '1';
					else
						branch_flag_o <= '0';
					end if;
				when "10" =>
					-- BNEZ
					if Rx /= zero16 then
						branch_target_addr_o <= pc_i + imm;
						branch_flag_o <= '1';
					else
						branch_flag_o <= '0';
					end if;
				when "11" =>
					-- BTEQZ
					if T = zero16 then
						branch_target_addr_o <= pc_i + imm;
						branch_flag_o <= '1';
					else
						branch_flag_o <= '0';
					end if;
				when others =>
					branch_flag_o <= '0';
			end case;
		else
			branch_flag_o <= '0';
		end if;
	end process;
end Behavioral;

