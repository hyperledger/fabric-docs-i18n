Instale exemplos, executáveis e imagens Docker
============================================

Enquanto trabalhamos no desenvolvimento de instaladores de verdade para os executáveis 
do Hyperledger Fabric, fornecemos um script que irá baixar e instalar exemplos e
executáveis para o seu sistema. Pensamos que você irá achar as aplicações de exemplo
instaladas úteis para aprender mais sobre os recursos e operações do
Hyperledger Fabric. 


.. note:: Se você estiver executando no **Windows**, você vai querer usar o
          Docker Quickstart Terminal para os próximos comandos de terminal.
          Visite o :doc:`prereqs` se você não instalou anteriormente isto.

          Se você estiver usando o Docker Toolbox ou macOS, você
           precisará usar um local em ``/Users`` (macOS) para instalar e executar os exemplos.

           Se você estiver usando o Docker para Mac, você precisará usar um local
           em ``/Users``, ``/Volumes``, ``/private`` ou ``/tmp``. Para usar uma localização
           diferente, consulte a documentação do Docker sobre
          `compartilhamento de arquivos <https://docs.docker.com/docker-for-mac/#file-sharing>`__.

          Se você estiver usando o Docker para Windows, consulte a documentação do Docker
            para `drives compartilhados <https://docs.docker.com/docker-for-windows/#shared-drives>`__
           e use um local em um dos drives compartilhados.

Determine um local em sua máquina onde você deseja colocar o repositório 
`fabric-samples` e entre nesse diretório em uma janela de terminal. O comando 
a seguir executará as seguintes etapas:

#. Se preciso, clona o repositório `hyperledger/fabric-samples <https://github.com/hyperledger/fabric-samples>`_ 
#. Faz o checkout da tag na versão apropriada
#. Instala os executáveis e arquivos de configuração do Hyperledger Fabric específicos da sua plataforma, 
    para a versão especificada, nos diretórios /bin e /config do fabric-samples
#. Baixa as imagens docker do Hyperledger Fabric para a versão especificada

Assim que você estiver pronto, e no diretório em que irá instalar os exemplos e executáveis do Fabric, 
vá em frente e execute o comando para baixar os binários e as imagens.

.. note:: Se você quiser a versão de produção mais recente, omita todos os identificadores de versão.

.. code:: bash

  curl -sSL https://bit.ly/2ysbOFE | bash -s

.. note:: Se deseja uma versão específica, passe um identificador de versão para as imagens Docker do Fabric e do Fabric-CA.
          O comando abaixo demonstra como baixar os últimos lançamentos de produção -
          **Fabric v2.2.3** e **Fabric CA v1.5.0**

.. code:: bash

  curl -sSL https://bit.ly/2ysbOFE | bash -s -- <fabric_version> <fabric-ca_version>
  curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.3 1.5.0

.. note:: Se você receber um erro ao executar o comando curl acima, você pode
          ter uma versão muito antiga do curl que não suporta
          redirecionamentos ou um ambiente não suportado.

          Visite a página :doc:`prereqs` para informações adicionais
          sobre onde encontrar a versão mais recente do curl e
          obtenha o ambiente certo. Alternativamente, você pode substituir
          pela URL não encurtada:
          https://raw.githubusercontent.com/hyperledger/fabric/{BRANCH}/scripts/bootstrap.sh

.. note:: Para um padrão de uso adicional, você pode usar a flag -h para visualizar a ajuda e os comandos disponíveis para o
          script de inicialização do Fabric-Samples. Por exemplo:
          ``curl -sSL https://bit.ly/2ysbOFE | bash -s -- -h``

O comando acima baixa e executa um script bash
que irá baixar e extrair todos os executáveis específicos da sua plataforma, que você
precisará para configurar sua rede, e irá colocá-los no repositório clonado que você
criou anteriormente. Ele obtém os seguintes executáveis específicos da sua plataforma:

  * ``configtxgen``,
  * ``configtxlator``,
  * ``cryptogen``,
  * ``discover``,
  * ``idemixgen``
  * ``orderer``,
  * ``peer``,
  * ``fabric-ca-client``,
  * ``fabric-ca-server``

e os coloca no subdiretório ``bin`` do diretório de trabalho atual.

Você pode querer adicionar isso à sua variável de ambiente PATH para que eles
possam ser alcançados sem precisar colocar todo o caminho para cada executável. Ex.:

.. code:: bash

  export PATH=<caminho para o local de download>/bin:$PATH

Por fim, o script fará o download das imagens docker do Hyperledger Fabric do
`Docker Hub <https://hub.docker.com/u/hyperledger/>`__ para
dentro do seu registro Docker local e irá marcá-las como 'latest'.

O script lista as imagens Docker instaladas após a conclusão.

Observe os nomes de cada imagem; estes são os componentes que irão 
por fim compor nossa rede Hyperledger Fabric. Você também notará que terá
duas instâncias do mesmo ID de imagem - uma marcada como "amd64-1.x.x" e
uma marcada como "latest". Antes da 1.2.0, a imagem que estava sendo 
baixada era determinada pelo ``uname -m`` e mostrada como "x86_64-1.x.x".

.. note:: Em arquiteturas diferentes, o x86_64/amd64 seria substituído
          com a string identificando sua arquitetura.

.. note:: Se você tiver dúvidas não abordadas por esta documentação, ou se deparar com
          problemas com qualquer um dos tutoriais, visite a página :doc:`questions`
          para obter algumas dicas sobre onde encontrar ajuda adicional.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/