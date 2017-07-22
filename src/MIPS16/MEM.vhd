----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:39:24 11/13/2016 
-- Design Name: 
-- Module Name:    MEM - Behavioral 
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

entity MEM is
	port(		
		rst : in std_logic;
		clk 			: in std_logic;
		stall_i			: in std_logic;
		
		-- �ڴ��д�����ź�
		MemWrite_i		: in std_logic;
		MemRead_i		: in std_logic;
		-- Ҫд�������ڴ��ֵ
		MEMData_i	: in	std_logic_vector(15 downto 0);					
		-- Ҫд�����������ڴ�ĵ�ַ
		MEMAddr_i		: in std_logic_vector(15 downto 0);
		-- �������ڴ������ֵ
		MEMData_o	: out	std_logic_vector(15 downto 0);		
	
				
		-- Ҫ��ָ���ڴ��ȡ�ĵ�ַ
		InsAddr_i 		: in std_logic_vector(15 downto 0);
		-- ��ȡ��ָ��
		Ins_o		: out std_logic_vector(15 downto 0);
		
		
		--���ڹܽ�
		tbre			: in std_logic;
		tsre			: in std_logic;
		rdn 			: inout std_logic;
		wrn				: inout std_logic;
		data_ready		: in std_logic;	
		--ram1�ܽ�
		ram1_en 		: out std_logic;
		ram1_oe			: out std_logic;
		ram1_we			: out std_logic;
		ram1_addr		: out std_logic_vector(15 downto 0);
		ram1_data		: inout std_logic_vector(15 downto 0);
		--ram2�ܽ�
		ram2_en			: out std_logic;
		ram2_oe			: out std_logic;
		ram2_we			: out std_logic;
		ram2_addr		: out std_logic_vector(15 downto 0);
		ram2_data		: inout std_logic_vector(15 downto 0);
		
		--flash
		flash_byte : out std_logic := '1';
		flash_vpen : out std_logic := '1';
		flash_CE   : out std_logic;
		flash_OE   : out std_logic;
		flash_WE   : out std_logic;
		flash_RP   : out std_logic := '1';
		flash_addr : out std_logic_vector(22 downto 0);
		flash_data : inout std_logic_vector(15 downto 0);
		
		--flash complete
		flash_complete_o : out std_logic;
		pro_addr_o : out std_logic_vector(15 downto 0);
		--MEM stall
		mem_stall_o : out std_logic
			
	);
end MEM;

architecture Behavioral of MEM is
	type status is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
	signal ram1_now_s: status := s0;
	signal ram2_now_s: status := s0;
	
	signal flash_now_s: status := s0;	
	signal flash_complete : std_logic := '0';
	signal pro_addr : std_logic_vector(15 downto 0) := "0000000000000000";
	signal mem1_stall_o : std_logic := '0';
	signal mem2_stall_o : std_logic := '0';
	signal t1 : std_logic_vector(15 downto 0):= x"0000";
	signal t2 : std_logic_vector(15 downto 0):= x"0000";
