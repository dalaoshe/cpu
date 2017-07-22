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
			  
			  --id_exe段的信息
			  id_exe_rx               : in  std_logic_vector(2 downto 0);
           id_exe_ry               : in  std_logic_vector(2 downto 0);
			  id_exe_sp					  : in  std_logic_vector(1 downto 0);
			  
			  id_exe_ALUSrcA          : in  std_logic_vector(1 downto 0);
			  id_exe_ALUSrcB          : in  std_logic;
				
			  --id段的信息(id段可能用到的前推)
			  id_rx               : in  std_logic_vector(2 downto 0);
           id_ry               : in  std_logic_vector(2 downto 0);
			  id_sp					 : in  std_logic_vector(1 downto 0);
			  -- id段指令是jump或者branch
			  id_jump				 : in std_logic;
			  id_branch				 : in std_logic;


			  --exe段指令要写回的特殊寄存器地址
			  exe_SpRegWrite		  : in  std_logic_vector(1 downto 0);
			  --exe段指令是否写回特殊寄存器
			  exe_WriteSpReg		  : in  std_logic;
			  --exe段指令要写回的普通寄存器的地址
			  exe_RegDst	 		  : in  std_logic_vector(2 downto 0);
			  --exe段指令是否写回普通寄存器
			  exe_RegWrite		  	  : in  std_logic;
			  exe_RegData				: in std_logic;

			  --exe_mem段指令要写回的特殊寄存器地址
			  exe_mem_SpRegWrite		  : in  std_logic_vector(1 downto 0);
			  --exe_mem段指令是否写回特殊寄存器
			  exe_mem_WriteSpReg		  : in  std_logic;
			  --exe_mem段指令要写回的普通寄存器的地址
			  exe_mem_RegDst	 		  : in  std_logic_vector(2 downto 0);
			  --exe_mem段指令是否写回普通寄存器
			  exe_mem_RegWrite		  : in  std_logic;
			  --wb要写回的数据来自alu还是mem
			  exe_mem_RegData			  : in  std_logic;			  

			  
			  --mem_wb段指令要写回的特殊寄存器地址
			  mem_wb_SpRegWrite		  : in  std_logic_vector(1 downto 0);
			  --mem_wb段指令是否写回特殊寄存器
			  mem_wb_WriteSpReg		  : in  std_logic;
			  --mem_wb段指令要写回的普通寄存器的地址
			  mem_wb_RegDst	 		  : in  std_logic_vector(2 downto 0);
			  --mem_wb段指令是否写回普通寄存器
			  mem_wb_RegWrite		  	  : in  std_logic;

			  
			  
			  
			  
			--EXE段要用的数据前推控制信号
			ForwardA_exe         : out  std_logic_vector(1 downto 0);
			ForwardB_exe         : out  std_logic_vector(1 downto 0);
			--EXE段MEM_Data要用的数据前推控制信号
			ForwardMemDataA_exe         : out  std_logic_vector(1 downto 0);
			ForwardMemDataB_exe         : out  std_logic_vector(1 downto 0);

			--ID段要用的数据前推控制信号
			ForwardA_id         : out  std_logic_vector(2 downto 0);
 			ForwardS_id         : out  std_logic_vector(2 downto 0);
			
			--IF_ID指令是否保持一个周期
			stall_if_id			  : out std_logic

	);
end ForwardUnit;

architecture Behavioral of ForwardUnit is
	signal ForwardA_id_temp :std_logic_vector(2 downto 0) :="000";
	signal ForwardS_id_temp :std_logic_vector(2 downto 0) :="000";
