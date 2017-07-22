--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:08:21 11/24/2016
-- Design Name:   
-- Module Name:   D:/xlinix/MIPS16/test_id.vhd
-- Project Name:  MIPS16
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ID
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_id IS
END test_id;
 
ARCHITECTURE behavior OF test_id IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ID
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         flush : IN  std_logic;
         stall : IN  std_logic;
         pc_i : IN  std_logic_vector(15 downto 0);
         inst_i : IN  std_logic_vector(15 downto 0);
         ImmSrc : OUT  std_logic_vector(1 downto 0);
         ImmExt : OUT  std_logic;
         imm : OUT  std_logic_vector(10 downto 0);
         rx : OUT  std_logic_vector(2 downto 0);
         ry : OUT  std_logic_vector(2 downto 0);
         rz : OUT  std_logic_vector(2 downto 0);
         A_i : IN  std_logic_vector(15 downto 0);
         B_i : IN  std_logic_vector(15 downto 0);
         S_i : IN  std_logic_vector(15 downto 0);
         ForwardData_ALU1 : IN  std_logic_vector(15 downto 0);
         ForwardData_MEM1 : IN  std_logic_vector(15 downto 0);
         ForwardData_ALU2 : IN  std_logic_vector(15 downto 0);
         ForwardData_MEM2 : IN  std_logic_vector(15 downto 0);
         ForwardA_i : IN  std_logic_vector(2 downto 0);
         ForwardS_i : IN  std_logic_vector(2 downto 0);
         A_o : OUT  std_logic_vector(15 downto 0);
         B_o : OUT  std_logic_vector(15 downto 0);
         S_o : OUT  std_logic_vector(15 downto 0);
         ALUSrcA_o : OUT  std_logic_vector(1 downto 0);
         ALUSrcB_o : OUT  std_logic;
         ALUOp_o : OUT  std_logic_vector(3 downto 0);
         MemRead_o : OUT  std_logic;
         MemWrite_o : OUT  std_logic;
         MemData_o : OUT  std_logic;
         RegDst_o : OUT  std_logic_vector(1 downto 0);
         RegWrite_o : OUT  std_logic;
         RegData_o : OUT  std_logic;
         SpRegWrite_o : OUT  std_logic_vector(1 downto 0);
         SpRegRead_o : OUT  std_logic_vector(1 downto 0);
         WriteSpReg_o : OUT  std_logic;
         IntModule_o : OUT  std_logic;
         BType : OUT  std_logic_vector(1 downto 0);
         Branch : OUT  std_logic;
         Jump : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal flush : std_logic := '0';
   signal stall : std_logic := '0';
   signal pc_i : std_logic_vector(15 downto 0) := (others => '0');
   signal inst_i : std_logic_vector(15 downto 0) := "1110000000101011";
   signal A_i : std_logic_vector(15 downto 0) := (others => '0');
   signal B_i : std_logic_vector(15 downto 0) := (others => '0');
   signal S_i : std_logic_vector(15 downto 0) := (others => '0');
   signal ForwardData_ALU1 : std_logic_vector(15 downto 0) := (others => '0');
   signal ForwardData_MEM1 : std_logic_vector(15 downto 0) := (others => '0');
   signal ForwardData_ALU2 : std_logic_vector(15 downto 0) := (others => '0');
   signal ForwardData_MEM2 : std_logic_vector(15 downto 0) := (others => '0');
   signal ForwardA_i : std_logic_vector(2 downto 0) := (others => '0');
   signal ForwardS_i : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal ImmSrc : std_logic_vector(1 downto 0);
   signal ImmExt : std_logic;
   signal imm : std_logic_vector(10 downto 0);
   signal rx : std_logic_vector(2 downto 0);
   signal ry : std_logic_vector(2 downto 0);
   signal rz : std_logic_vector(2 downto 0);
   signal A_o : std_logic_vector(15 downto 0);
   signal B_o : std_logic_vector(15 downto 0);
   signal S_o : std_logic_vector(15 downto 0);
   signal ALUSrcA_o : std_logic_vector(1 downto 0);
   signal ALUSrcB_o : std_logic;
   signal ALUOp_o : std_logic_vector(3 downto 0);
   signal MemRead_o : std_logic;
   signal MemWrite_o : std_logic;
   signal MemData_o : std_logic;
   signal RegDst_o : std_logic_vector(1 downto 0);
   signal RegWrite_o : std_logic;
   signal RegData_o : std_logic;
   signal SpRegWrite_o : std_logic_vector(1 downto 0);
   signal SpRegRead_o : std_logic_vector(1 downto 0);
   signal WriteSpReg_o : std_logic;
   signal IntModule_o : std_logic;
   signal BType : std_logic_vector(1 downto 0);
   signal Branch : std_logic;
   signal Jump : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1000 ms;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ID PORT MAP (
          clk => clk,
          rst => rst,
          flush => flush,
          stall => stall,
          pc_i => pc_i,
          inst_i => inst_i,
          ImmSrc => ImmSrc,
          ImmExt => ImmExt,
          imm => imm,
          rx => rx,
          ry => ry,
          rz => rz,
          A_i => A_i,
          B_i => B_i,
          S_i => S_i,
          ForwardData_ALU1 => ForwardData_ALU1,
          ForwardData_MEM1 => ForwardData_MEM1,
          ForwardData_ALU2 => ForwardData_ALU2,
          ForwardData_MEM2 => ForwardData_MEM2,
          ForwardA_i => ForwardA_i,
          ForwardS_i => ForwardS_i,
          A_o => A_o,
          B_o => B_o,
          S_o => S_o,
          ALUSrcA_o => ALUSrcA_o,
          ALUSrcB_o => ALUSrcB_o,
          ALUOp_o => ALUOp_o,
          MemRead_o => MemRead_o,
          MemWrite_o => MemWrite_o,
          MemData_o => MemData_o,
          RegDst_o => RegDst_o,
          RegWrite_o => RegWrite_o,
          RegData_o => RegData_o,
          SpRegWrite_o => SpRegWrite_o,
          SpRegRead_o => SpRegRead_o,
          WriteSpReg_o => WriteSpReg_o,
          IntModule_o => IntModule_o,
          BType => BType,
          Branch => Branch,
          Jump => Jump
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
