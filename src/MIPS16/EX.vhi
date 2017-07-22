
-- VHDL Instantiation Created from source file EX.vhd -- 06:44:00 11/24/2016
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT EX
	PORT(
		clk : IN std_logic;
		pc_i : IN std_logic_vector(15 downto 0);
		A_i : IN std_logic_vector(15 downto 0);
		B_i : IN std_logic_vector(15 downto 0);
		S_i : IN std_logic_vector(15 downto 0);
		imm_i : IN std_logic_vector(15 downto 0);
		ForwardData1_alu : IN std_logic_vector(15 downto 0);
		ForwardData1_mem : IN std_logic_vector(15 downto 0);
		ForwardData2 : IN std_logic_vector(15 downto 0);
		rx_i : IN std_logic_vector(2 downto 0);
		ry_i : IN std_logic_vector(2 downto 0);
		rz_i : IN std_logic_vector(2 downto 0);
		ALUSrcA_i : IN std_logic_vector(1 downto 0);
		ALUSrcB_i : IN std_logic;
		ForwardA_i : IN std_logic_vector(1 downto 0);
		ForwardB_i : IN std_logic_vector(1 downto 0);
		ALUOp_i : IN std_logic_vector(3 downto 0);
		RegDst_i : IN std_logic_vector(1 downto 0);
		MemData_i : IN std_logic;          
		ALUOut : OUT std_logic_vector(15 downto 0);
		RegDst_o : OUT std_logic_vector(2 downto 0);
		MemData_o : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	Inst_EX: EX PORT MAP(
		clk => ,
		pc_i => ,
		A_i => ,
		B_i => ,
		S_i => ,
		imm_i => ,
		ForwardData1_alu => ,
		ForwardData1_mem => ,
		ForwardData2 => ,
		rx_i => ,
		ry_i => ,
		rz_i => ,
		ALUSrcA_i => ,
		ALUSrcB_i => ,
		ForwardA_i => ,
		ForwardB_i => ,
		ALUOp_i => ,
		ALUOut => ,
		RegDst_i => ,
		RegDst_o => ,
		MemData_i => ,
		MemData_o => 
	);