begin
	-- exe段要用到的前推控制信号 A
	process(clk,id_exe_ALUSrcA,exe_mem_RegWrite,exe_mem_RegDst,id_exe_rx,mem_wb_RegWrite,mem_wb_RegDst,exe_mem_WriteSpReg,exe_mem_SpRegWrite,id_exe_sp)
	begin
		case id_exe_ALUSrcA is
			-- alu所用的第一个操作数来自rx
			when "00" =>
				-- exe_mem段的指令要写回rx
				if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_rx then
					case exe_mem_RegData is
						--写回数据来子alu结果
						when '0' =>
							ForwardA_exe <= "01";
						--写回数据来自内存结果
						when '1' =>
							ForwardA_exe <= "10";
						when others =>
							ForwardA_exe <= "00";
					end case;
				-- mem_wb段指令要写回rx
				elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_rx then
					ForwardA_exe <= "11";
				-- 不前推
				else
					ForwardA_exe <= "00";
				end if;
				
				
			-- alu所用的第一个操作数来自特殊寄存器
			when "01" =>
				-- exe_mem段的指令要写回该特殊寄存器
				if exe_mem_WriteSpReg = '1' and exe_mem_SpRegWrite = id_exe_sp then					
					case exe_mem_RegData is
						--写回数据来子alu结果
						when '0' =>
							ForwardA_exe <= "01";
						--写回数据来自内存结果
						when '1' =>
							ForwardA_exe <= "10";
						when others =>
							ForwardA_exe <= "00";
					end case;				
				-- mem_wb段指令要写回该特殊寄存器	
				elsif mem_wb_WriteSpReg = '1' and mem_wb_SpRegWrite = id_exe_sp then
					ForwardA_exe <= "11";
				-- 不前推
				else
					ForwardA_exe <= "00";
				end if;
			-- 使用pc和立即数都不前推
			when others =>
					ForwardA_exe <= "00";
		end case;
	end process;
	
	-- exe段要用到的前推控制信号（第二个操作数ry或imm）
	process(clk,id_exe_ALUSrcB,exe_mem_RegWrite,id_exe_ry,exe_mem_RegDst,mem_wb_RegWrite,mem_wb_RegDst)
	begin
		case id_exe_ALUSrcB is
			-- alu所用的第二个操作数来自ry
			when '0' =>
				-- exe_mem段的指令要写回ry
				if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_ry then
					case exe_mem_RegData is
						--写回数据来子alu结果
						when '0' =>
							ForwardB_exe <= "01";
						--写回数据来自内存结果
						when '1' =>
							ForwardB_exe <= "10";
						when others =>
							ForwardB_exe <= "00";
					end case;
				-- mem_wb段指令要写回ry
				elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_ry then
					ForwardB_exe <= "11";
				-- 不前推
				else
					ForwardB_exe <= "00";
				end if;
			-- 使用立即数不前推
			when others =>
					ForwardB_exe <= "00";
		end case;
	end process;
	
	-- exe段mem_data要用到的前推控制信号（第二个操作数ry）
	process(clk,exe_mem_RegWrite,exe_mem_RegDst,id_exe_ry,mem_wb_RegWrite,mem_wb_RegDst)
	begin
		if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_ry then
			case exe_mem_RegData is
				--写回数据来子alu结果
				when '0' =>
					ForwardMemDataB_exe <= "01";
				--写回数据来自内存结果
				when '1' =>
					ForwardMemDataB_exe <= "10";
				when others =>
					ForwardMemDataB_exe <= "00";
			end case;
		-- mem_wb段指令要写回ry
		elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_ry then
			ForwardMemDataB_exe <= "11";
		-- 不前推
		else
			ForwardMemDataB_exe <= "00";
		end if;
	end process;
	
	-- exe段mem_data要用到的前推控制信号（第一个操作数rx）
	process(clk,exe_mem_RegWrite,exe_mem_RegDst,id_exe_rx,mem_wb_RegWrite,mem_wb_RegDst)
	begin
		if exe_mem_RegWrite = '1' and exe_mem_RegDst = id_exe_rx then
			case exe_mem_RegData is
				--写回数据来子alu结果
				when '0' =>
					ForwardMemDataA_exe <= "01";
				--写回数据来自内存结果
				when '1' =>
					ForwardMemDataA_exe <= "10";
				when others =>
					ForwardMemDataA_exe <= "00";
			end case;
		-- mem_wb段指令要写回ry
		elsif mem_wb_RegWrite = '1' and mem_wb_RegDst = id_exe_rx then
			ForwardMemDataA_exe <= "11";
		-- 不前推
		else
			ForwardMemDataA_exe <= "00";
		end if;
	end process;	
	
	-- id段要用到的前推控制信号 rx(a)
	process(clk)
	begin
		if id_jump = '1' or id_branch = '1' then
			-- exe段的指令要写回rx
			if exe_RegWrite = '1' and exe_RegDst = id_rx then
				case exe_RegData is
					--写回数据来子alu结果
					when '0' =>
						ForwardA_id <= "001";
						ForwardA_id_temp <= "001";
					--写回数据来自内存结果(插气泡！！)
					when '1' =>
						ForwardA_id <= "010";
						ForwardA_id_temp <= "010";
					--不前推
					when others =>
						ForwardA_id <= "000";	
						ForwardA_id_temp <= "000";
				end case;
			-- exe_mem段指令要写回rx
			elsif exe_mem_RegWrite = '1' and exe_mem_RegDst = id_rx then
				case exe_mem_RegData is
					--写回数据来子alu结果
					when '0' =>
						ForwardA_id <= "011";	
						ForwardA_id_temp <= "011";
					--写回数据来自内存结果(不插气泡)
					when '1' =>
						ForwardA_id <= "100";
						ForwardA_id_temp <= "100";
					--不前推
					when others =>
						ForwardA_id <= "000";	
						ForwardA_id_temp <= "000";
				end case;
			--不前推
			else
				ForwardA_id <= "000";
				ForwardA_id_temp <= "000";
			end if;	
		else 
			ForwardA_id <= "000";
			ForwardA_id_temp <= "000";
		end if;
	end process;
	
	
	-- id段要用到的前推控制信号 s(s) 只有jump和branch指令需要前推
	process(clk)
	begin
		if id_jump = '1' or id_branch = '1' then
			-- exe段的指令要写回该特殊寄存器
			if exe_WriteSpReg = '1' and exe_SpRegWrite = id_sp then			
				case exe_RegData is
					--写回数据来子alu结果
					when '0' =>
						ForwardS_id <= "001";
						ForwardS_id_temp <= "001";
					--写回数据来自内存结果（插气泡）
					when '1' =>
						ForwardS_id <= "010";
						ForwardS_id_temp <= "010";
					--不前推
					when others =>
						ForwardS_id <= "000";
						ForwardS_id_temp <= "000";
				end case;				
			-- mem_wb段指令要写回该特殊寄存器	
			elsif exe_mem_WriteSpReg = '1' and exe_mem_SpRegWrite = id_sp then
				case exe_mem_RegData is
					--写回数据来子alu结果
					when '0' =>
						ForwardS_id <= "011";
						ForwardS_id_temp <= "011";
					--写回数据来自内存结果（不插气泡）
					when '1' =>
						ForwardS_id <= "100";
						ForwardS_id_temp <= "100";
					--不前推
					when others =>
						ForwardS_id <= "000";
						ForwardS_id_temp <= "000";
				end case;		
			-- 不前推
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

