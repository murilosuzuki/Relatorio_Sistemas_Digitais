-- Testbench completo para o Reconhecedor de Sequência Moore
library ieee;
use ieee.std_logic_1164.all;

-- A ENTITY define a "caixa preta" do testbench (geralmente vazia)
entity seq_rec_moore_tb is
end seq_rec_moore_tb;

-- A ARCHITECTURE contém toda a lógica e os processos internos
architecture tb_arch of seq_rec_moore_tb is

    -- Sinais para conectar ao Reconhecedor de Sequência Moore
    signal tb_CLK   : std_logic := '0';
    signal tb_RESET : std_logic := '1';
    signal tb_X     : std_logic := '0';
    signal tb_Z     : std_logic;

    -- Constante para definir o período do clock
    constant CLK_PERIOD : time := 100 ns;

begin -- Início do corpo da arquitetura

    -- Instancia o circuito sob teste (UUT - Unit Under Test)
    uut: entity work.seq_rec_moore(moore_arch)
        port map(
            CLK   => tb_CLK,
            RESET => tb_RESET,
            X     => tb_X,
            Z     => tb_Z
        );

    -- Processo 1: Gerador de Clock
    clock_generator: process
    begin
        loop
            tb_CLK <= '0';
            wait for CLK_PERIOD / 2;
            tb_CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Processo 2: Gerador de Estímulos (o seu código, agora no lugar certo)
    stimulus_generator: process
    begin
        -- 1. Pulso de RESET inicial
        tb_RESET <= '1';
        tb_X <= '0';
        wait for CLK_PERIOD * 2;
        tb_RESET <= '0';
        wait for CLK_PERIOD;

        -- 2. Testando a sequência "1101"
        tb_X <= '1';
        wait for CLK_PERIOD;
        assert (tb_Z = '0') report "Falha: Z deveria ser 0 no estado B" severity error;

        tb_X <= '1';
        wait for CLK_PERIOD;
        assert (tb_Z = '0') report "Falha: Z deveria ser 0 no estado C" severity error;

        tb_X <= '0';
        wait for CLK_PERIOD;
        assert (tb_Z = '0') report "Falha: Z deveria ser 0 no estado D" severity error;

        tb_X <= '1';
        wait for CLK_PERIOD;
        assert (tb_Z = '0') report "Falha: Z ainda deveria ser 0 ao entrar em E" severity error;
        
        -- AGORA SIM: A máquina está no estado E. A saída Z deve ser '1'.
        tb_X <= '0'; 
        wait for 1 ns;
        assert (tb_Z = '1') report "FALHA NA DETECCAO: Z deveria ser '1' no estado E" severity error;
        wait for CLK_PERIOD - 1 ns;

        wait for CLK_PERIOD;

        -- 3. Sequência de teste para garantir a robustez
        tb_X <= '1'; wait for CLK_PERIOD; -- Estado B
        tb_X <= '1'; wait for CLK_PERIOD; -- Estado C
        tb_X <= '1'; wait for CLK_PERIOD; -- Estado C
        tb_X <= '0'; wait for CLK_PERIOD; -- Estado D
        tb_X <= '1'; wait for CLK_PERIOD; -- Entra em E, Z ainda '0'
        
        -- Próximo ciclo, Z deve ser '1'
        tb_X <= '1';
        wait for 1 ns;
        assert (tb_Z = '1') report "FALHA NA DETECCAO 2: Z deveria ser '1' no estado E" severity error;
        wait for CLK_PERIOD - 1 ns;

        -- Finaliza a simulação após os vetores de teste
        report "Simulacao do Testbench MOORE concluida!" severity note;
        wait;
    end process;

end tb_arch; -- Fim da arquitetura
