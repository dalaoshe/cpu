----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:46:29 11/20/2016 
-- Design Name: 
-- Module Name:    ForwardUnit - Behavioral 
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

entity ForwardUnit is
    Port ( 
			   -- clk, rst
			  clk	   : in std_logic;
			  
			  --id_exe�ε���Ϣ
			  id_exe_rx               : in  std_logic_vector(2 downto 0);
           id_exe_ry               : in  std_logic_vector(2 downto 0);
			  id_exe_sp					  : in  std_logic_vector(1 downto 0);
			  
			  id_exe_ALUSrcA          : in  std_logic_vector(1 downto 0);
			  id_exe_ALUSrcB          : in  std_logic;
				
			  --id�ε���Ϣ(id�ο����õ���ǰ��)
			  id_rx               : in  std_logic_vector(2 downto 0);
           id_ry               : in  std_logic_vector(2 downto 0);
			  id_sp					 : in  std_logic_vector(1 downto 0);
			  -- id��ָ����jump����branch
			  id_jump				 : in std_logic;
			  id_branch				 : in std_logic;


			  --exe��ָ��Ҫд�ص�����Ĵ�����ַ
			  exe_SpRegWrite		  : in  std_logic_vector(1 downto 0);
			  --exe��ָ���Ƿ�д������Ĵ���
			  exe_WriteSpReg		  : in  std_logic;
			  --exe��ָ��Ҫд�ص���ͨ�Ĵ����ĵ�ַ
			  exe_RegDst	 		  : in  std_logic_vector(2 downto 0);
			  --exe��ָ���Ƿ�д����ͨ�Ĵ���
			  exe_RegWrite		  	  : in  std_logic;
			  exe_RegData				: in std_logic;

			  --exe_mem��ָ��Ҫд�ص�����Ĵ�����ַ
			  exe_mem_SpRegWrite		  : in  std_logic_vector(1 downto 0);
			  --exe_mem��ָ���Ƿ�д������Ĵ���
			  exe_mem_WriteSpReg		  : in  std_logic;
			  --exe_mem��ָ��Ҫд�ص���ͨ�Ĵ����ĵ�ַ
			  exe_mem_RegDst	 		  : in  std_logic_vector(2 downto 0);
			  --exe_mem��ָ���Ƿ�д����ͨ�Ĵ���
			  exe_mem_RegWrite		  : in  std_logic;
			  --wbҪд�ص���������alu����mem
			  exe_mem_RegData			  : in  std_logic;			  

			  
			  --mem_wb��ָ��Ҫд�ص�����Ĵ�����ַ
			  mem_wb_SpRegWrite		  : in  std_logic_vector(1 downto 0);
			  --mem_wb��ָ���Ƿ�д������Ĵ���
			  mem_wb_WriteSpReg		  : in  std_logic;
			  --mem_wb��ָ��Ҫд�ص���ͨ�Ĵ����ĵ�ַ
			  mem_wb_RegDst	 		  : in  std_logic_vector(2 downto 0);
			  --mem_wb��ָ���Ƿ�д����ͨ�Ĵ���
			  mem_wb_RegWrite		  	  : in  std_logic;

			  
			  
			  
			  
			--EXE��Ҫ�õ�����ǰ�ƿ����ź�
			ForwardA_exe         : out  std_logic_vector(1 downto 0);
			ForwardB_exe         : out  std_logic_vector(1 downto 0);
			--EXE��MEM_DataҪ�õ�����ǰ�ƿ����ź�
			ForwardMemDataA_exe         : out  std_logic_vector(1 downto 0);
			ForwardMemDataB_exe         : out  std_logic_vector(1 downto 0);

			--ID��Ҫ�õ�����ǰ�ƿ����ź�
			ForwardA_id         : out  std_logic_vector(2 downto 0);
 			ForwardS_id         : out  std_logic_vector(2 downto 0);
			
			--IF_IDָ���Ƿ񱣳�һ������
			stall_if_id			  : out std_logic

	);
end ForwardUnit;

architecture Behavioral of ForwardUnit is
	signal ForwardA_id_temp :std_logic_vector(2 downto 0) :="000";
	signal ForwardS_id_temp :std_logic_vector(2 downto 0) :="000";
