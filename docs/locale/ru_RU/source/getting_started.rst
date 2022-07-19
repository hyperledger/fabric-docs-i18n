Приступая к работе
==================

.. toctree::
   :maxdepth: 1
   :hidden:

   prereqs
   install
   test_network

Прежде чем начать, если вы этого еще не сделали - убедитесь,
что у вас установлены все :doc:`prereqs` для платформ, на которых вы будете
вести разработку блокчейн-приложений или запускать Hyperledger Fabric.

Если необходимые инструменты установлены, тогда вы можете загрузить и установить
HyperLedger Fabric. Пока мы еще не сделали настоящий установщик Fabric,
воспользуйтесь скриптом (:doc:`install`), который проведет установку на вашу систему.
Этот же скрипт загрузит и образы Docker в ваш локальный реестр.

Как только загрузите на локальную машину примеры Fabric и образы Docker,
можете начать работу с Fabric и руководством :doc:`test_network`.

Интерфейсы приложений (API) для смарт-контрактов (чейнкода) Hyperledger Fabric
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

В Hyperledger Fabric заложен ряд интерфейсов (API) для поддержки смарт-контрактов (чейнкода) на
разных языках программирования. Интерфейсы для смарт-контрактов доступны для языков Go, Node.js, and Java:

  * `Go API смарт-контрактов <https://github.com/hyperledger/fabric-contract-api-go>`__.
  * `Node.js API смарт-контрактов <https://github.com/hyperledger/fabric-chaincode-node>`__ и `документация по Node.js API <https://hyperledger.github.io/fabric-chaincode-node/>`__.
  * `Java API смарт-контрактов <https://github.com/hyperledger/fabric-chaincode-java>`__ и  `документация по Java API <https://hyperledger.github.io/fabric-chaincode-java/>`__.

Наборы средств разработчика (SDK) приложений для Hyperledger Fabric
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

В Hyperledger Fabric предлагается ряд пакетов средств разработчика (SDK), поддерживающих
разработку приложений на различных языках программирования. Пакеты (SDK) есть для Node.js и Java:

  * `Node.js SDK <https://github.com/hyperledger/fabric-sdk-node>`__ и `документация по Node.js SDK  <https://hyperledger.github.io/fabric-sdk-node/>`__.
  * `Java SDK <https://github.com/hyperledger/fabric-gateway-java>`__ и `документация по Java SDK <https://hyperledger.github.io/fabric-gateway-java/>`__.

  Список необходимых требований для начала разработки с SDK для Node.js SDK находится здесь: `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__, а для Java SDK
  находится здесь: `README <https://github.com/hyperledger/fabric-gateway-java/blob/master/README.md>`__.

Кроме того, есть еще два еще не выпущенных официально пакета средств разработчика
(для Python и Go), но все же их уже можно скачать для тестирования:

  * `Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.

В настоящее время Node.js, Java и Go поддерживают новую модель программирования приложений, заложенную в Hyperledger Fabric v1.4.

Удостоверяющие центры Hyperledger Fabric
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric предоставляет для использования
`сервис удостоверяющего центра <http://hyperledger-fabric-ca.readthedocs.io/en/latest>`_,
который вы можете использовать для генерирования сертификатов и ключей для того, чтобы
определять конфигурацию и управлять идентификаторами вашей блокчейн-сети. В то же время это
не обязательно - вы можете использовать и любой другой удостоверяющий центр, способный
генерировать ECDSA-сертификаты.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
