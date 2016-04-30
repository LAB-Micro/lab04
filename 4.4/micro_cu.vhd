library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.myTypes.all;

entity micro_cu is
  port (
              -- FIRST PIPE STAGE OUTPUTS
              EN1    : out std_logic;               -- enables the register file and the pipeline registers
              RF1    : out std_logic;               -- enables the read port 1 of the register file
              RF2    : out std_logic;               -- enables the read port 2 of the register file
              WF1    : out std_logic;               -- enables the write port of the register file
              -- SECOND PIPE STAGE OUTPUTS
              EN2    : out std_logic;               -- enables the pipe registers
              S1     : out std_logic;               -- input selection of the first multiplexer
              S2     : out std_logic;               -- input selection of the second multiplexer
              ALU1   : out std_logic;               -- alu control bit
              ALU2   : out std_logic;               -- alu control bit
              -- THIRD PIPE STAGE OUTPUTS
              EN3    : out std_logic;               -- enables the memory and the pipeline registers
              RM     : out std_logic;               -- enables the read-out of the memory
              WM     : out std_logic;               -- enables the write-in of the memory
              S3     : out std_logic;               -- input selection of the multiplexer
              -- INPUTS
              OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
              FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0);              
              Clk : in std_logic;
              Rst : in std_logic);      

end micro_cu;

architecture fsm_cu_beh of micro_cu is
	
	type micro_memory is array(2**(FUNC_SIZE'length + OP_CODE_SIZE'length)) of std_logic_vector(N_OUTS-1 downto 0); 
	signal micro_mem : micro_memory := (others => (others => '0'));
	signal counter : integer := 0;
  
	type TYPE_STATE is (
		reset, stage123
	);
	signal CURRENT_STATE : TYPE_STATE := reset;
	signal NEXT_STATE : TYPE_STATE;
  
	signal uPC: std_logic_vector((FUNC_SIZE'length + OP_CODE_SIZE'length - 1) downto 0) := (others =>'0');--uPC=Func&OPCODE.  the total bits are 17
	
	
	--															 PIPELINES
	--															1st	 2st  3st
	--								           
	--															RF1  0	  0
	--															RF2  0	  0
	--															EN1  0	  0
	--															 0	 S1	  0
	--															 0	 S2	  0
	--															 0	ALU1  0
	--															 0	ALU2  0
	--															 0	EN2	  0
	--															 0	 0	  RM
	--															 0	 0	  WM
	--															 0	 0	  S3
	--															 0	 0	  EN3
	--															 0	 0	  WF1
	--
	--															 3 +  5 +  5   useful bits
	--
	
	------------------------------------    MICRO MEMORY  -------------------------------------------------
	
	--R-Type instruction 
	-- ADD RS1,RS2,RD				 FUNC	   & OPCODE
	signal micro_mem(conv_integer("00000000000"&"000000")) := "111"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"000001")) := (2 downto 0 => '0')&"01001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"000010")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- SUB RS1,RS2,RD
	signal micro_mem(conv_integer("00000000001"&"000000")) := "111"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000001"&"000001")) := (2 downto 0 => '0')&"01011"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000001"&"000010")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- AND RS1,RS2,RD
	signal micro_mem(conv_integer("00000000010"&"000000")) := "111"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000010"&"000001")) := (2 downto 0 => '0')&"01101"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000010"&"000010")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- OR RS1,RS2,RD
	signal micro_mem(conv_integer("00000000011"&"000000")) := "111"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000011"&"000001")) := (2 downto 0 => '0')&"01111"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000011"&"000010")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";

	
	--I-Type instruction
	-- ADDI1 RS2,RD,INP1
	signal micro_mem(conv_integer("00000000000"&"000011")) := "011"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"000100")) := (2 downto 0 => '0')&"11001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"000101")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	
	-- SUBI1 RS2,RD,INP1
	signal micro_mem(conv_integer("00000000000"&"000110")) := "011"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"000111")) := (2 downto 0 => '0')&"11011"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"001000")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- ANDI1 RS2,RD,INP1
	signal micro_mem(conv_integer("00000000000"&"001001")) := "011"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"001010")) := (2 downto 0 => '0')&"11101"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"001011")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	
	-- ORI1 RS2,RD,INP1
	signal micro_mem(conv_integer("00000000000"&"001100")) := "011"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"001101")) := (2 downto 0 => '0')&"11111"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"001110")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	
	-- ADDI2 RS1,RD,INP2
	signal micro_mem(conv_integer("00000000000"&"001111")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"010000")) := (2 downto 0 => '0')&"00001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"010001")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- SUBI2 RS1,RD,INP2
	signal micro_mem(conv_integer("00000000000"&"010101")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"010110")) := (2 downto 0 => '0')&"00011"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"010111")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- ANDI2 RS1,RD,INP2
	signal micro_mem(conv_integer("00000000000"&"011000")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"011001")) := (2 downto 0 => '0')&"00101"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"011010")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- ORI2 RS1,RD,INP2
	signal micro_mem(conv_integer("00000000000"&"011011")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"011100")) := (2 downto 0 => '0')&"00111"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"011101")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- mov RS1, RD, INP2	ADDI2 R0,RD,INP2, inp2 is 0
	signal micro_mem(conv_integer("00000000000"&"011110")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"011111")) := (2 downto 0 => '0')&"00001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"100000")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- sav RD, input1	ADDI1 R0,RD,INP1, r0 is 0
	signal micro_mem(conv_integer("00000000000"&"100001")) := "011"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"100010")) := (2 downto 0 => '0')&"11001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"100011")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- sav RD, input2	ADDI2 R0,RD,INP2, r0 is 0
	signal micro_mem(conv_integer("00000000000"&"100100")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"100101")) := (2 downto 0 => '0')&"00001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"100110")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"00011";
	
	-- MEM[R1+inp2]=r2
	signal micro_mem(conv_integer("00000000000"&"100111")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"101000")) := (2 downto 0 => '0')&"00001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"101001")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"01010";
	
	-- RD=mem[inp1+r1]
	signal micro_mem(conv_integer("00000000000"&"101010")) := "011"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"101011")) := (2 downto 0 => '0')&"11001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"101100")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"10111";
	
	-- tra la istruzione superriore e quella inferiore c'è un gap nell'indice OPCODE.. come mai?? 101100 -> 110000
	
	-- RD=mem[inp2+r1]
	signal micro_mem(conv_integer("00000000000"&"110000")) := "101"&(4 downto 0 => '0')&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"110001")) := (2 downto 0 => '0')&"00001"&(4 downto 0 => '0');
	signal micro_mem(conv_integer("00000000000"&"110010")) := (2 downto 0 => '0')&(4 downto 0 => '0')&"10111";
	
 