begin
	-- exe��Ҫ�õ���ǰ�ƿ����ź� A
	process(clk,id_exe_ALUSrcA,exe_mem_RegWrite,exe_mem_RegDst,id_exe_rx,mem_wb_RegWrite,mem_wb_RegDst,exe_mem_WriteSpReg,exe_mem_SpRegWrite,id_exe_sp)
	begin
		case id_exe_ALUSrcA is
			-- alu���õĵ�һ������������rx
			when "00" =>
				-- exe_mem�ε�ָ��Ҫд��rx
				if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_rx then
					case exe_mem_RegData is
						--д����������alu���
						when '0' =>
							ForwardA_exe <= "01";
						--д�����������ڴ���
						when '1' =>
							ForwardA_exe <= "10";
						when others =>
							ForwardA_exe <= "00";
					end case;
				-- mem_wb��ָ��Ҫд��rx
				elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_rx then
					ForwardA_exe <= "11";
				-- ��ǰ��
				else
					ForwardA_exe <= "00";
				end if;
				
				
			-- alu���õĵ�һ����������������Ĵ���
			when "01" =>
				-- exe_mem�ε�ָ��Ҫд�ظ�����Ĵ���
				if exe_mem_WriteSpReg = '1' and exe_mem_SpRegWrite = id_exe_sp then					
					case exe_mem_RegData is
						--д����������alu���
						when '0' =>
							ForwardA_exe <= "01";
						--д�����������ڴ���
						when '1' =>
							ForwardA_exe <= "10";
						when others =>
							ForwardA_exe <= "00";
					end case;				
				-- mem_wb��ָ��Ҫд�ظ�����Ĵ���	
				elsif mem_wb_WriteSpReg = '1' and mem_wb_SpRegWrite = id_exe_sp then
					ForwardA_exe <= "11";
				-- ��ǰ��
				else
					ForwardA_exe <= "00";
				end if;
			-- ʹ��pc������������ǰ��
			when others =>
					ForwardA_exe <= "00";
		end case;
	end process;
	
	-- exe��Ҫ�õ���ǰ�ƿ����źţ��ڶ���������ry��imm��
	process(clk,id_exe_ALUSrcB,exe_mem_RegWrite,id_exe_ry,exe_mem_RegDst,mem_wb_RegWrite,mem_wb_RegDst)
	begin
		case id_exe_ALUSrcB is
			-- alu���õĵڶ�������������ry
			when '0' =>
				-- exe_mem�ε�ָ��Ҫд��ry
				if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_ry then
					case exe_mem_RegData is
						--д����������alu���
						when '0' =>
							ForwardB_exe <= "01";
						--д�����������ڴ���
						when '1' =>
							ForwardB_exe <= "10";
						when others =>
							ForwardB_exe <= "00";
					end case;
				-- mem_wb��ָ��Ҫд��ry
				elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_ry then
					ForwardB_exe <= "11";
				-- ��ǰ��
				else
					ForwardB_exe <= "00";
				end if;
			-- ʹ����������ǰ��
			when others =>
					ForwardB_exe <= "00";
		end case;
	end process;
	
	-- exe��mem_dataҪ�õ���ǰ�ƿ����źţ��ڶ���������ry��
	process(clk,exe_mem_RegWrite,exe_mem_RegDst,id_exe_ry,mem_wb_RegWrite,mem_wb_RegDst)
	begin
		if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_ry then
			case exe_mem_RegData is
				--д����������alu���
				when '0' =>
					ForwardMemDataB_exe <= "01";
				--д�����������ڴ���
				when '1' =>
					ForwardMemDataB_exe <= "10";
				when others =>
					ForwardMemDataB_exe <= "00";
			end case;
		-- mem_wb��ָ��Ҫд��ry
		elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_ry then
			ForwardMemDataB_exe <= "11";
		-- ��ǰ��
		else
			ForwardMemDataB_exe <= "00";
		end if;
	end process;
	
	-- exe��mem_dataҪ�õ���ǰ�ƿ����źţ���һ��������rx��
	process(clk,exe_mem_RegWrite,exe_mem_RegDst,id_exe_rx,mem_wb_RegWrite,mem_wb_RegDst)
	begin
		if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_rx then
			case exe_mem_RegData is
				--д����������alu���
				when '0' =>
					ForwardMemDataA_exe <= "01";
				--д�����������ڴ���
				when '1' =>
					ForwardMemDataA_exe <= "10";
				when others =>
					ForwardMemDataA_exe <= "00";
			end case;
		-- mem_wb��ָ��Ҫд��ry
		elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_rx then
			ForwardMemDataA_exe <= "11";
		-- ��ǰ��
		else
			ForwardMemDataA_exe <= "00";
		end if;
	end process;	
	
	-- id��Ҫ�õ���ǰ�ƿ����ź� rx(a)
	process(clk)
	begin
		if id_jump = '1' or id_branch = '1' then
			-- exe�ε�ָ��Ҫд��rx
			if exe_RegWrite = '1' and exe_RegDst = id_rx then
				case exe_RegData is
					--д����������alu���
					when '0' =>
						ForwardA_id <= "001";
						ForwardA_id_temp <= "001";
					--д�����������ڴ���(�����ݣ���)
					when '1' =>
						ForwardA_id <= "010";
						ForwardA_id_temp <= "010";
					--��ǰ��
					when others =>
						ForwardA_id <= "000";	
						ForwardA_id_temp <= "000";
				end case;
			-- exe_mem��ָ��Ҫд��rx
			elsif exe_mem_RegWrite = '1' and exe_mem_RegDst = id_rx then
				case exe_mem_RegData is
					--д����������alu���
					when '0' =>
						ForwardA_id <= "011";	
						ForwardA_id_temp <= "011";
					--д�����������ڴ���(��������)
					when '1' =>
						ForwardA_id <= "100";
						ForwardA_id_temp <= "100";
					--��ǰ��
					when others =>
						ForwardA_id <= "000";	
						ForwardA_id_temp <= "000";
				end case;
			--��ǰ��
			else
				ForwardA_id <= "000";
				ForwardA_id_temp <= "000";
			end if;	
		else 
			ForwardA_id <= "000";
			ForwardA_id_temp <= "000";
		end if;
	end process;
	
	
	-- id��Ҫ�õ���ǰ�ƿ����ź� s(s) ֻ��jump��branchָ����Ҫǰ��
	process(clk)
	begin
		if id_jump = '1' or id_branch = '1' then
			-- exe�ε�ָ��Ҫд�ظ�����Ĵ���
			if exe_WriteSpReg = '1' and exe_SpRegWrite = id_sp then			
				case exe_RegData is
					--д����������alu���
					when '0' =>
						ForwardS_id <= "001";
						ForwardS_id_temp <= "001";
					--д�����������ڴ����������ݣ�
					when '1' =>
						ForwardS_id <= "010";
						ForwardS_id_temp <= "010";
					--��ǰ��
					when others =>
						ForwardS_id <= "000";
						ForwardS_id_temp <= "000";
				end case;				
			-- mem_wb��ָ��Ҫд�ظ�����Ĵ���	
			elsif exe_mem_WriteSpReg = '1' and exe_mem_SpRegWrite = id_sp then
				case exe_mem_RegData is
					--д����������alu���
					when '0' =>
						ForwardS_id <= "011";
						ForwardS_id_temp <= "011";
					--д�����������ڴ������������ݣ�
					when '1' =>
						ForwardS_id <= "100";
						ForwardS_id_temp <= "100";
					--��ǰ��
					when others =>
						ForwardS_id <= "000";
						ForwardS_id_temp <= "000";
				end case;		
			-- ��ǰ��
			else
				ForwardS_id <= "000";
				ForwardS_id_temp <= "000";
			end if;	
		else
			ForwardS_id <= "000";
			ForwardS_id_temp <= "000";
		end if;
	end process;
	
	process(clk,ForwardS_id_temp,ForwardA_id_temp)
	begin
			
		if(ForwardS_id_temp = "010" or ForwardA_id_temp = "010") then	
			stall_if_id <= '1';
		else 
			stall_if_id <= '0';
		end if;
		
	end process;
	
	
end Behavioral;

