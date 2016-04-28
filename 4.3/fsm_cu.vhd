library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use ieee.numeric_std.all;
--use work.all;

entity fsm_cu is
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

end fsm_cu;

architecture fsm_cu_beh of fsm_cu is

  signal to_stage_2 : std_logic_vector(9 downto 0) := (others=>'0');
  signal to_stage_3 : std_logic_vector(4 downto 0) := (others=>'0');
  
	type TYPE_STATE is (
		reset, stage1, stage2, stage3
	);
	signal CURRENT_STATE : TYPE_STATE := reset;
	signal NEXT_STATE : TYPE_STATE := fetch;



 
begin

 	update_state : process(Clk)		
                  begin
                  if (Clk ='1' and Clk'EVENT) then
                    if Rst='1' then
                            CURRENT_STATE <= reset;
                    else 
                      CURRENT_STATE <= NEXT_STATE;
                    end if;
                end process update_state;
                
  output_next_state : process(CURRENT_STATE)
                      begin
                      case CURRENT_STATE is
                          when reset =>
                          -- FIRST PIPE STAGE OUTPUTS
                          EN1  <='0';                 -- disables the register file and the pipeline registers
                          RF1  <='0';                  -- disables the read port 1 of the register file
                          RF2  <='0';                -- disables the read port 2 of the register file
                          WF1  <='0';   
                              
                          to_stage_2 <=(others=>'0');
                          
                          when stage1 =>
                                case OPCODE is 
                                when  RTYPE  =>--R-Type
                                
                              -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1 of the register file
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                              
                                    --check FUNCTION signal for ALU signal                            
                                     case FUNC is
                                        when RTYPE_ADD =>  -- ADD "00000000000"
                                        to_stage_2<="0100100101";
                                        --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                       
                                        
                                        when RTYPE_SUB =>    -- SUB RS1,RS2,RD "00000000001"
                                        to_stage_2<="0101100101";
                                        --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                       
                                      
                                        
                                        when RTYPE_AND=>    -- AND RS1,RS2,RD "00000000010"
                                        to_stage_2<="0101000101";
                                        --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                       
                                        
                                        when => RTYPE_OR   -- OR RS1,RS2,RD "00000000011"
                                        to_stage_2<="0111100101";
                                        --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                       
                                        
                                        when others   =>  -- Error: we don't recognize the function
                                        to_stage_2<="0000000000";
                                        --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                       -- function is UNKNOWN
                                     end case;
                                
                                when ITYPE_ADDI1 =>
                                    
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    to_stage_2 <="1100100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                when ITYPE_SUBI1 =>
                                -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    to_stage_2 <="1101100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                when ITYPE_ANDI1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    to_stage_2 <="1110100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                  
                              when ITYPE_ORI1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    to_stage_2 <="1111100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                                                     
                                when ITYPE_ADDI2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    to_stage_2 <="0000100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                                                    
                                when ITYPE_SUBI2 =>
                                -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    to_stage_2 <="0001100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                
                                when ITYPE_ANDI2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    to_stage_2 <="0010100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                              when ITYPE_ORI2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    to_stage_2 <="0011100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                              when MOV =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2, immediate='0'
                                    
                                    to_stage_2 <="0000100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                    
                                         
                              when S_REG1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1
                                    RF2   <='1';                -- enables the read port 2, should read r0
                                    
                                    to_stage_2 <="1100100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                    
                                    
                              when S_REG2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1, should read r0
                                    RF2   <='0';                -- disables the read port 2
                                    
                                    to_stage_2 <="0000100101";
                                    --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                    
                                         
                          when S_MEM2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1
                                    RF2   <='0';                -- disables the read port 2, WE have INPUT2
                                    
                                    to_stage_2 <="0000101100";
                                   --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf      
                                
                        when L_MEM1 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='0';                -- disables the read port 1, WE have INPU1
                                    RF2   <='1';                -- enables the read port 2 of the register file
                                    
                                    to_stage_2 <="1100110111";
                                   --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                    
                        when L_MEM2 =>
                                    -- FIRST PIPE STAGE OUTPUTS
                                    EN1   <='1';                -- enables the register file and the pipeline registers
                                    RF1   <='1';                -- enables the read port 1,
                                    RF2   <='0';                -- disenables the read port 2, we have INP2
                                    
                                    to_stage_2 <="0000110111";
                                   --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                    
                        when others   =>  -- Error: we don't recognize the OPCODE
                                        to_stage_2<="0000000000";
                                        --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                                        -- OPCODE is UNKNOWN        
                      end case; --end case of OPCODE
                      NEXT_STATE <= stage2;
                      --disable the signals for stage2 and stage3
                      s1 <='0';
                      s2 <='0';
                      alu1 <='0';
                      alu2 <='0';
                      en2 <='0';
                      rm <='0';
                      wm <='0';
                      en3 <='0';
                      s3 <='0';
                      wf <='0';
                      when stage2=>
                      --disable the signals for stage1
                      EN1   <='0';                
                      RF1   <='0';                
                      RF2   <='0';
                      
                      --enable signals for stage2
                      --s1,s2,alu1,alu2,en2,rm,wm,en3,s3,wf
                      s1 <=to_stage_2(9);
                      s2 <=to_stage_2(8);
                      alu1 <=to_stage_2(7);
                      alu2 <=to_stage_2(6);
                      en2 <=to_stage_2(5);
                      to_stage_3 <=to_stage_2(4 downto 0);
                      
                      --disables signals for stage3
                      rm <='0';
                      wm <='0';
                      en3 <='0';
                      s3 <='0';
                      wf <='0';
                      NEXT_STATE <= stage3;
                      when stage3=>
                      --disable the signals for stage1
                      EN1   <='0';                
                      RF1   <='0';                
                      RF2   <='0';
                      
                      --disables signals for stage2
                      s1 <='0';
                      s2 <='0';
                      alu1 <='0';
                      alu2 <='0';
                      en2 <='0';
                      
                      --enable the signal for stage3
                      --rm,wm,en3,s3,wf
                      rm <=to_stage_3(4);
                      wm <=to_stage_3(3);
                      en3 <=to_stage_3(2);
                      s3 <=to_stage_3(1);
                      wf <=to_stage_3(0);
                      NEXT_STATE <= stage1;
                      end case; --end case of current state                  
                      
                      end process;
        
end fsm_cu_beh;
        