begin

 	update_state : process(Clk)		
                  begin
                  if (Clk ='1' and Clk'EVENT) then
                  --when RESET we set the starting address.
                    if Rst='1' then
                            CURRENT_STATE <= reset;
                            uPC <=FUNC&OPCODE;
							counter <= 0;
                    else 
						if counter < 3 then
							CURRENT_STATE <= NEXT_STATE;
							--uPC <= uPC + "00000000000000001";
							uPC <= uPC + ((FUNC_SIZE'length + OP_CODE_SIZE'length - 1) downto 0 => '0') & '1';
							counter <= counter + 1;
						end if;
                    end if;
                end process update_state;
                
  output_next_state : process(uPC, CURRENT_STATE)
                      begin
                      case CURRENT_STATE is
                          when reset =>
							  -- FIRST PIPE STAGE OUTPUTS
								EN1		<='0';					-- disables the register file and the pipeline registers
								RF1		<='0';					-- disables the read port 1 of the register file
								RF2		<='0';					-- disables the read port 2 of the register file
								WF1		<='0';   				-- disables the write port of the register file
								EN2		<='0';					-- disables the pipe registers
								EN3		<='0';					-- disables the memory and the pipeline registers
								RM		<='0';					-- disables the read-out of the memory
								WM		<='0';					-- disables the write-in of the memory
                          
								NEXT_STATE <= stage123;
                          
                          when stage123 =>
								-- FIRST PIPE STAGE OUTPUTS
								RF1    <= micro_memory(conv_integer(uPC))(0);   -- enables the read port 1 of the register file
								RF2    <= micro_memory(conv_integer(uPC))(1);   -- enables the read port 2 of the register file
								EN1    <= micro_memory(conv_integer(uPC))(2);   -- enables the register file and the pipeline registers
								-- SECOND PIPE STAGE OUTPUTS
								S1     <= micro_memory(conv_integer(uPC))(3);   -- input selection of the first multiplexer
								S2     <= micro_memory(conv_integer(uPC))(4);   -- input selection of the second multiplexer
								ALU1   <= micro_memory(conv_integer(uPC))(5);   -- alu control bit
								ALU2   <= micro_memory(conv_integer(uPC))(6);   -- alu control bit
								EN2    <= micro_memory(conv_integer(uPC))(7);   -- enables the pipe registers
								-- THIRD PIPE STAGE OUTPUTS
								RM     <= micro_memory(conv_integer(uPC))(8);   -- enables the read-out of the memory
								WM     <= micro_memory(conv_integer(uPC))(9);   -- enables the write-in of the memory
								S3     <= micro_memory(conv_integer(uPC))(10);   -- input selection of the multiplexer
								EN3    <= micro_memory(conv_integer(uPC))(11);   -- enables the memory and the pipeline registers
								WF1    <= micro_memory(conv_integer(uPC))(12);   -- enables the write port of the register file

                      end case; --end case of current state                  
                      
                      end process;
        
end fsm_cu_beh;
        

