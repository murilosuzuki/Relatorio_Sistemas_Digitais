-- Reconhecedor de Sequência "1101" - Máquina de Moore
library ieee;
use ieee.std_logic_1164.all;

entity seq_rec_moore is
    port(CLK, RESET, X: in std_logic;
         Z: out std_logic);
end seq_rec_moore;

architecture moore_arch of seq_rec_moore is
    -- Adicionamos um novo estado 'E' para a saída da detecção
    type state_type is (A, B, C, D, E); 
    signal state, next_state: state_type;

begin

    -- Processo 1 - Registrador de Estado (Permanece igual)
    -- Armazena o estado atual, é sensível ao clock e ao reset.
    state_register: process (CLK, RESET)
    begin
        if (RESET = '1') then
            state <= A;
        elsif (CLK'event and CLK = '1') then
            state <= next_state;
        end if;
    end process;

    -- Processo 2 - Lógica de Próximo Estado (Lógica de transição modificada)
    -- Define as transições entre os estados com base no estado atual e na entrada X.
    next_state_func: process (X, state)
    begin
        case state is
            when A => -- Estado inicial
                if X = '1' then
                    next_state <= B;
                else
                    next_state <= A;
                end if;

            when B => -- Sequência "1" recebida
                if X = '1' then
                    next_state <= C;
                else
                    next_state <= A;
                end if;

            when C => -- Sequência "11" recebida
                if X = '1' then
                    next_state <= C; -- Permanece aqui se vier outro '1' (...111)
                else
                    next_state <= D;
                end if;

            when D => -- Sequência "110" recebida
                if X = '1' then
                    next_state <= E; -- Transição para o estado de SUCESSO!
                else
                    next_state <= A;
                end if;

            when E => -- Estado de SUCESSO ("1101" foi recebido)
                if X = '1' then
                    -- A sequência era ...1101, e agora chegou outro 1 (...11011).
                    -- Os últimos dois '1's correspondem ao estado C.
                    next_state <= C; 
                else
                    -- A sequência era ...1101, e agora chegou um 0 (...11010).
                    -- Nenhum trecho corresponde, então volta ao início.
                    next_state <= A;
                end if;
        end case;
    end process;

    -- Processo 3 - Lógica de Saída (AGORA É MOORE!)
    -- A saída Z depende APENAS do estado atual.
    output_func: process (state)
    begin
        case state is
            when A =>
                Z <= '0';
            when B =>
                Z <= '0';
            when C =>
                Z <= '0';
            when D =>
                Z <= '0';
            when E => -- A saída é '1' APENAS no estado E.
                Z <= '1';
        end case;
    end process;

end moore_arch;
