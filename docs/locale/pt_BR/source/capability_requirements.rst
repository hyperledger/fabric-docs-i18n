Definindo requisitos de recursos
================================

Conforme discutido em :doc:`capabilities_concept`, os requisitos de recurso são definidos pelo canal na configuração do canal (encontrado
no bloco de configuração mais recente do canal). A configuração do canal contém três locais, cada um dos quais define um recurso de um
tipo diferente.

+------------------+-----------------------------------+----------------------------------------------------+
| Tipo Recurso     | Path Padrão                       | Path JSON                                          |
+==================+===================================+====================================================+
| Channel          | /Channel/Capabilities             | .channel_group.values.Capabilities                 |
+------------------+-----------------------------------+----------------------------------------------------+
| Orderer          | /Channel/Orderer/Capabilities     | .channel_group.groups.Orderer.values.Capabilities  |
+------------------+-----------------------------------+----------------------------------------------------+
| Application      | /Channel/Application/Capabilities | .channel_group.groups.Application.values.          |
|                  |                                   | Capabilities                                       |
+------------------+-----------------------------------+----------------------------------------------------+

.. _setting-capabilities:

Configurando recursos
---------------------

Os recursos são definidos como parte da configuração do canal (como parte da configuração inicial --- sobre a qual falaremos daqui a
pouco --- ou como parte de uma reconfiguração).

.. note :: Para mais informações sobre como atualizar uma configuração de canal, consulte :doc:`config_update`.

Como novos canais copiam por padrão a configuração do canal do sistema de ordens, novos canais serão configurados automaticamente para
funcionar com os recursos de ordens e os recursos de aplicativo especificados pela transação de criação de canais.

.. _capabilities-in-an-initial-configuration:

Recursos em uma configuração inicial
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

No arquivo ``configtx.yaml`` distribuído no diretório ``config`` dos artefatos da release, há uma seção ``Capabilities`` que enumera os
recursos possíveis para cada tipo de recurso (Channel, Orderer e Application).

Observe que há uma seção ``Capabilities`` definida no nível raiz (para os recursos do canal) e no nível Ordenador (para recursos do
ordenador).

Ao definir o canal do sistema do ordenador, não há uma seção Aplicativo, pois esses recursos são definidos durante a criação de um canal de
aplicativo.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/