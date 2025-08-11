library ieee;
use ieee.std_logic_1164.all;

entity seq_rec_testbench is
end seq_rec_testbench;

architecture tb_arch of seq_rec_testbench is

    -- Sinais para conectar ao Reconhecedor de Sequência
    signal tb_CLK   : std_logic := '0'; -- Inicializa CLK em '0'
    signal tb_RESET : std_logic := '1'; -- Inicializa RESET ativo para o pulso inicial
    signal tb_X     : std_logic := '0';
    signal tb_Z     : std_logic;

    -- Constante para definir o período do clock (ex: 100 ns -> 5 MHz)
    constant CLK_PERIOD : time := 100 ns;

begin

    -- Instancia o circuito sob teste (UUT - Unit Under Test)
    -- O nome da entidade é 'seq_rec' e a arquitetura é 'process_3'
    uut: entity work.seq_rec(process_3)
        port map(
            CLK   => tb_CLK,
            RESET => tb_RESET,
            X     => tb_X,
            Z     => tb_Z
        );

    -- Gerador de Clock
    -- Este processo gera um sinal de clock contínuo
    clock_generator: process
    begin
        loop
            tb_CLK <= '0';
            wait for CLK_PERIOD / 2; -- Metade do período (50 ns para um período de 100 ns)
            tb_CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Gerador de Vetores de Teste (Entradas e Reset)
    -- Este processo aplica os estímulos ao UUT
    stimulus_generator: process
    begin
        -- 1. Pulso de RESET inicial
        tb_RESET <= '1';    -- Ativa o reset
        tb_X <= '0';        -- Mantém X em '0' durante o reset
        wait for CLK_PERIOD * 2; -- Espera 2 ciclos de clock com reset ativo

        tb_RESET <= '0';    -- Desativa o reset
        wait for CLK_PERIOD; -- Espera 1 ciclo de clock para a máquina estabilizar após o reset

        -- 2. Testando a sequência "1101"
        -- Sequência: ...1101...
        -- Tempo | CLK | X | Esperado Z
        -- ---------------------------
        -- 0     | rising edge |   |
        -- 100   | rising edge | 1 | 0 (Estado B)
        tb_X <= '1';
        wait for CLK_PERIOD;

        -- 200   | rising edge | 1 | 0 (Estado C)
        tb_X <= '1';
        wait for CLK_PERIOD;

        -- 300   | rising edge | 0 | 0 (Estado D)
        tb_X <= '0';
        wait for CLK_PERIOD;

        -- 400   | rising edge | 1 | 1 (Estado B - Saída '1' por ser Mealy, depois transita)
        tb_X <= '1';
        wait for CLK_PERIOD; -- AQUI Z DEVE SER '1' POR UM CICLO!

        -- 500   | rising edge | 0 | 0 (Estado A)
        tb_X <= '0';
        wait for CLK_PERIOD;

        -- 600   | rising edge | 0 | 0 (Estado A)
        tb_X <= '0';
        wait for CLK_PERIOD;

        -- 3. Outra sequência "1101" com ruído
        -- Sequência: ...011010...
        -- Tempo | CLK | X | Esperado Z
        -- ---------------------------
        -- 700   | rising edge | 0 | 0 (Estado A)
        tb_X <= '0';
        wait for CLK_PERIOD;

        -- 800   | rising edge | 1 | 0 (Estado B)
        tb_X <= '1';
        wait for CLK_PERIOD;

        -- 900   | rising edge | 1 | 0 (Estado C)
        tb_X <= '1';
        wait for CLK_PERIOD;

        -- 1000  | rising edge | 0 | 0 (Estado D)
        tb_X <= '0';
        wait for CLK_PERIOD;

        -- 1100  | rising edge | 1 | 1 (Estado B - Saída '1')
        tb_X <= '1';
        wait for CLK_PERIOD; -- AQUI Z DEVE SER '1' POR UM CICLO!

        -- 1200  | rising edge | 0 | 0 (Estado A)
        tb_X <= '0';
        wait for CLK_PERIOD;

        -- Finaliza a simulação após os vetores de teste
        wait; -- Mantém o processo parado indefinidamente
    end process;

end tb_arch;
