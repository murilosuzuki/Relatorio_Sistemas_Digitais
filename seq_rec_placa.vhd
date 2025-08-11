-- Sequence Recognizer: VHDL Process Description
-- (See Figure 4-21 for state diagram)
library ieee;
use ieee.std_logic_1164.all;
entity seq_rec is
   port(
		KEY: in std_logic_vector(1 downto 0);
		SW: in std_logic_vector(0 downto 0);
      HEX0: out std_logic_vector(6 downto 0);
		HEX1: out std_logic_vector(6 downto 0);
		HEX2: out std_logic_vector(6 downto 0);
		HEX3: out std_logic_vector(6 downto 0);
		HEX5: out std_logic_vector(6 downto 0)
	);
end seq_rec;


architecture process_3 of seq_rec is
   type state_type is (A, B, C, D);
   signal state, next_state : state_type;
begin

-- Process 1 - state_register: implements positive edge-triggered
-- state storage with asynchronous reset. 
   state_register: process (KEY(0), KEY(1))
   begin
     if (KEY(1)='0') then
        state <= A;
     else
        if (rising_edge(KEY(0))) then
           state <= next_state;
        end if;
     end if;
end process;

-- Process 2 - next_state_function: implements next state as function
-- of input X and state. 
   next_state_func: process (SW, state)
   begin
      case state is
         when A =>
	   if SW(0) = '1' then
	      next_state <= B;
	   else
	      next_state <= A;
           end if;
        when B =>
	   if SW(0) = '1' then
	      next_state <= C;
	   else
	      next_state <= A;
           end if;
        when C =>
	   if SW(0) = '1' then
	      next_state <= C;
	   else
	      next_state <= D;
           end if;
        when D =>
	   if SW(0) = '1' then
	      next_state <= B;
	   else
	      next_state <= A;
           end if;
      end case;
   end process;

-- Process 3 - output_function: implements output as function
-- of input X and state. 
   output_func: process (SW, state)
   begin
      case state is
            when A =>
                HEX5 <= "0001000"; --A
                HEX0 <= "1000000";--0
                HEX1 <= "1111111"; 
                HEX2 <= "1111111"; 
                HEX3 <= "1111111"; 
         
            when B =>
                HEX5 <= "0000011"; --b
                HEX0 <= "1000000";--0
                HEX1 <= "1111111";
                HEX2 <= "1111111";
                HEX3 <= "1111111";

            when C =>
                HEX5 <= "1000110"; --c
                HEX0 <= "1000000";--0
                HEX1 <= "1111111";
                HEX2 <= "1111111";
                HEX3 <= "1111111";
    
            when D =>
                HEX5 <= "0100001"; --d
                HEX0 <= "1000000";--0
                HEX1 <= "1111111";
                HEX2 <= "1111111";
                HEX3 <= "1111111";
                if SW(0) = '1' then
                    HEX0 <= "1111001"; --se receber o numero 1 enquanto esta em d, retorna 1.
                end if;
      end case;
   end process;
end;
