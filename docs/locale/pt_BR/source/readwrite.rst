Semântica de conjuntos de leitura e gravação
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Este documento discute os detalhes da implementação atual sobre a semântica de conjuntos de leitura e gravação.

.. transaction-simulation-and-read-write-set:

Simulação de transação e conjunto de leitura e gravação
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

Durante a simulação de uma transação em um ``endossante``, um conjunto de leitura e gravação é preparado para a transação. O 
``conjunto de leitura`` contém uma lista de chaves exclusivas e seus números de versão confirmados (mas não valores) que a transação lê 
durante a simulação. O ``conjunto de gravação`` contém uma lista de chaves exclusivas (embora possa haver sobreposição com as chaves 
presentes no conjunto de leitura) e seus novos valores que a transação grava. Um marcador de exclusão é definido (no lugar de novo valor) 
para a chave se a atualização realizada pela transação for excluir a chave.

Além disso, se a transação gravar um valor várias vezes para uma chave, apenas o último valor gravado será retido. Além disso, se uma 
transação ler um valor para uma chave, o valor no estado confirmado será retornado, mesmo que a transação tenha atualizado o valor da chave 
antes de emitir a leitura. Em outras palavras, a semântica de leitura e gravação não é suportada.

Como observado anteriormente, as versões das chaves são gravadas apenas no conjunto de leitura, o conjunto de gravação contém apenas a lista 
de chaves exclusivas e seus valores mais recentes definidos pela transação.

Pode haver vários esquemas para implementar versões. O requisito mínimo para um esquema de versão é produzir identificadores não repetitivos 
para uma determinada chave. Por exemplo, o uso de números crescentes monotonicamente para versões pode ser um desses esquemas. Na 
implementação atual, usamos um esquema de versão baseado em altura da blockchain no qual a altura da transação de confirmação é usada como a 
versão mais recente para todas as chaves modificadas pela transação. Nesse esquema, a altura de uma transação é representada por uma tupla 
(txNumber é a altura da transação dentro do bloco). Esse esquema tem muitas vantagens sobre o esquema numérico incremental - principalmente, 
ele permite que outros componentes, como o banco de dados de estado, simulação de transação e validação, façam escolhas eficientes de design.

A seguir, é apresentada uma ilustração de um conjunto de leitura e gravação de exemplo preparado pela simulação de uma transação hipotética. 
Por uma questão de simplicidade, nas ilustrações, usamos os números incrementais para representar as versões.

::

    <TxReadWriteSet>
      <NsReadWriteSet name="chaincode1">
        <read-set>
          <read key="K1", version="1">
          <read key="K2", version="1">
        </read-set>
        <write-set>
          <write key="K1", value="V1">
          <write key="K3", value="V2">
          <write key="K4", isDelete="true">
        </write-set>
      </NsReadWriteSet>
    <TxReadWriteSet>

Além disso, se a transação executar uma consulta de intervalo durante a simulação, a consulta de intervalo e seus resultados serão 
adicionados ao conjunto de leitura e gravação como ``query-info``.

.. transaction-validation-and-updating-world-state-using-read-write-set:

Validação de transação e atualização do estado mundial usando o conjunto de leitura e gravação
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Um ``confirmador`` usa a parte do conjunto de leitura, dos conjuntos de leitura e gravação, para verificar a validade de uma transação e a 
parte do conjunto de gravação, dos conjuntos de leitura e gravação para atualizar as versões e os valores das chaves afetadas.

Na fase de validação, uma transação é considerada ``válida`` se a versão de cada chave presente no conjunto de leitura da transação 
corresponder à versão da mesma chave no estado global - assumindo a confirmação de todas as transações anteriores ``válidas`` (*estado 
confirmado*) (incluindo as transações anteriores no mesmo bloco) . Uma validação adicional será executada se os conjuntos de leitura e 
gravação também contiver uma ou mais informações de consulta.

Essa validação adicional deve garantir que nenhuma chave tenha sido inserida/excluída/atualizada no intervalo (ou seja, união dos intervalos) 
dos resultados capturados nas informações da consulta. Em outras palavras, se reexecutarmos alguma das consultas de intervalo (que a 
transação executou durante a simulação) durante a validação no estado confirmado, ela deverá produzir os mesmos resultados que foram 
observados pela transação no momento da simulação. Essa verificação garante que, se uma transação observar itens fantasmas durante a 
confirmação, a transação deverá ser marcada como inválida. Observe que essa proteção fantasma é limitada a consultas de intervalo (ou seja, 
a função ``GetStateByRange`` no chaincode) e ainda não foi implementada para outras consultas (ou seja, a função ``GetQueryResult`` no 
chaincode). Outras consultas correm risco de fantasmas e, portanto, devem ser usadas apenas em transações somente leitura que não são 
submetidas a ordens, a menos que o aplicativo possa garantir a estabilidade do conjunto de resultados entre a simulação e o tempo de 
validação/confirmação.

Se uma transação passa na verificação de validade, o emissor usa o conjunto de gravação para atualizar o estado global. Na fase de 
atualização, para cada chave presente no conjunto de gravação, o valor no estado global da mesma chave é definido como o valor especificado 
no conjunto de gravação. Além disso, a versão da chave no estado global é alterada para refletir a versão mais recente.

.. example-simulation-and-validation:

Exemplo de simulação e validação
''''''''''''''''''''''''''''''''

Esta seção ajuda a entender a semântica através de um cenário de exemplo. Para os fins deste exemplo, a presença de uma chave, ``k``, no 
estado global é representada por uma tupla ``(k, ver, val)`` onde ``ver`` é a versão mais recente da chave ``k`` tendo ``val`` como valor.

Agora, considere um conjunto de cinco transações ``T1, T2, T3, T4 e T5``, todas simuladas no mesmo instantâneo do estado global. O trecho a 
seguir mostra a captura instantânea do estado global em relação ao qual as transações são simuladas e a sequência de atividades de leitura e 
gravação executadas por cada uma dessas transações.

::

    World state: (k1,1,v1), (k2,1,v2), (k3,1,v3), (k4,1,v4), (k5,1,v5)
    T1 -> Write(k1, v1'), Write(k2, v2')
    T2 -> Read(k1), Write(k3, v3')
    T3 -> Write(k2, v2'')
    T4 -> Write(k2, v2'''), read(k2)
    T5 -> Write(k6, v6'), read(k5)

Agora, suponha que essas transações sejam ordenadas na sequência de T1, .., T5 (podem estar contidas em um único bloco ou em blocos 
diferentes)

1. ``T1`` passa na validação porque não realiza nenhuma leitura. 
   Além disso, a tupla de chaves ``k1`` e ``k2`` no estado global é atualizada para ``(k1,2,v1'), (k2,2,v2')``.

2. ``T2`` falha na validação porque lê uma chave, ``k1``, que foi modificada por uma transação anterior - ``T1``.

3. ``T3`` passa na validação porque não realiza uma leitura. 
   Além disso, a tupla da chave, ``k2``, no estado global é atualizada para ``(k2,3,v2'')``.

4. ``T4`` falha na validação porque lê uma chave, ``k2``, que foi modificada por uma transação anterior ``T1``.

5. ``T5`` passa na validação porque lê uma chave, ``k5``, que não foi modificada por nenhuma das transações anteriores.

**Nota**: transações com vários conjuntos de leitura e gravação ainda não são suportadas.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
