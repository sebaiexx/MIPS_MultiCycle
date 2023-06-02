library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MultiCycle is
    Port ( CLKmain : in  STD_LOGIC);
end MultiCycle;

architecture Behavioral of MultiCycle is

COMPONENT ALUControl
	PORT(
		Func : IN std_logic_vector(5 downto 0);
		ALUop : IN std_logic_vector(1 downto 0);          
		ALUcon : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

COMPONENT ALU
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);
		ALUControl : IN std_logic_vector(3 downto 0);          
		Output : OUT std_logic_vector(31 downto 0);
		Zero : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT Reg
	PORT(
		input : IN std_logic_vector(31 downto 0);
		CLK : IN std_logic;          
		output : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ControlUnit
	PORT(
		OP : IN std_logic_vector(5 downto 0);
		CLK : IN std_logic;          
		RegDst : OUT std_logic;
		MemToReg : OUT std_logic;
		RegWrite : OUT std_logic;
		MemRead : OUT std_logic;
		MemWrite : OUT std_logic;
		PCWriteCond : OUT std_logic;
		PCWrite : OUT std_logic;
		IorD : OUT std_logic;
		IRWrite : OUT std_logic;
		ALUop : OUT std_logic_vector(1 downto 0);
		PCSource : OUT std_logic_vector(1 downto 0);
		ALUSrcB : OUT std_logic_vector(1 downto 0);
		ALUSrcA : OUT std_logic
		);
	END COMPONENT;
	
	--MUX 2 input 32 Bit--	
COMPONENT MUX2to1
	PORT(
		a : IN std_logic_vector(31 downto 0);
		b : IN std_logic_vector(31 downto 0);
		sel : IN std_logic;          
		output : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
--MUX 2 input 5 Bit--	
COMPONENT MUXRegDst
	PORT(
		a : IN std_logic_vector(4 downto 0);
		b : IN std_logic_vector(4 downto 0);
		sel : IN std_logic;          
		output : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;

--MUX 4 input 32 bit--	
COMPONENT MUX4to1
	PORT(
		a : IN std_logic_vector(31 downto 0);
		b : IN std_logic_vector(31 downto 0);
		c : IN std_logic_vector(31 downto 0);
		d : IN std_logic_vector(31 downto 0);
		sel : IN std_logic_vector(1 downto 0);          
		output : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
COMPONENT Memory
	PORT(
		memwrite : IN std_logic;
		memread : IN std_logic;
		Wdata : IN std_logic_vector(31 downto 0);
		address : IN std_logic_vector(31 downto 0);
		IORD : IN std_logic;
		CLK : IN std_logic;          
		Rdata : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

COMPONENT InstructionReg
	PORT(
		input : IN std_logic_vector(31 downto 0);
		sig : IN std_logic;
		CLK : IN std_logic;          
		output : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	

	
COMPONENT RegisterFile
	PORT(
		rs : IN std_logic_vector(4 downto 0);
		rt : IN std_logic_vector(4 downto 0);
		rd : IN std_logic_vector(4 downto 0);
		WriteData : IN std_logic_vector(31 downto 0);
		RegWrite : IN std_logic;        
		ReadData1 : OUT std_logic_vector(31 downto 0);
		ReadData2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
COMPONENT ShiftLeft2
	PORT(
		a : IN std_logic_vector(31 downto 0);          
		b : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
COMPONENT SignExtend
	PORT(
		a : IN std_logic_vector(15 downto 0);          
		b : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	signal ZeroFlag,sigPCWriteCond,sigPCWrite,sigIorD,sigMemRead,sigMemWrite,sigMemToReg,sigIRWrite,sigALUSrcA,sigRegWrite,sigRegDst:std_logic;
	signal sigPCSource,sigALUOp,sigALUSrcB: std_logic_vector(1 downto 0);
	signal Instruction,PCin,PCout,ALUOutout,sigaddress,MEMout,MemDatain,MDRout,WriteDatain,Ain,Bin,SignExtendOut,ShiftLeftOut,Aout,ALUin1,ALUin2,ALUresult: std_logic_vector(31 downto 0);
	signal WriteRegisterin: std_logic_vector (4 downto 0);
	signal op: std_logic_vector (3 downto 0);

begin

	Inst_ALUControl: ALUControl PORT MAP(
		Func => Instruction(5 downto 0),
		ALUop => sigALUOp,
		ALUcon => op
	);
	
	Inst_AL: ALU PORT MAP(
		A => ALUin1,
		B => ALUin2,
		ALUControl => op,
		Output => ALUresult,
		Zero => ZeroFlag
	);
	
	MemoryDataRegister: Reg PORT MAP(
		input => MEMout,
		output => MDRout,
		CLK => CLKmain
	);
	
	Inst_ControlUnit: ControlUnit PORT MAP(
		OP => Instruction(31 downto 26),
		RegDst => sigRegDst,
		MemToReg => sigMemtoReg,
		RegWrite => sigRegWrite,
		MemRead => sigMemRead,
		MemWrite => sigMemWrite,
		PCWriteCond => sigPCWriteCond,
		PCWrite => sigPCWrite,
		IorD => sigIorD,
		IRWrite => sigIRWrite,
		ALUop => sigALUOp,
		PCSource => sigPCSource,
		ALUSrcB => sigALUSrcB,
		ALUSrcA => sigALUSrcA,
		CLK => CLKmain
	);
	
	Inst_InstructionReg: InstructionReg PORT MAP(
		input => MEMout,
		output => Instruction,
		sig => sigIRWrite,
		CLK => CLKmain
	);
	
	PC: InstructionReg PORT MAP(
		input => PCin,
		output => PCout,
		sig => (ZeroFlag and sigPCWriteCond) or sigPCWrite,
		CLK => CLKmain
	);
	
	ALUmux: MUX2to1 PORT MAP(
		a => ALUOutout,
		b => MDRout,
		sel => sigMemtoReg,
		output => WriteDatain
	);
	
	MUXmem: MUX2to1 PORT MAP(
		a => PCout,
		b => ALUOutout,
		sel => sigIorD,
		output => sigaddress
	);
	
	MUXregA: MUX2to1 PORT MAP(
		a => PCout,
		b => Aout,
		sel => sigALUSrcA,
		output => ALUin1
	);
	
	MUXregB: MUX4to1 PORT MAP(
		a => MemDatain,
		b => "00000000000000000000000000000100",
		c => SignExtendOut,
		d => ShiftLeftOut,
		sel => sigALUSrcB,
		output => ALUin2
	);
	
	MUXpc: MUX4to1 PORT MAP(
		a => ALUresult,
		b => ALUOutout,
		c => "00000000000000000000000000000000",
		d => "00000000000000000000000000000000",
		sel => sigPCsource,
		output => PCin
	);
	
	Inst_MUXRegDst: MUXRegDst PORT MAP(
		a => Instruction(20 downto 16),
		b => Instruction(15 downto 11),
		sel => sigRegDst,
		output => WriteRegisterin 
	);
	
	Inst_Memory: Memory PORT MAP(
		memwrite => sigMemWrite,
		memread => sigMemRead,
		Wdata => MemDataIn,
		Rdata => MemOut,
		address => sigAddress,
		IORD => sigIorD,
		CLK => CLKmain
	);
	
	RegA: Reg PORT MAP(
		input => Ain,
		output => Aout,
		CLK => CLKmain
	);

	RegB: Reg PORT MAP(
		input => Bin,
		output => MemDatain,
		CLK => CLKmain 
	);
	
	RegALUout: Reg PORT MAP(
		input => ALUresult,
		output => ALUOutout,
		CLK => CLKmain
	);
	
		Inst_RegisterFile: RegisterFile PORT MAP(
		ReadData1 => Ain,
		ReadData2 => Bin,
		rs => Instruction(25 downto 21),
		rt => Instruction(20 downto 16),
		rd => WriteRegisterin,
		WriteData => WriteDataIn,
		RegWrite => sigRegWrite
	);
	
	Inst_ShiftLeft2: ShiftLeft2 PORT MAP(
		a => SignExtendOut,
		b => ShiftLeftOut
	);
	
	Inst_SignExtend: SignExtend PORT MAP(
		a => Instruction(15 downto 0),
		b => SignExtendOut
	);


end Behavioral;

