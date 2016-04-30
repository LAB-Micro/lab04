library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant OP_CODE_SIZE	: integer :=  6;       -- OPCODE field size
    constant FUNC_SIZE		: integer :=  11;      -- FUNC field size
	constant N_OUTS		: integer :=  13;      -- NUMBER OF OUTPUTS OF THE CONTROLLER
	
-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation
-- R-Type instruction -> FUNC field
    constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- ADD RS1,RS2,RD
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";    -- SUB RS1,RS2,RD
    constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";    -- AND RS1,RS2,RD
    constant RTYPE_OR  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";    -- OR RS1,RS2,RD


-- I-Type instruction -> OPCODE field
    --when input1
    constant ITYPE_ADDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";    -- ADDI1 RS2,RD,INP1
    constant ITYPE_SUBI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";    -- SUBI1 RS2,RD,INP1
    constant ITYPE_ANDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";    -- ANDI1 RS2,RD,INP1
    constant ITYPE_ORI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";    -- ORI1 RS2,RD,INP1
    --when input2
    constant ITYPE_ADDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";    -- ADDI2 RS1,RD,INP2
    constant ITYPE_SUBI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101";    -- SUBI2 RS1,RD,INP2
    constant ITYPE_ANDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011000";    -- ANDI2 RS1,RD,INP2
    constant ITYPE_ORI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011011";    -- ORI2 RS1,RD,INP2
    
    constant MOV  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011110";           --mov RS1, RD, INP2
                                                                                           --ADDI2 R0,RD,INP2, inp2 is 0
                                                                                           
    constant S_REG1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";        --sav RD, input1
                                                                                           --ADDI1 R0,RD,INP1, r0 is 0
                                                                                           
    constant S_REG2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100100";        --sav RD, input2
                                                                                           --ADDI2 R0,RD,INP2, r0 is 0
                                                                                           
    constant S_MEM2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100111";        --MEM[R1+inp2]=r2       
    constant L_MEM1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101010";        --RD=mem[inp1+r1]
    constant L_MEM2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110000";        --RD=mem[inp2+r1]
    

-- Change the values of the instructions coding as you want, depending also on the type of control unit choosen

end myTypes;

