----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:30:51 11/13/2016 
-- Design Name: 
-- Module Name:    MIPS - Behavioral 
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
entity MIPS is
		port(
			-- clk, rst, debug output
			clk_h  : in std_logic;
			clk_50m  : in std_logic;
			clk_11m  : in std_logic;
			rst      : in std_logic;
			sw      : in std_logic_vector(15 downto 0);
			led      : out std_logic_vector(15 downto 0) := "0101010101010101";
			digit1 : out std_logic_vector(6 downto 0) := "1111110";
			digit2 : out std_logic_vector(6 downto 0) := "1111110";			
			
			--串口管脚
			tbre			: in std_logic;
			tsre			: in std_logic;
			rdn 			: inout std_logic;
			wrn				: inout std_logic;
			data_ready		: in std_logic;
			--ram1管脚
			ram1_en 		: out std_logic;
			ram1_oe			: out std_logic;
			ram1_we			: out std_logic;
			ram1_addr		: out std_logic_vector(15 downto 0);
			ram1_data		: inout std_logic_vector(15 downto 0);
			--ram2管脚
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
			flash_data : inout std_logic_vector(15 downto 0)
			);
end MIPS;

architecture Behavioral of MIPS is
	subtype array16 is std_logic_vector(15 downto 0);
	subtype int4 is integer range 0 to 3; -- int for clock frequency division
	subtype int8 is integer range 0 to 7;	
	shared variable zero16 : array16 := "0000000000000000";
	---------- INT ----------
	signal int_r0      : std_logic_vector(15 downto 0) := zero16;
	signal int_r1      : std_logic_vector(15 downto 0) := zero16;
	signal int_recover : std_logic := '0';
	signal int_signal  : std_logic_vector(15 downto 0) := zero16;
	signal int_pc      : std_logic_vector(15 downto 0) := zero16;	
	--clk
	signal clk : std_logic := '0';
	--IF
	--pass signal
	signal pc_branch_flag_i : std_logic := '0';
	signal pc_branch_target_addr_i:std_logic_vector(15 downto 0) := "0000000000000000";
	signal pc_int_pc_i  : std_logic_vector(15 downto 0) := "0000000000000000";
	signal pc_int_module_i : std_logic := '0';
	signal if_ins_o : std_logic_vector(15 downto 0) := zero16;
	signal if_pc_o : std_logic_vector(15 downto 0) := zero16;	

	---------- IF/ID ----------
	-- general signal	
	signal if_id_stall_i : std_logic := '0'; 
	signal if_id_flush_i : std_logic := '0';
	signal if_id_int_module_i : std_logic := '0'; 
	signal if_id_int_module_o : std_logic := '0';
	
	signal id_ins_o : std_logic_vector(15 downto 0) := zero16;
	signal id_pc_o : std_logic_vector(15 downto 0) := zero16;	

	---------- ID ----------	
	signal id_A_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_B_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_S_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_ForwardData_ALU1_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_ForwardData_MEM1_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_ForwardData_ALU2_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_ForwardData_MEM2_i		:std_logic_vector(15 downto 0) := zero16;
	signal id_ForwardA_i		:std_logic_vector(2 downto 0) := "000";
	signal id_ForwardS_i		:std_logic_vector(2 downto 0) := "000";
	
	-- control signal in ID
	signal id_branch_o     : std_logic := '0';
	signal id_btype_o     : std_logic_vector(1 downto 0) := "00";
	signal id_jump_o       : std_logic := '0';
	
	--imm
	signal id_imm_src_o    : std_logic_vector(1 downto 0) := "00";
	signal id_imm_ext_o    : std_logic := '0';
	signal id_imm_raw_o    : std_logic_vector(10 downto 0) := "00000000000";
	
	
	-- control signal pass ID
	--reg
	signal id_reg_dst_o      : std_logic_vector(1 downto 0) := "00";
	signal id_reg_write_o    : std_logic := '0';
	signal id_reg_data_o     : std_logic := '0';
	--spreg
	signal id_sp_reg_read_o   : std_logic_vector(1 downto 0) := "00";
	signal id_sp_reg_write_o : std_logic_vector(1 downto 0) := "00";
	signal id_write_sp_reg_o : std_logic := '0';
	--alu
	signal id_alu_src_A_o    : std_logic_vector(1 downto 0) := "00";
	signal id_alu_src_B_o    : std_logic := '0';
	signal id_alu_op_o       : std_logic_vector(3 downto 0) := "0000";
	--mem
	signal id_mem_read_o     : std_logic := '0';
	signal id_mem_write_o    : std_logic := '0';
	signal id_mem_data_o     : std_logic := '0';
	--int
	signal id_int_module_o   : std_logic := '0';

	--data
	signal id_A_o   : std_logic_vector(15 downto 0) := zero16;
	signal id_B_o   : std_logic_vector(15 downto 0) := zero16;
	signal id_S_o   : std_logic_vector(15 downto 0) := zero16;
	signal id_imm_o : std_logic_vector(15 downto 0) := zero16;
	signal id_rx_o   : std_logic_vector(2 downto 0) := "000";
	signal id_ry_o   : std_logic_vector(2 downto 0) := "000";
	signal id_rz_o   : std_logic_vector(2 downto 0) := "000";

	---------- ID/EXE ----------
	-- control signal
	--reg
	signal id_exe_reg_dst_o      : std_logic_vector(1 downto 0) := "00";
	signal id_exe_reg_write_o    : std_logic := '0';
	signal id_exe_reg_data_o     : std_logic := '0';
	--spreg
	signal id_exe_sp_reg_read_o   : std_logic_vector(1 downto 0) := "00";
	signal id_exe_sp_reg_write_o : std_logic_vector(1 downto 0) := "00";
	signal id_exe_write_sp_reg_o : std_logic := '0';
	--alu
	signal id_exe_alu_src_A_o    : std_logic_vector(1 downto 0) := "00";
	signal id_exe_alu_src_B_o    : std_logic := '0';
	signal id_exe_alu_op_o       : std_logic_vector(3 downto 0) := "0000";
	--mem
	signal id_exe_mem_read_o     : std_logic := '0';
	signal id_exe_mem_write_o    : std_logic := '0';
	signal id_exe_mem_data_o     : std_logic := '0';
	--INT
	
	signal id_exe_int_module_o   : std_logic := '0';

	-- general signal
	signal id_exe_pc_o  : std_logic_vector(15 downto 0) := zero16;
	signal id_exe_A_o   : std_logic_vector(15 downto 0) := zero16;
	signal id_exe_B_o   : std_logic_vector(15 downto 0) := zero16;
	signal id_exe_S_o   : std_logic_vector(15 downto 0) := zero16;
	signal id_exe_rx_o  : std_logic_vector(2 downto 0)  := "000";
	signal id_exe_ry_o  : std_logic_vector(2 downto 0)  := "000";
	signal id_exe_rz_o  : std_logic_vector(2 downto 0)  := "000";
	signal id_exe_imm_o : std_logic_vector(15 downto 0) := zero16;
	
	---------- EXE ----------
	-- general signal in EXE
	signal exe_ForwardA_i         :  std_logic_vector(1 downto 0);
	signal exe_ForwardB_i         :  std_logic_vector(1 downto 0);
	signal exe_ForwardMemDataA_i         :  std_logic_vector(1 downto 0);
	signal exe_ForwardMemDataB_i         :  std_logic_vector(1 downto 0);
	--上条指令的运算结果
	signal exe_ForwardData1_alu_i: std_logic_vector(15 downto 0);
	--上条指令的内存结果
	signal exe_ForwardData1_mem_i: std_logic_vector(15 downto 0);
	--上上条指令的运算结果
	signal exe_ForwardData2_i: std_logic_vector(15 downto 0);
	signal exe_alu_out_o : std_logic_vector(15 downto 0) := zero16;
	signal exe_reg_dst_o      : std_logic_vector(2 downto 0) := "000";
	signal exe_mem_data_o  :std_logic_vector(15 downto 0) := zero16;
	
	---------- EXE/MEM ----------
	-- control signal
	--mem
	signal exe_mem_mem_read_o     : std_logic := '0';
	signal exe_mem_mem_write_o    : std_logic := '0';
	signal exe_mem_mem_data_o      : std_logic_vector(15 downto 0) := zero16;
	--alu
	signal exe_mem_alu_output_o : std_logic_vector(15 downto 0) := zero16;
	--reg
	signal exe_mem_reg_write_o   : std_logic := '0';
	signal exe_mem_reg_data_o     : std_logic := '0';
	signal exe_mem_reg_dst_o     : std_logic_vector(2 downto 0)  := "000";
	--spreg
	signal exe_mem_write_sp_reg_o : std_logic := '0';
	signal exe_mem_sp_reg_write_o : std_logic_vector(1 downto 0) := "00";
	--INT
	signal exe_mem_int_module_o   : std_logic := '0';

	---------- MEM ----------	
	signal mem_data_o : std_logic_vector(15 downto 0) := zero16;
	signal mem_stall_i : std_logic := '0';
	
	---------- MEM/WB ----------
	-- control signal
	--reg
	signal mem_wb_reg_write_o    : std_logic := '0';
	signal mem_wb_reg_data_o     : std_logic := '0';
	signal mem_wb_reg_dst_o  : std_logic_vector(2 downto 0)  := "000";
	--spreg
	signal mem_wb_sp_reg_write_o : std_logic_vector(1 downto 0) := "00";
	signal mem_wb_write_sp_reg_o : std_logic := '0';
	--INT
	signal mem_wb_int_module_o   : std_logic := '0';
	-- general siganl
	signal mem_wb_alu_output_o : std_logic_vector(15 downto 0) := zero16;
	signal mem_wb_mem_data_o : std_logic_vector(15 downto 0) := zero16;
	signal mem_wb_wb_data_o  : std_logic_vector(15 downto 0) := zero16;

	---------- Forward76 ----------
	
	
	---------- FLASH ----------
	signal flash_complete : std_logic := '0';
	signal pro_addr : std_logic_vector(15 downto 0) := "0000000000000000";
	
	
	--ImmExtend
	component ImmExtend
		Port (
			ImmSrc    : in  std_logic_vector(1 downto 0) := "00";
			ImmExt    : in  std_logic := '0';
			ImmInput  : in  std_logic_vector(10 downto 0) := "00000000000";
			ImmOutput : out  std_logic_vector(15 downto 0) := "0000000000000000"
			);
	end component;
		
	--BranchControl
	component BranchControl
		Port (
				--if/id的指令地址
				pc_i: in STD_LOGIC_VECTOR (15 downto 0);
				--当前指令是否是B型或者j型指令
				Branch: in std_logic;
				-- 哪一条B型指令		
				BType : in  STD_LOGIC_VECTOR (1 downto 0);
				Rx : in  STD_LOGIC_VECTOR (15 downto 0);
				T : in  STD_LOGIC_VECTOR (15 downto 0);
				imm : in  STD_LOGIC_VECTOR (15 downto 0);
				-- 跳转控制 
				Jump: in std_logic;
				-- 是否跳转
				branch_flag_o : out  STD_LOGIC;
				-- 跳转的目标地址
				branch_target_addr_o: out std_logic_vector(15 downto 0)
			);
	end component;
		
	--ForwardUnit
	component ForwardUnit
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
	end component;
	
	
	--Registers
	component Registers
	Port (
			clk        : in  STD_LOGIC;
			rst		  : in STD_LOGIC;
			--是否要写回通用寄存器
			WriteReg   : in  STD_LOGIC;
			--要读取的通用寄存器地址
			Rx         : in  STD_LOGIC_VECTOR (2 downto 0);
			Ry         : in  STD_LOGIC_VECTOR (2 downto 0);
			--要写回的通用寄存器的地址
			RegWrite   : in  STD_LOGIC_VECTOR (2 downto 0);
			--要写回通用寄存器的数据
			WriteData  : in  STD_LOGIC_VECTOR (15 downto 0);
			
			--要写入的特殊寄存器的地址
			SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
			--要读取的特殊寄存器的地址
			SpRegRead_i    : in  STD_LOGIC_VECTOR (1 downto 0);
			--是否要写回特殊寄存器
			WriteSpReg_i  : in  STD_LOGIC;	
	
			--中断恢复信号
			int_recover_i : in STD_LOGIC;
			--中断保留现场信号
			mem_wb_int_module_i : in STD_LOGIC;
			--保留数据
			int_signal_i  : in  STD_LOGIC_VECTOR (15 downto 0);
			int_buffer_pc_i  : in  STD_LOGIC_VECTOR (15 downto 0);
			
			-- 寄存器要传送给ID/EXE的A、B、S
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
	end component;
	
	--MEM
	component MEM
	port(		
		rst : in std_logic;
		clk 			: in std_logic;	
		stall_i			: in std_logic;		
		-- 内存读写控制信号
		MemWrite_i		: in std_logic;
		MemRead_i		: in std_logic;
		-- 要写入数据内存的值
		MEMData_i	: in	std_logic_vector(15 downto 0);					
		-- 要写入读入的数据内存的地址
		MEMAddr_i		: in std_logic_vector(15 downto 0);
		-- 从数据内存读出的值
		MEMData_o	: out	std_logic_vector(15 downto 0);		
	
				
		-- 要从指令内存读取的地址
		InsAddr_i 		: in std_logic_vector(15 downto 0);
		-- 读取的指令
		Ins_o		: out std_logic_vector(15 downto 0);
		
		
		--串口管脚
		tbre			: in std_logic;
		tsre			: in std_logic;
		rdn 			: inout std_logic;
		wrn				: inout std_logic;
		data_ready		: in std_logic	;
		--ram1管脚
		ram1_en 		: out std_logic;
		ram1_oe			: out std_logic;
		ram1_we			: out std_logic;
		ram1_addr		: out std_logic_vector(15 downto 0);
		ram1_data		: inout std_logic_vector(15 downto 0);
		--ram2管脚
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
	end component;	
	
	
	--PC
	component PC
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号
		flush		: in std_logic;
		--	pc保持信号
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash 完成
		flash_complete : in std_logic;		
		--	分支跳转信号
		branch_flag_i	: in std_logic;
		-- jump
		jump_i	: in std_logic;
		-- 执行分支或跳转时的目标地址
		branch_target_addr_i: in std_logic_vector(15 downto 0) := "0000000000000000";	
		
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		int_recover_o : out STD_LOGIC;
		int_signal_o  : out std_logic_vector(15 downto 0) := "0000000000000000";
		-- 中断时缓存指令
		int_pc_o  : out std_logic_vector(15 downto 0) := "0000000000000000";	
		
		-- 取值阶段的指令地址		
		if_pc  : out std_logic_vector(15 downto 0) := "0000000000000000";
		-- if_id段输出指令
		if_id_ins_i : in std_logic_vector(15 downto 0) := "0000000000000000"
		);
	end component;
	

	--IF_ID
	component IF_ID
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号,插入nop
		flush		: in std_logic;
		--	取值阶段暂停（保持一个周期）
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash boot完毕
		flash_complete : in std_logic;
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC;
		
		if_pc  : in std_logic_vector(15 downto 0) := "0000000000000000";
		if_inst  : in std_logic_vector(15 downto 0) := "0000000000000000";

		id_pc :  out std_logic_vector(15 downto 0) := "0000000000000000";
		id_inst : out std_logic_vector(15 downto 0) := "0000000000000000"
		);
	end component;	
	
	--ID
	component ID
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
	end component;		
	
	--ID_EXE
	component ID_EX
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号
		flush		: in std_logic;
		--	取值阶段暂停
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash 完成
		flash_complete : in std_logic;
		
		--ID段传过来EXE阶段会用到的寄存器操作数A、B值和特殊寄存器值
		A_i: in std_logic_vector(15 downto 0);
		B_i: in std_logic_vector(15 downto 0);
		S_i: in std_logic_vector(15 downto 0);
		--EXE阶段会用到的寄存器操作数A、B值和特殊寄存器值
		A_o: out std_logic_vector(15 downto 0);
		B_o: out std_logic_vector(15 downto 0);
		S_o: out std_logic_vector(15 downto 0);
		
		--ID段传过来EXE阶段会用到的rx,ry,rz寄存器地址
		rx_i: in std_logic_vector(2 downto 0);
		ry_i: in std_logic_vector(2 downto 0);
		rz_i: in std_logic_vector(2 downto 0);
		--EXE阶段会用到的rx,ry,rz寄存器地址
		rx_o: out std_logic_vector(2 downto 0);
		ry_o: out std_logic_vector(2 downto 0);
		rz_o: out std_logic_vector(2 downto 0);
		
		--ID段传过来EXE阶段会用到的扩展后的立即数
		imm_i: in std_logic_vector(15 downto 0);
		--EXE阶段会用到的扩展后的立即数
		imm_o: out std_logic_vector(15 downto 0);
		
		
		--ID段传过来的控制信号
		
		
		
		--ALU的第一个操作数选择信号
		ALUSrcA_i     : in  STD_LOGIC_VECTOR (1 downto 0);
		ALUSrcA_o     : out  STD_LOGIC_VECTOR (1 downto 0);
		--ALU的第二个操作数选择信号
		ALUSrcB_i     : in  STD_LOGIC;	
		ALUSrcB_o    : out  STD_LOGIC;		
		--ALU进行的运算类型
		ALUOp_i       : in  STD_LOGIC_VECTOR (3 downto 0);
		ALUOp_o       : out  STD_LOGIC_VECTOR (3 downto 0);
		--要被写回的通用寄存器的地址选择信号(选择rx/ry/rz)		
		RegDst_i		: in std_logic_vector(1 downto 0);
		RegDst_o		: out std_logic_vector(1 downto 0);
		--该指令是否要写回通用寄存器
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--要被写回的寄存器的数据是ALU结果还是MEM结果
		RegData_i     : in  STD_LOGIC;	
		RegData_o     : out  STD_LOGIC;	

		--要写入的特殊寄存器的地址
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--要访问的特殊寄存器的地址
		SpRegRead_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegRead_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--是否要写回特殊寄存器
		WriteSpReg_i  : in  STD_LOGIC;	
		WriteSpReg_o  : out  STD_LOGIC;	
		--该指令访存时是否要读取内存
		MemRead_i     : in  STD_LOGIC;
		MemRead_o     : out  STD_LOGIC;
		--访存时是否要写入内存
		MemWrite_i    : in  STD_LOGIC;
		MemWrite_o    : out  STD_LOGIC;
		--要写入内存的数据选择自哪个寄存器
		MemData_i     : in  STD_LOGIC;
		MemData_o     : out  STD_LOGIC;
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC;
		
		--pc
		pc_i:in std_logic_vector(15 downto 0);
		pc_o:out std_logic_vector(15 downto 0)
		
	);
	end component;		
	
	--EXE
	component EX
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
	end component;		
	
	-- EXE_MEM
	component EX_MEM
		port(
			-- clk, rst
			clk	   : in std_logic;
			rst      : in std_logic;		
			-- 流水线清除信号
			flush		: in std_logic;
			--	取值阶段暂停
			stall		: in std_logic;
			mem_stall_i : in std_logic;
			-- flash 完成
			flash_complete : in std_logic;
			
			-- 通用寄存器的写回信号
			--要被写回的通用寄存器的地址		
			RegDst_i		: in std_logic_vector(2 downto 0);
			RegDst_o		: out std_logic_vector(2 downto 0);
			--该指令是否要写回通用寄存器
			RegWrite_i    : in  STD_LOGIC;
			RegWrite_o    : out  STD_LOGIC;
			--要被写回的寄存器的数据是ALU结果还是MEM结果
			RegData_i     : in  STD_LOGIC;				
			RegData_o     : out  STD_LOGIC;
			
			
			-- 特殊寄存器的写回信号
			--要写入的特殊寄存器的地址
			SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
			SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
			--是否要写回特殊寄存器
			WriteSpReg_i  : in  STD_LOGIC;
			WriteSpReg_o  : out  STD_LOGIC;	
			
			
			--该指令访存时是否要读取内存
			MemRead_i     : in  STD_LOGIC;
			MemRead_o     : out  STD_LOGIC;
			--访存时是否要写入内存
			MemWrite_i    : in  STD_LOGIC;		
			MemWrite_o    : out  STD_LOGIC;
			
			
			-- EXE段传来的ALU计算结果
			ALUOut_i	: in	std_logic_vector(15 downto 0);
			ALUOut_o	: out	std_logic_vector(15 downto 0);
			-- EXE段传来的要写回内存的值
			MEMData_i	: in	std_logic_vector(15 downto 0);					
			MEMData_o	: out	std_logic_vector(15 downto 0);

			--是否在中断
			IntModule_i   : in  STD_LOGIC;
			IntModule_o   : out  STD_LOGIC
		);
	end component;	

	--MEM_WB
	component MEM_WB
	port(
		-- clk, rst
		clk	   : in std_logic;
		rst      : in std_logic;		
		-- 流水线清除信号
		flush		: in std_logic;
		--	取值阶段暂停
		stall		: in std_logic;
		mem_stall_i : in std_logic;
		-- flash 完成
		flash_complete : in std_logic;
	
		-- MEM段传来的ALU计算结果数据
		ALUOut_i	: in	std_logic_vector(15 downto 0);
		ALUOut_o	: out	std_logic_vector(15 downto 0);
		-- MEM段传来的数据内存读取数据
		MEMData_i	: in	std_logic_vector(15 downto 0);		
		MEMData_o	: out	std_logic_vector(15 downto 0);
		
		
		
		-- 通用寄存器的写回
		--要被写回的通用寄存器的地址		
		RegDst_i		: in std_logic_vector(2 downto 0);
		RegDst_o		: out std_logic_vector(2 downto 0);
		--该指令是否要写回通用寄存器
		RegWrite_i    : in  STD_LOGIC;
		RegWrite_o    : out  STD_LOGIC;
		--要被写回的寄存器的数据是ALU结果还是MEM结果
		RegData_i     : in  STD_LOGIC;			
		RegData_o     : out  STD_LOGIC;
		
		
		-- 特殊寄存器的写回
		--要写入的特殊寄存器的地址
		SpRegWrite_i  : in  STD_LOGIC_VECTOR (1 downto 0);
		SpRegWrite_o  : out  STD_LOGIC_VECTOR (1 downto 0);
		--是否要写回特殊寄存器
		WriteSpReg_i  : in  STD_LOGIC;
		WriteSpReg_o  : out  STD_LOGIC;		
		
		--是否在中断
		IntModule_i   : in  STD_LOGIC;
		IntModule_o   : out  STD_LOGIC;		
		
		-- 要写回的数据
		WB_Data :out	std_logic_vector(15 downto 0)
	);
	end component;			
	signal s : std_logic := '0';
	signal r0_o : std_logic_vector(15 downto 0) := zero16;
	signal r1_o : std_logic_vector(15 downto 0) := zero16;
	signal r2_o : std_logic_vector(15 downto 0) := zero16;
	signal r3_o : std_logic_vector(15 downto 0) := zero16;
	signal r4_o : std_logic_vector(15 downto 0) := zero16;
	signal r5_o : std_logic_vector(15 downto 0) := zero16;
	signal r6_o : std_logic_vector(15 downto 0) := zero16;
	signal r7_o : std_logic_vector(15 downto 0) := zero16;
	signal T_o : std_logic_vector(15 downto 0) := zero16;
	signal IH_o : std_logic_vector(15 downto 0) := zero16;
	signal SP_o : std_logic_vector(15 downto 0) := zero16;
