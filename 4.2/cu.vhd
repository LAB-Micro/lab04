library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use ieee.numeric_std.all;
--use work.all;

entity cu is
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
              Rst : in std_logic);                  -- Active Low
    end cu;

architecture cu_hw of cu is
begin
cu_beh: process(clk)
        begin
        if (clk='1' and clk'event) then
          if (RST='1') then
                    -- FIRST PIPE STAGE OUTPUTS
                    EN1   <='0';             -- enables the register file and the pipeline registers
                    RF1   <='0';                -- enables the read port 1 of the register file
                    RF2   <='0';                -- enables the read port 2 of the register file
                    WF1   <='0';              -- enables the write port of the register file
                   


                   -- SECOND PIPE STAGE OUTPUTS
                    EN2    <='0';                -- enables the pipe registers
                    
                    --WE set WF1 <='0', so the ALU can do whatever he wants, we will never save the output
                    --to the REGISTER FILE
                    
                    --S1     : out std_logic;               -- input selection of the first multiplexer
                    --S2     : out std_logic;               -- input selection of the second multiplexer
                    --ALU1   : out std_logic;               -- alu control bit
                    --ALU2   : out std_logic;               -- alu control bit
                    
                    
                    
                    -- THIRD PIPE STAGE OUTPUTS
                    EN3    <='0';               -- enables the memory and the pipeline registers
                    RM     <='0';               -- enables the read-out of the memory
                    WM     <='0';                -- enables the write-in of the memory
                    
                    --Mux between memory output or ALU output, 
                    --this value is not important since we don't look the output of the MUX
                    --S3     : out std_logic;

                    --END RESET='1'
                        
                    
                    else --now reset='0', the CU is active 
                        
                        --we check OPCODE signals
                        case OPCODE is 
                                when  RTYPE  =>--R-Type
                                
                              -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1 of the register file
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                              -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='1';               -- input selection of the second multiplexer
                                                                --s2=1, select from RF
                                    --check FUNCTION signal for ALU signal                            
                                     case FUNC is
                                        when RTYPE_ADD =>  -- ADD "00000000000"
                                        ALU1   <='0';            -- alu control bit
                                        ALU2   <='0';
                                        EN2    <='1';               -- enables the pipe registers
                                        WF1   <='1';                -- enables the write port of the register file, R-TYpe, need to save output in RF
                                        -- THIRD PIPE STAGE OUTPUTS
                                        EN3    <='1';               -- enables the memory and the pipeline registers
                                        RM     <='0';               -- disables the read-out of the memory
                                        WM     <='0';                -- disables the write-in of the memory
                                        s3     <='0';               -- input selection of the third multiplexer
                                                                    --s3=0, select from ALU_OUTPUT
                                        
                                        when RTYPE_SUB =>    -- SUB RS1,RS2,RD "00000000001"
                                        ALU1   <='0';            -- alu control bit
                                        ALU2   <='1';
                                        EN2    <='1';               -- enables the pipe registers
                                        WF1   <='1';                -- enables the write port of the register file, R-TYpe, need to save output in RF
                                        -- THIRD PIPE STAGE OUTPUTS
                                        EN3    <='1';               -- enables the memory and the pipeline registers
                                        RM     <='0';               -- disables the read-out of the memory
                                        WM     <='0';                -- disables the write-in of the memory
                                        s3     <='0';               -- input selection of the third multiplexer
                                                                    --s3=0, select from ALU_OUTPUT
                                        
                                        when RTYPE_AND=>    -- AND RS1,RS2,RD "00000000010"
                                        ALU1   <='1';            -- alu control bit
                                        ALU2   <='0';
                                        EN2    <='1';               -- enables the pipe registers
                                        WF1   <='1';                -- enables the write port of the register file, R-TYpe, need to save output in RF
                                        -- THIRD PIPE STAGE OUTPUTS
                                        EN3    <='1';               -- enables the memory and the pipeline registers
                                        RM     <='0';               -- disables the read-out of the memory
                                        WM     <='0';                -- disables the write-in of the memory
                                        s3     <='0';               -- input selection of the third multiplexer
                                                                    --s3=0, select from ALU_OUTPUT
                                        
                                        when  RTYPE_OR =>  -- OR RS1,RS2,RD "00000000011"
                                        ALU1   <='1';            -- alu control bit
                                        ALU2   <='1';
                                        EN2    <='1';               -- enables the pipe registers
                                        WF1   <='1';                -- enables the write port of the register file, R-TYpe, need to save output in RF
                                        -- THIRD PIPE STAGE OUTPUTS
                                        EN3    <='1';               -- enables the memory and the pipeline registers
                                        RM     <='0';               -- disables the read-out of the memory
                                        WM     <='0';                -- disables the write-in of the memory
                                        s3     <='0';               -- input selection of the third multiplexer
                                                                    --s3=0, select from ALU_OUTPUT
                                        
                                        when others   =>  -- Error: we don't recognize the function
                                        EN2    <='0';               -- disables the pipe registers
                                        --don't save alu output
                                        -- DISABLE 3rd stage output
                                        EN3    <='0';               -- disables the memory and the pipeline registers
                                        RM     <='0';               -- disables the read-out of the memory
                                        WM     <='0';                -- disables the write-in of the memory
                                        --DISABLE WRITE ALU_OUTPUT IN RF
                                        WF1   <='0';                -- disables the write port of the register file, functio is UNKNOWN
                                     end case;
                                
                                when ITYPE_ADDI1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='1';               -- input selection of the first multiplexer
                                                                --s1=1, select from inp1
                                    S2     <='1';               -- input selection of the second multiplexer
                                                                --s2=1, select from RF
                                    --ALU SIGNALS ADDITION                           
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                                                    --s3=0, select from ALU_OUTPUT
                                                                    
                                when ITYPE_SUBI1 =>
                                -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='1';               -- input selection of the first multiplexer
                                                                --s1=1, select from inp1
                                    S2     <='1';               -- input selection of the second multiplexer
                                                                --s2=1, select from RF
                                    --ALU SIGNALS, SUBSTRACTION                            
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='1';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                                                 --s3=0, select from ALU_OUTPUT
                                when ITYPE_ANDI1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='1';               -- input selection of the first multiplexer
                                                                --s1=1, select from inp1
                                    S2     <='1';               -- input selection of the second multiplexer
                                                                --s2=1, select from RF
                                    --ALU SIGNALS, AND OPERATION                            
                                    ALU1   <='1';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                                              --s3=0, select from ALU_OUTPUT
                                  
                              when ITYPE_ORI1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='1';               -- input selection of the first multiplexer
                                                                --s1=1, select from inp1
                                    S2     <='1';               -- input selection of the second multiplexer
                                                                --s2=1, select from RF
                                    --ALU SIGNALS, AND OPERATION                            
                                    ALU1   <='1';            -- alu control bit
                                    ALU2   <='1';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                                                --s3=0, select from ALU_OUTPUT
                                                                     
                                when ITYPE_ADDI2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                                --s2=0, select from inp2
                                    --ALU SIGNALS ADDITION                           
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                                                    --s3=0, select from ALU_OUTPUT
                                                                    
                                when ITYPE_SUBI2 =>
                                -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                                --s2=0, select from inp2
                                    --ALU SIGNALS, SUBSTRACTION                            
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='1';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                
                                when ITYPE_ANDI2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                               --s2=0, select from inp2
                                    --ALU SIGNALS, AND OPERATION                            
                                    ALU1   <='1';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                  
                              when ITYPE_ORI2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                                --s2=0, select from inp2
                                    --ALU SIGNALS, AND OPERATION                            
                                    ALU1   <='1';            -- alu control bit
                                    ALU2   <='1';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                                                     
                              when MOV =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2, immediate='0'
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                               --s2=0, select from immediate, inp2
                                    --ALU SIGNALS, ADD OPERATION 
                                        --addition rs1 + inpb. inpb is equal to 0.
                                        --save the result in RD.
                                        --overall we are doing RD=rs1
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                         
                              when S_REG1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1
                                    RF2   <='1';                -- enables the read port 2, should read r0
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='1';               -- input selection of the first multiplexer
                                                                --s1=1, select from inp1
                                    S2     <='1';               -- input selection of the second multiplexer
                                                               --s2=1, select from RF
                                    --ALU SIGNALS, ADD OPERATION 
                                        --addition r0 + inp1. r0 is equal to 0
                                        --save the result in RD.
                                        --overall we are doing RD=inp1
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                    
                              when S_REG2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1, should read r0
                                    RF2   <='0';                -- disables the read port 2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                               --s2=0, select from inp2
                                    --ALU SIGNALS, ADD OPERATION 
                                        --addition r0 + inpb. r0 is equal to 0
                                        --save the result in RD.
                                        --overall we are doing RD=inpb
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
                                    WF1   <='1';                -- enables the write port of the register file, I-TYpe, need to save output in RF
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='0';                -- disables the write-in of the memory
                                    s3     <='0';               -- input selection of the third multiplexer
                                         
                          when S_MEM2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                                --s2=0, select from inp2
                                    --ALU SIGNALS ADDITION                           
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
									WF1   <='0';                --we don't need to save the value in RF    
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='0';               -- disables the read-out of the memory
                                    WM     <='1';                -- enables the write-in of the memory, SAVE INTO MEMORY
                                    s3     <='0';  --we don't need it, but we can check the address for the memory  
                                
                        when L_MEM1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='1';               -- input selection of the first multiplexer
                                                                --s1=1, select from inp1
                                    S2     <='1';               -- input selection of the second multiplexer
                                                                --s2=1, select from RF
                                    --ALU SIGNALS ADDITION                           
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
									WF1   <='1';                -- save the value in RF   
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='1';               -- enables the read-out of the memory, READ and SAVE INTO RF
                                    WM     <='0';                -- disables the write-in of the memory, 
                                    s3     <='1';                -- s3=1, ouput from MEMMORY

                        when L_MEM2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1,
                                    RF2   <='0';                -- disenables the read port 2, we have INP2
                                    
                                    -- SECOND PIPE STAGE OUTPUTS
                                    
                                    S1     <='0';               -- input selection of the first multiplexer
                                                                --s1=0, select from RF
                                    S2     <='0';               -- input selection of the second multiplexer
                                                                --s2=0, select from inp2
                                    --ALU SIGNALS ADDITION                           
                                    ALU1   <='0';            -- alu control bit
                                    ALU2   <='0';
                                    EN2    <='1';               -- enables the pipe registers
									WF1   <='1';                -- save the value in RF   
                                    -- THIRD PIPE STAGE OUTPUTS
                                    EN3    <='1';               -- enables the memory and the pipeline registers
                                    RM     <='1';               -- enables the read-out of the memory, READ and SAVE INTO RF
                                    WM     <='0';                -- disables the write-in of the memory, 
                                    s3     <='1';                -- s3=1, ouput from MEMMORY
									
                      when others   =>  -- Error: we don't recognize the OPCODE
                                        EN2    <='0';               -- disables the pipe registers
                                        --don't save alu output
                                        -- DISABLE 3rd stage output
                                        EN3    <='0';               -- disables the memory and the pipeline registers
                                        RM     <='0';               -- disables the read-out of the memory
                                        WM     <='0';                -- disables the write-in of the memory
                                        --DISABLE WRITE ALU_OUTPUT IN RF
                                        WF1   <='0';                -- disables the write port of the register file, functio is UNKNOWN         
                      end case; --end case of OPCODE
                    end if; --end if reset
          end if; --end if rising edge
          end process cu_beh;
  
end cu_hw;

configuration CFG_cu_HARDWIRED of cu is
  for cu_hw
  end for;
end configuration;