begin		
	process(clk,t1,t2,rst,mem2_stall_o,mem1_stall_o)
	begin						
		if rst = '0' then
				MEMData_o <= x"0000";			
		elsif	((MEMAddr_i(15 downto 0) <= x"7FFF" and MEMAddr_i(15 downto 0) >= x"4000") ) and MemRead_i = '1' then
						MEMData_o		<= t2;
				
		else
						MEMData_o		<= t1;
		end if;
		mem_stall_o <= mem2_stall_o or mem1_stall_o;
	end process;
	--boot/ȡָ/дָ
	process(clk, rst)
	begin
		if rst = '0' then
			Ins_o <= (others => '0');
			ram2_en 	<= '0';	
			ram2_oe	<= '1';	
			ram2_we	<= '1';		
			ram2_now_s <= s0;
			ram2_data <= "ZZZZZZZZZZZZZZZZ";
			t2 <= x"0000";
			mem2_stall_o <= '0';		
		elsif clk'event and clk = '1' then
			if flash_complete = '1' then
				--boot ���
				case ram2_now_s is
					when s0 =>
						if stall_i = '0' then
							--׼��״̬��
							ram2_en 	<= '0';
							ram2_oe <= '0';
							ram2_we <= '1';
							--׼������ַ������
							ram2_data <= "ZZZZZZZZZZZZZZZZ";
							ram2_addr <= InsAddr_i;	
						end if;
						ram2_now_s <= s1;					
					when s1 =>
						if stall_i = '0' then
							ram2_addr <= InsAddr_i;	
							ins_o <= ram2_data;						
							ram2_oe <= '0';
							ram2_we <= '1';
							ram2_en 	<= '0';
						end if;
						--Ҫ��дָ������ͣ
						if ((MEMAddr_i(15 downto 0) <= x"7FFF" and MEMAddr_i(15 downto 0) >= x"4000") ) and (MemWrite_i = '1' or MemRead_i = '1') then
							mem2_stall_o <= '1';
							ram2_now_s <= s2;
						elsif (MemWrite_i = '1' or MemRead_i = '1') then
							mem2_stall_o <= '0';
							ram2_now_s <= s2;--s0
						else
							mem2_stall_o <= '0';
							ram2_now_s <= s0;
						end if;
					-- дram2�洢ָ��
					when s2 =>				
					--	ins_o <= ram2_data;	
						if ((MEMAddr_i(15 downto 0) <= x"7FFF" and MEMAddr_i(15 downto 0) >= x"4000") ) and MemWrite_i = '1' then
							--��ַ�ռ����û�������(0x4000~0x7FFFF)
							ram2_en <= '0';
							ram2_oe <= '1';
							ram2_data <= MEMData_i;
							ram2_addr <= MEMAddr_i;
							ram2_we <= '1';	
						elsif	((MEMAddr_i(15 downto 0) <= x"7FFF" and MEMAddr_i(15 downto 0) >= x"4000") ) and MemRead_i = '1' then
							--��ַ�ռ����û�������(0x4000~0x7FFFF)
							ram2_en <= '0';
							ram2_oe <= '0';
							ram2_data <= "ZZZZZZZZZZZZZZZZ";
							ram2_addr <= MEMAddr_i;
							ram2_we <= '1';							
						end if;				
						mem2_stall_o <= '1';						
						ram2_now_s <= s3;					
					when s3 =>
						if ((MEMAddr_i(15 downto 0) <= x"7FFF" and MEMAddr_i(15 downto 0) >= x"4000") ) and MemWrite_i = '1' then
							--��ַ�ռ����û�������(0x4000~0x7FFFF)
							--д��ָ�����״̬
							ram2_oe <= '1';
							ram2_we <= '0';
							ram2_data <= MEMData_i;
							ram2_addr <= MEMAddr_i;							
							ram2_en <= '0';
						elsif	((MEMAddr_i(15 downto 0) <= x"7FFF" and MEMAddr_i(15 downto 0) >= x"4000") ) and MemRead_i = '1' then
							--��ַ�ռ����û�������(0x4000~0x7FFFF)
							ram2_en <= '0';
							ram2_oe <= '0';
							t2		<= ram2_data;
							ram2_addr <= MEMAddr_i;
							ram2_we <= '1';
						end if;
						mem2_stall_o <= '0';						
						ram2_now_s <= s0;
					when s4 =>
						mem2_stall_o <= '0';						
						ram2_now_s <= s0;						
					when others =>
						ram2_oe <= '1';
						ram2_we <= '1';
						ram2_en <= '0';
						ram2_now_s <= s0;
						mem2_stall_o <= '0';
				end case;
			elsif flash_complete = '0' then
				--boot
				case flash_now_s is
					when s0 =>
						flash_CE <= '0';
						flash_WE <= '1';
						flash_OE <= '1';
						flash_byte <= '1';
						flash_vpen <= '1';
						flash_rp <= '1';
						flash_addr <= "000000" & pro_addr & '0';
						flash_data <= "ZZZZZZZZZZZZZZZZ";
						
						flash_now_s <= s1;
					when s1 =>
						ram2_en <= '0';
						ram2_oe <= '1';
						ram2_we <= '1';
						ram2_addr <= pro_addr;
						
						flash_now_s <= s2;
					when s2 =>
						flash_OE <= '0';
						
						flash_now_s <= s3;
					when s3 =>
						ram2_data <= flash_data;
						
						flash_now_s <= s4;
					when s4 =>
						flash_OE <= '1';
						
						flash_now_s <= s5;
					when s5 =>
						ram2_we <= '0';
						
						flash_now_s <= s6;
					when s6 =>
						ram2_we <= '1';
						
						flash_now_s <= s7;
					when s7 =>
						pro_addr <= pro_addr + '1';
						pro_addr_o <= pro_addr;
						flash_now_s <= s0;
					when others =>
				end case;
				if pro_addr > x"0220" then
						flash_complete <= '1';
						flash_complete_o <= '1';
				else 
					flash_complete <= '0';
					flash_complete_o <= '0';
				end if;				
			end if;
		end if;
	end process;
	
	
	
	--ram1 ���ݺʹ��ڵĶ�д
	process(clk, rst)
	begin
		if rst = '0' then
			ram1_en <= '0';
			ram1_oe <= '1';
			ram1_we <= '1';
			ram1_data <= "ZZZZZZZZZZZZZZZZ";
			rdn <= '1';
			wrn <= '1';			
			t1 <= x"0000";
			ram1_now_s <= s0;
			mem1_stall_o <= '0';
		elsif clk'event and clk = '1' then 
			--lw
			if flash_complete = '1' then
				case ram1_now_s is
					when s0 =>
						--s0�ȴ����ȴ���ַ����
						ram1_en <= '0';
						ram1_oe <= '1';
						ram1_we <= '1';
						rdn <= '1';
						wrn <= '1';						
						ram1_now_s <= s1;
					when s1 =>
						--�ڴ��ַ������ϣ�����׼���ź�
						if MemRead_i = '1' then
							--��ȡ����
							if (MEMAddr_i(15 downto 0) = x"BF00" or MEMAddr_i(15 downto 0) = x"BF02") then 					
								-- ����������(lw bf00 r)
								ram1_en <= '1';
								ram1_oe <= '1';
								ram1_we <= '1';
								rdn <= '1';
								wrn <= '1';
								ram1_data(7 downto 0) <= "ZZZZZZZZ";
							elsif (MEMAddr_i(15 downto 0) = x"BF01" or MEMAddr_i(15 downto 0) = x"BF03") then
								-- �鿴���ڿɶ���д״̬(lw bf01 r)
								wrn <= '1';
								rdn <= '1';
								ram1_en <= '1';
								ram1_we <= '1';
								ram1_oe <= '1';
								t1(0) <= tbre and tsre;
								t1(15 downto 5) <= "00000000000";
								t1(1) <= data_ready;
								t1(2) <= tsre;
								t1(4 downto 3) <= "00";
							elsif ((MEMAddr_i(15 downto 0) <= x"FFFF" and MEMAddr_i(15 downto 0) >= x"BF04") or (MEMAddr_i(15 downto 0)>= x"8000" and MEMAddr_i(15 downto 0) <= x"BEFF")) then
								-- ���ڴ�����
								ram1_en <= '0';
								ram1_oe <= '0';
								ram1_we <= '1';								
								ram1_data <= "ZZZZZZZZZZZZZZZZ";
								ram1_addr <= MEMAddr_i;
							end if;	
						  	mem1_stall_o <= '1';
							ram1_now_s <= s2;
						elsif MemWrite_i = '1' then
							--д����(sw bf00 r)
							if (MEMAddr_i(15 downto 0) = x"BF00" or MEMAddr_i(15 downto 0) = x"BF02" ) then
								--д���ݵ�����								
								-- �ر��ڴ�����ʹ��
								wrn <= '1';
								rdn <= '1';
								ram1_en <= '1';
								ram1_we <= '1';
								ram1_oe <= '1';																
							elsif ((MEMAddr_i(15 downto 0) <= x"FFFF" and MEMAddr_i(15 downto 0) >= x"BF04") or (MEMAddr_i(15 downto 0)>= x"8000" and MEMAddr_i(15 downto 0) <= x"BEFF")) then
								-- д���ݵ��ڴ�
								ram1_en <= '0';
								ram1_data <= MEMData_i;
								ram1_addr <= MEMAddr_i;
								ram1_we <= '0';
							end if;
							mem1_stall_o <= '1';
							ram1_now_s <= s2;
						else
							mem1_stall_o <= '0';
							ram1_now_s <= s0;	
						end if;
						
												
					when s2 =>
						if MemRead_i = '1' then
							--��ȡ����
							if (MEMAddr_i(15 downto 0) = x"BF00" or MEMAddr_i(15 downto 0) = x"BF02") then 					
								-- ����������(lw bf00 r)
								rdn <= '0';
								t1(7 downto 0) <= ram1_data(7 downto 0);			
							elsif (MEMAddr_i(15 downto 0) = x"BF01" or MEMAddr_i(15 downto 0) = x"BF03") then
								-- �鿴���ڿɶ���д״̬(lw bf01 r)
								wrn <= '1';
								rdn <= '1';
								ram1_en <= '1';
								ram1_we <= '1';
								ram1_oe <= '1';
								t1(0) <= tbre and tsre;
								t1(15 downto 5) <= "00000000000";
								t1(1) <= data_ready;
								t1(2) <= tsre;
								t1(4 downto 3) <= "00";
							elsif ((MEMAddr_i(15 downto 0) <= x"FFFF" and MEMAddr_i(15 downto 0) >= x"BF04") or (MEMAddr_i(15 downto 0)>= x"8000" and MEMAddr_i(15 downto 0) <= x"BEFF")) then
								-- ���ڴ�����
								t1 <= ram1_data;
								ram1_oe <= '1';
								ram1_we <= '1';
								ram1_en <= '0';
								rdn <= '1';
								wrn <= '1';
							end if;				
						elsif MemWrite_i = '1' then
							--д����(sw bf00 r)
							if (MEMAddr_i(15 downto 0) = x"BF00" or MEMAddr_i(15 downto 0) = x"BF02" ) then
								--д���ݵ�����								
								wrn <= '0';
								ram1_data(7 downto 0) <= MEMData_i(7 downto 0);									
							elsif ((MEMAddr_i(15 downto 0) <= x"FFFF" and MEMAddr_i(15 downto 0) >= x"BF04") or (MEMAddr_i(15 downto 0)>= x"8000" and MEMAddr_i(15 downto 0) <= x"BEFF")) then
								-- д���ݵ��ڴ�
								ram1_en <= '0';
								ram1_we <= '1';
							end if;
						end if;
						mem1_stall_o <= '1';
						ram1_now_s <= s3;		
					when s3 =>
						if MemRead_i = '1' then
							--��ȡ����
							if (MEMAddr_i(15 downto 0) = x"BF00" or MEMAddr_i(15 downto 0) = x"BF02") then 					
								t1(7 downto 0) <= ram1_data(7 downto 0);	
								t1(15 downto 8) <= "00000000";								
							elsif (MEMAddr_i(15 downto 0) = x"BF01" or MEMAddr_i(15 downto 0) = x"BF03") then
								-- �鿴���ڿɶ���д״̬(lw bf01 r)
								t1(0) <= tbre and tsre;
								t1(15 downto 5) <= "00000000000";
								t1(1) <= data_ready;
								t1(2) <= tsre;
								t1(4 downto 3) <= "00";
							elsif ((MEMAddr_i(15 downto 0) <= x"FFFF" and MEMAddr_i(15 downto 0) >= x"BF04") or (MEMAddr_i(15 downto 0)>= x"8000" and MEMAddr_i(15 downto 0) <= x"BEFF")) then
								-- ���ڴ�����
								t1 <= ram1_data;
							end if;				
						end if;
						mem1_stall_o <= '0';
						ram1_now_s <= s0;
						--�ָ�����״̬
					when others =>
						ram1_oe <= '1';
						ram1_we <= '1';
						ram1_en <= '0';
						rdn <= '1';
						wrn <= '1';
						ram1_now_s <= s0;	
						mem1_stall_o <= '0';
					end case;
				end if;
		end if;
	end process;
end Behavioral;