begin

	digit1 <= pro_addr(6 downto 0);
	digit2 <= if_pc_o(6 downto 0);

	
	-------------------- CLOCK --------------------
	process(sw)
	begin	
		case sw(9 downto 8) is
			when "00" =>
				clk <= clk_h;
			when "01" =>
				clk <= clk_50m;
			when others =>
				clk <= clk_h;
		end case;
	end process;
	
	process(clk,sw)
	begin
		case sw is
		when "0000000000000000" =>
			led <= r0_o;
		when "0000000000000001" =>
			led <= r1_o;
		when "0000000000000010" =>
			led <= r2_o;
		when "0000000000000011" =>
			led <= r3_o;
		when "0000000000000100" =>
			led <= r4_o;
		when "0000000000000101" =>
			led <= r5_o;
		when "0000000000000110" =>
			led <= r6_o;
		when "0000000000000111" =>
			led <= r7_o;
		when "0000000000001000" =>
			led <= T_o;
		when "0000000000001001" =>
			led <= IH_o;
		when "0000000000001010" =>
			led <= SP_o;
		when "0000000000001011" =>
			led <= mem_wb_wb_data_o;
		when "0000000000001100" =>
			led <= id_ins_o;
		when "0000000000001101" =>
			led <= if_ins_o;
		when "0000000000001110" =>
			led <= id_pc_o;
		when "0000000000001111" =>
			led <= if_pc_o;
		when "0000000000011111" =>
			led <= exe_mem_alu_output_o;
		when "0000000000111111" =>
			led <= mem_wb_alu_output_o;	
		when "0000000001111111" =>
			led <= id_exe_pc_o;	
		when "1000000000000000" =>
			led <= pc_branch_target_addr_i;	
		when "1100000000000000" =>
			led <= pc_branch_flag_i & id_branch_o & id_btype_o & id_A_o(11 downto 0) ;				
		when others =>
			led <= flash_complete & if_pc_o(6 downto 0) & if_ins_o(15 downto 9) & clk;
		end case;
	end process;
	u_imm_extend : ImmExtend 
		port map(
			ImmSrc    => id_imm_src_o,
			ImmExt    => id_imm_ext_o,
			ImmInput  => id_imm_raw_o(10 downto 0),
			ImmOutput => id_imm_o
		);
	
	u_registers: Registers 
		port map(
				clk        => clk,
				rst		   => rst,
				WriteReg   => mem_wb_reg_write_o,
				Rx         => id_rx_o,
				Ry         => id_ry_o,
				RegWrite   => mem_wb_reg_dst_o,
				WriteData  => mem_wb_wb_data_o,
				SpRegWrite_i  => mem_wb_sp_reg_write_o,
				SpRegRead_i   => id_sp_reg_read_o,
				WriteSpReg_i  => mem_wb_write_sp_reg_o,
				
				--中断恢复信号
				int_recover_i => int_recover,
				--中断保留现场信号
				mem_wb_int_module_i => mem_wb_int_module_o,
				--保留数据
				int_signal_i  =>		int_signal,
				int_buffer_pc_i  =>	int_pc,
	
				A_o          => id_A_i,
				B_o          => id_B_i,
				r0_o => r0_o,
				r1_o => r1_o,
				r2_o => r2_o,
				r3_o => r3_o,
				r4_o => r4_o,
				r5_o => r5_o,
				r6_o => r6_o,
				r7_o => r7_o,
				T_o => T_o,
				IH_o => IH_o,
				SP_o => SP_o,
				S_o          => id_S_i
		);
	
	u_mem: MEM 
		port map(		
			rst => rst,
			clk => clk,
			stall_i	=> if_id_stall_i,
			MemWrite_i => exe_mem_mem_write_o,
			MemRead_i  => exe_mem_mem_read_o,
			MEMData_i  => exe_mem_mem_data_o,					
			MEMAddr_i  => exe_mem_alu_output_o,
			MEMData_o => mem_data_o,			
					
			-- 要从指令内存读取的地址
			InsAddr_i 		=>  if_pc_o, 
			-- 读取的指令
			Ins_o		=> if_ins_o, -- out std_logic_vector(15 downto 0);
			
			
			--串口管脚
			tbre			=> tbre, -- in std_logic;
			tsre			=> tsre, --: in std_logic;
			rdn 			=> rdn, -- inout std_logic;
			wrn				=> wrn, -- inout std_logic;
			data_ready		=> data_ready, --in std_logic	
			--ram1管脚
			ram1_en 		=> ram1_en,-- out std_logic;
			ram1_oe			=> ram1_oe,--: out std_logic;
			ram1_we			=> ram1_we,--: out std_logic;
			ram1_addr		=> ram1_addr,--: out std_logic_vector(15 downto 0);
			ram1_data		=> ram1_data, --: inout std_logic_vector(15 downto 0);
			--ram2管脚
			ram2_en			=> ram2_en,--: out std_logic;
			ram2_oe			=> ram2_oe,--: out std_logic;
			ram2_we			=> ram2_we,--: out std_logic;
			ram2_addr		=> ram2_addr,-- out std_logic_vector(15 downto 0);
			ram2_data		=>ram2_data, -- inout std_logic_vector(15 downto 0);
			
			--flash
			flash_byte => flash_byte,--: out std_logic := '1';
			flash_vpen => flash_vpen,-- out std_logic := '1';
			flash_CE   => flash_CE, -- out std_logic;
			flash_OE   => flash_OE, -- out std_logic;
			flash_WE   => flash_WE, -- out std_logic;
			flash_RP   => flash_RP, -- out std_logic := '1';
			flash_addr => flash_addr, -- out std_logic_vector(22 downto 0);
			flash_data => flash_data,-- inout std_logic_vector(15 downto 0);
			
			--flash complete
			flash_complete_o => flash_complete, -- out std_logic,
			pro_addr_o => pro_addr,
			mem_stall_o => mem_stall_i
		);
	
	u_forwardunit: ForwardUnit 
		port map(
			clk	   => clk,
			  
			  --id_exe段的信息
		    id_exe_rx    => id_exe_rx_o,--           : in  std_logic_vector(2 downto 0);
            id_exe_ry    => id_exe_ry_o,           --: in  std_logic_vector(2 downto 0);
		    id_exe_sp	 => id_exe_sp_reg_read_o, --				  : in  std_logic_vector(1 downto 0);
			  
			id_exe_ALUSrcA    => id_exe_alu_src_A_o, --      : in  std_logic_vector(1 downto 0);
			id_exe_ALUSrcB    => id_exe_alu_src_B_o,--      : in  std_logic;
				
			  --id段的信息(id段可能用到的前推)
			id_rx  => id_rx_o,--             : in  std_logic_vector(2 downto 0);
            id_ry   => id_ry_o,--            : in  std_logic_vector(2 downto 0);
			id_sp => id_sp_reg_read_o,--					 : in  std_logic_vector(1 downto 0);
			-- id段指令是jump或者branch
			id_jump	=> id_jump_o,	--		 : in std_logic;
			id_branch	=> id_branch_o,--			 : in std_logic;


			  --exe段指令要写回的特殊寄存器地址
			  exe_SpRegWrite	=> id_exe_sp_reg_write_o,--	  : in  std_logic_vector(1 downto 0);
			  --exe段指令是否写回特殊寄存器
			  exe_WriteSpReg	=> id_exe_write_sp_reg_o,--	  : in  std_logic;
			  --exe段指令要写回的普通寄存器的地址
			  exe_RegDst	 	=> exe_reg_dst_o, 
			  --exe段指令是否写回普通寄存器
			  exe_RegWrite		=> id_exe_reg_write_o, 	 
				exe_RegData   => id_exe_reg_data_o,
			
			  --exe_mem段指令要写回的特殊寄存器地址
			  exe_mem_SpRegWrite   => exe_mem_sp_reg_write_o,		--  : in  std_logic_vector(1 downto 0);
			  --exe_mem段指令是否写回特殊寄存器
			  exe_mem_WriteSpReg	=> exe_mem_write_sp_reg_o,--	  : in  std_logic;
			  --exe_mem段指令要写回的普通寄存器的地址
			  exe_mem_RegDst	 	=> exe_mem_reg_dst_o,--	  : in  std_logic_vector(1 downto 0);
			  --exe_mem段指令是否写回普通寄存器
			  exe_mem_RegWrite		=> exe_mem_reg_write_o, --  : in  std_logic;
			  --wb要写回的数据来自alu还是mem
			  exe_mem_RegData		=> exe_mem_reg_data_o,--	  : in  std_logic;			  

			  
			  --mem_wb段指令要写回的特殊寄存器地址
			  mem_wb_SpRegWrite		=> mem_wb_sp_reg_write_o, --  : in  std_logic_vector(1 downto 0);
			  --mem_wb段指令是否写回特殊寄存器
			  mem_wb_WriteSpReg		=> mem_wb_write_sp_reg_o,--  : in  std_logic;
			  --mem_wb段指令要写回的普通寄存器的地址
			  mem_wb_RegDst	 		=> mem_wb_reg_dst_o, --  : in  std_logic_vector(1 downto 0);
			  --mem_wb段指令是否写回普通寄存器
			  mem_wb_RegWrite		=> mem_wb_reg_write_o, --  	  : in  std_logic;
			  ForwardA_exe         => exe_ForwardA_i, --: out  std_logic_vector(1 downto 0);
			  ForwardB_exe         => exe_ForwardB_i, --: out  std_logic_vector(1 downto 0);
			--EXE段MEM_Data要用的数据前推控制信号
			ForwardMemDataA_exe     => exe_ForwardMemDataA_i,
			ForwardMemDataB_exe     =>  exe_ForwardMemDataB_i,
			--ID段要用的数据前推控制信号
			  ForwardA_id         => id_ForwardA_i, --: out  std_logic_vector(2 downto 0);
 			  ForwardS_id         => id_ForwardS_i,--: out  std_logic_vector(2 downto 0);
			
			--IF_ID指令是否保持一个周期
			  stall_if_id			 => if_id_stall_i -- : out std_logic
		);

	u_branchcontrol : BranchControl 
		port map( -- when id_cnt = 1
			--id的指令地址
			pc_i => id_pc_o, --: in STD_LOGIC_VECTOR (15 downto 0);
			--当前指令是否是B型或者j型指令
			Branch => id_branch_o, -- in std_logic;
			-- 哪一条B型指令		
			BType => id_btype_o, -- in  STD_LOGIC_VECTOR (1 downto 0);
			Rx  => id_A_o, --: in  STD_LOGIC_VECTOR (15 downto 0);
			T   => id_S_o, --: in  STD_LOGIC_VECTOR (15 downto 0);
			imm => id_imm_o,-- in  STD_LOGIC_VECTOR (15 downto 0);
			-- 跳转控制 
			Jump => id_jump_o, -- in std_logic;
			-- 是否跳转
			branch_flag_o => pc_branch_flag_i,--  out  STD_LOGIC;
			-- 跳转的目标地址
			branch_target_addr_o => pc_branch_target_addr_i -- out std_logic_vector(15 downto 0);
		);			
		
		
	u_pc : PC 
		port map( -- when id_cnt = 1
			-- clk, rst
			clk	   => clk,
			rst    => rst,
			flush  => pc_branch_flag_i, 
			stall	=> if_id_stall_i,
			mem_stall_i => mem_stall_i,
			flash_complete => flash_complete,
			branch_flag_i => pc_branch_flag_i,
			jump_i	=> id_jump_o,
			branch_target_addr_i => pc_branch_target_addr_i,
			
			IntModule_i   => id_int_module_o, 

			int_recover_o => int_recover,
			int_signal_o  => int_signal,
			
			
			int_pc_o  => int_pc,
			if_pc  => if_pc_o,
			if_id_ins_i => id_ins_o
		);	

	u_if_id : IF_ID 
		port map(
			clk	  => clk,
			rst   => rst,
			-- 流水线清除信号,插入nop
			flush	=> pc_branch_flag_i,
			--	取值阶段暂停（保持一个周期）
			stall	=> if_id_stall_i,
			mem_stall_i => mem_stall_i,
			flash_complete => flash_complete,
			
			IntModule_i   => id_int_module_o,
			IntModule_o   => if_id_int_module_o,
			
			if_pc  => if_pc_o,
			if_inst  => if_ins_o,
			id_pc 	=> id_pc_o,
			id_inst => id_ins_o
		);	
	
	u_id : ID 
		port map(
			clk	  => clk,
			rst   => rst,
			flush => pc_branch_flag_i,
			stall => if_id_stall_i,
			pc_i  => id_pc_o,
			inst_i  => id_ins_o,
			
			ImmSrc  => id_imm_src_o,
			ImmExt  => id_imm_ext_o,
			imm		=> id_imm_raw_o,
			rx => id_rx_o, 
			ry => id_ry_o,
			rz => id_rz_o,
			A_i => id_A_i,
			B_i => id_B_i,
			S_i => id_S_i, 
			--上条指令的运算结果（ALU直接输出）
			ForwardData_ALU1 => exe_alu_out_o,
			ForwardData_MEM1 => exe_alu_out_o,
			--上上条指令的运算结果（EXE/MEM的ALU）
			ForwardData_ALU2 => exe_mem_alu_output_o,
			ForwardData_MEM2 => mem_data_o,
			--数据前推控制信号
			ForwardA_i      => id_ForwardA_i,
			ForwardS_i      => id_ForwardS_i,
			A_o => id_A_o, 
			B_o => id_B_o,
			S_o => id_S_o,


			ALUSrcA_o   => id_alu_src_A_o,
			ALUSrcB_o   => id_alu_src_B_o,		
			ALUOp_o     => id_alu_op_o,

			MemRead_o   => id_mem_read_o,
			MemWrite_o  => id_mem_write_o,
			MemData_o   => id_mem_data_o, 
		
		
			RegDst_o	=> id_reg_dst_o,
			RegWrite_o  => id_reg_write_o, 
			RegData_o   => id_reg_data_o,

			SpRegWrite_o => id_sp_reg_write_o,
			SpRegRead_o  => id_sp_reg_read_o,
			WriteSpReg_o  => id_write_sp_reg_o,
			

			IntModule_o  => id_int_module_o,
			BType      => id_btype_o,
			Branch     => id_branch_o,
			Jump       => id_jump_o
		
		);	

	u_id_exe : ID_EX
		port map( 
			clk	  => clk,
			rst   => rst,  	
			flush	=> pc_branch_flag_i,
			stall	=> if_id_stall_i,
			mem_stall_i => mem_stall_i,
			flash_complete => flash_complete,
			A_i => id_A_o,
			B_i => id_B_o,
			S_i => id_S_o,

			A_o => id_exe_A_o,
			B_o => id_exe_B_o,
			S_o => id_exe_S_o,

			rx_i => id_rx_o,
			ry_i => id_ry_o,
			rz_i => id_rz_o,

			rx_o => id_exe_rx_o,
			ry_o => id_exe_ry_o,
			rz_o => id_exe_rz_o,
			

			imm_i => id_imm_o,
			imm_o => id_exe_imm_o,

			ALUSrcA_i    => id_alu_src_A_o,
			ALUSrcA_o    => id_exe_alu_src_A_o,
			ALUSrcB_i    => id_alu_src_B_o,
			ALUSrcB_o    => id_exe_alu_src_B_o,
			ALUOp_i      => id_alu_op_o,
			ALUOp_o      => id_exe_alu_op_o,

			RegDst_i	=> id_reg_dst_o,
			RegDst_o	=> id_exe_reg_dst_o,
			RegWrite_i  => id_reg_write_o,
			RegWrite_o  => id_exe_reg_write_o,
			RegData_i   => id_reg_data_o,
			RegData_o   => id_exe_reg_data_o,

			SpRegWrite_i  => id_sp_reg_write_o,
			SpRegWrite_o  => id_exe_sp_reg_write_o,
			SpRegRead_i   => id_sp_reg_read_o,
			SpRegRead_o   => id_exe_sp_reg_read_o,

			WriteSpReg_i  => id_write_sp_reg_o,
			WriteSpReg_o  => id_exe_write_sp_reg_o,
			
			MemRead_i     => id_mem_read_o,
			MemRead_o     => id_exe_mem_read_o,
			
			MemWrite_i    => id_mem_write_o,
			MemWrite_o    => id_exe_mem_write_o,
			MemData_i     => id_mem_data_o,
			MemData_o     => id_exe_mem_data_o,

			IntModule_i   => id_int_module_o,
			IntModule_o   => id_exe_int_module_o,
			
			--pc
			pc_i => id_pc_o,
			pc_o => id_exe_pc_o
		);			

	u_exe : EX
		port map(
			clk	  => clk,
			pc_i  => id_exe_pc_o,
			A_i   => id_exe_A_o,
			B_i   => id_exe_B_o,
			S_i	  => id_exe_S_o,
			imm_i => id_exe_imm_o,
			--上条指令的运算结果
			ForwardData1_alu => exe_mem_alu_output_o,
			--上条指令的内存结果
			ForwardData1_mem => mem_data_o,
			--上上条指令的运算结果
			ForwardData2    => mem_wb_wb_data_o,
			

			rx_i => id_exe_rx_o,
			ry_i => id_exe_ry_o,
			rz_i => id_exe_rz_o,


			ALUSrcA_i  => id_exe_alu_src_A_o,
			ALUSrcB_i  => id_exe_alu_src_B_o,
			ForwardA_i => exe_ForwardA_i,
			ForwardB_i => exe_ForwardB_i,
			--EXE段MEM_Data要用的数据前推控制信号
			ForwardMemDataA_i     => exe_ForwardMemDataA_i,
			ForwardMemDataB_i     =>  exe_ForwardMemDataB_i,			
			ALUOp_i    => id_exe_alu_op_o,
			ALUOut	=> exe_alu_out_o,

			RegDst_i => id_exe_reg_dst_o,
			RegDst_o => exe_reg_dst_o,
			
			MemData_i  => id_exe_mem_data_o,
			-- 要写入内存的数据
			MemData_o => exe_mem_data_o
		);
		
	u_exe_mem : EX_MEM
		port map(
			clk	   => clk,
			rst    => rst,		
			flush  => pc_branch_flag_i,
			stall  => if_id_stall_i,
			mem_stall_i => mem_stall_i,			
			flash_complete => flash_complete,	
			RegDst_i	=> exe_reg_dst_o,
			RegDst_o	=> exe_mem_reg_dst_o,
			RegWrite_i  => id_exe_reg_write_o,
			RegWrite_o  => exe_mem_reg_write_o,
			RegData_i    => id_exe_reg_data_o,		
			RegData_o    => exe_mem_reg_data_o,
			SpRegWrite_i  => id_exe_sp_reg_write_o,
			SpRegWrite_o  => exe_mem_sp_reg_write_o,
			WriteSpReg_i  => id_exe_write_sp_reg_o,
			WriteSpReg_o  => exe_mem_write_sp_reg_o,
			MemRead_i     => id_exe_mem_read_o,
			MemRead_o     => exe_mem_mem_read_o,
			MemWrite_i    => id_exe_mem_write_o,
			MemWrite_o    => exe_mem_mem_write_o,
			
			-- EXE段传来的ALU计算结果
			ALUOut_i	=> exe_alu_out_o,
			ALUOut_o	=> exe_mem_alu_output_o,
			-- EXE段传来的要写回内存的值
			MEMData_i   => exe_mem_data_o,			
			MEMData_o	=> exe_mem_mem_data_o,
			IntModule_i  => id_exe_int_module_o,
			IntModule_o   => exe_mem_int_module_o
		);
	u_mem_wb : MEM_WB
		port map(
			clk	  => clk,
			rst   => rst,		
			flush => pc_branch_flag_i,
			stall => if_id_stall_i,
			mem_stall_i => mem_stall_i,
			flash_complete  => flash_complete,
			ALUOut_i	 => exe_mem_alu_output_o,
			ALUOut_o	 => mem_wb_alu_output_o,
			MEMData_i	 => mem_data_o,		
			MEMData_o	 => mem_wb_mem_data_o,
			RegDst_i	 => exe_mem_reg_dst_o,
			RegDst_o	 => mem_wb_reg_dst_o,
			   
			RegWrite_i    => exe_mem_reg_write_o,
			RegWrite_o    => mem_wb_reg_write_o,
			RegData_i     => exe_mem_reg_data_o,	
			RegData_o     => mem_wb_reg_data_o,

			SpRegWrite_i  => exe_mem_sp_reg_write_o,
			SpRegWrite_o  => mem_wb_sp_reg_write_o,
			WriteSpReg_i  => exe_mem_write_sp_reg_o,
			WriteSpReg_o  => mem_wb_write_sp_reg_o,

			--是否在中断
			IntModule_i   => exe_mem_int_module_o,
			IntModule_o   => mem_wb_int_module_o,
		
			WB_Data    => mem_wb_wb_data_o
		);
end Behavioral;

