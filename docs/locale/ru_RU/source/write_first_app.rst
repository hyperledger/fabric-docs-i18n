Запуск приложений Fabric
########################
.. note:: Если вы еще не очень хорошо знакомы с основами архитектуры сети Fabric, то, до того, как изучать этот раздел,
          вам может быть полезным сначала ознакомиться с разделом :doc:`key_concepts`.

          Вы также должны быть знакомы с шлюзом Fabric (службой Fabric Gateway) и его ролью в исполнении транзакций
          приложения. Этой службе посвящен раздел :doc:`gateway`.

В этом руководстве показано, как приложения Fabric взаимодействуют с развернутыми блокчейн-сетями. В руководстве
используются примеры программ, созданные с помощью клиентского API шлюза Fabric для вызова умных контрактов, которые
запрашивают и обновляют данные в реестре, используя API умных контрактов, описанный в разделе :doc:`deploy_chaincode`.

**Пример Asset Transfer**

Пример Asset Transfer (basic) демонстрирует, как создавать, обновлять и запрашивать активы. Он включает следующие два
компонента:

  1. **Пример приложения**, которое обращается к блокчейн-сети, выполняя транзакции, реализованные в умном контракте.
  Приложение расположено в следующем каталоге проекта ``fabric-samples``:

  .. code-block:: text

    asset-transfer-basic/application-gateway-typescript

  2. **Умный контракт**, который реализует транзакции, взаимодействующие с реестром. Умный контракт расположен в
  следующем каталоге проекта ``fabric-samples``:

  .. code-block:: text

    asset-transfer-basic/chaincode-(typescript, go, java)

В этом примере мы будем использовать умный контракт, реализованный на языке TypeScript.

Данное руководство состоит из двух основных частей:

  1. **Настройка блокчейн-сети.**
  Нашему приложению нужна сеть блокчейн, с которой оно будет взаимодействовать. Поэтому мы запустим базовую сеть и
  развернем в ней умный контракт для нашего приложения.

  .. image:: images/AppConceptsOverview.png

  2. **Запуск приложения из примера для взаимодействия с умным контактом.**
  Наше приложение будет использовать умный контракт assetTransfer для создания, запроса и обновления активов в реестре.
  Мы рассмотрим код приложения и транзакций, которые оно вызывает, включая создание начальных активов, запрос актива,
  запрос группы активов, создание нового актива и передачу актива новому владельцу.

После прохождения данного руководства вы должны получить начальное представление о том, как приложения Fabric и умные
контракты работают вместе для управления данными в распределенном реестре сети блокчейн.


Предисловие
===========
Перед тем как запустил приложение из примера, вам необходимо установить примеры Fabric в вашем окружении. Следуйте
инструкциям из статьи :doc:`getting_started` для установки необходимого программного обеспечения.
Пример приложения в этом руководстве используется клиентский API шлюза Fabric для Node. Актуальный список поддерживаемых
языков программирования и зависимостей смотрите в `документации шлюза Fabric <https://hyperledger.github.io/fabric-gateway/>`_.

- Убедитесь, что у вас установлена подходящая версия Node. Инструкции по установке Node можно найти в
  `документации Node.js <https://nodejs.dev/learn/how-to-install-nodejs>`_.


Настройка сети блокчейн
=======================
Если вы уже проходили шаги руководства :doc:`test_network` и запустили сеть, то при прохождении шагов данного
руководства она будет остановлена. Затем будет запущена новая сеть, в которой будет пустой реестр.


Запуск сети блокчейн
--------------------
Перейдите в подкаталог ``test-network`` вашей локальной копии репозитория ``fabric-samples``.

.. code-block:: bash

  cd fabric-samples/test-network

Если тестовая сеть уже запущена, остановите ее, чтобы очистить окружение.

.. code-block:: bash

  ./network.sh down

Запустите тестовую сеть Fabric с помощью сценария ``network.sh``.

.. code-block:: bash

  ./network.sh up createChannel -c mychannel -ca

Эта команда запустит тестовую сеть, состоящую из двух одноранговых узлов, службы упорядочения и трех удостоверяющих
центров (Orderer, Org1 и Org2). Вместо использования инструмента cryptogen мы запускаем удостоверяющие центры в сети, на
что указывает флаг ``-ca`` в команде выше. Дополнительно при старте удостоверяющих центров выполняется регистрация
администраторов организаций.


Развертывание умного контракта
------------------------------
.. note:: Это руководство демонстрирует работу умного контракта и приложения из примера Asset Transfer, написанных на
          языке TypeScript, но вы можете использовать умный контракт, написанный на любом языке программирования, вместе
          с приложением на TypeScript (например, вызывать из приложения на TypeScript функции умного контракта,
          написанного на Go или Java). Чтобы использовать версии умного контракта на Go или Java, замените аргумент
          ``typescript`` в команде ``./network.sh deployCC -ccl typescript`` на ``go`` или ``java`` и следуйте
          инструкциям, которые будут печататься в терминале.

Далее давайте развернем пакет чейнкода, содержащий умный контракт, вызовом сценария ``./network.sh`` с указанием имени
чейнкода и языка, на котором он написан.

.. code-block:: bash

  ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript/ -ccl typescript

Этот сценарий использует команды жизненного цикла чейнкода для упаковки, установки, запроса установленных чейнкодов,
одобрения чейнкода обеими организациями Org1 и Org2, а также финальной записи определения чейнкода.

Если пакет чейнкода будет успешно развернут, в вашем терминале должно появиться примерно следующее:

.. code-block:: text

  Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
  Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
  Query chaincode definition successful on peer0.org2 on channel 'mychannel'
  Chaincode initialization is not required


Подготовка примера приложения
-----------------------------
Теперь давайте подготовим `приложение на TypeScript <https://github.com/hyperledger/fabric-samples/tree/main/asset-transfer-basic/application-gateway-typescript>`_
Asset Transfer, которое будет взаимодействовать с развернутым умным контрактом.

Откройте терминал и перейдите в каталог ``application-gateway-typescript``.

.. code-block:: bash

  cd asset-transfer-basic/application-gateway-typescript

В этом каталоге находится пример приложения, разработанного с использованием клиентского API шлюза Fabric для Node.

Для установки зависимостей и сборки приложения выполните следующую команду. Ее выполнение займет некоторое время.

.. code-block:: bash

  npm install

Зависимости, которые будут установлены, определены в файле ``package.json``. Наиболее важная из них - пакет для Node.js
``@hyperledger/fabric-gateway``; она обеспечивает соединение со шлюзом Fabric через его клиентский API, а также,
используя учетные данные клиента, отправку транзакций, чтение результата их выполнения и получение событий.

После завершения команды ``npm install`` все готово к запуску приложения.

Давайте посмотрим на файлы примера приложения на TypeScript, которое используется в этом руководстве. Выполните
следующую команду для вывода списка файлов каталога на экран:


.. code-block:: bash

  ls

Вы должны увидеть следующее:

.. code-block:: text

  dist
  node_modules
  package-lock.json
  package.json
  src
  tsconfig.json

Каталог ``src`` содержит исходный код клиентского приложения. Файлы JavaScript, сгенерированные из этого исходного
кода в процессе сборки, расположены в каталоге ``dist`` и могут быть игнорированы.


Запуск примера приложения
=========================
Когда мы запускали тестовую сеть Fabric чуть ранее в этом руководстве, с помощью удостоверяющих центров были созданы
учетные данные нескольких пользователей. Они включают идентификаторы пользователей для каждой организации. Приложение
будет использовать учетные данные одного из пользователей для выполнения транзакций в сети блокчейн.

Давайте запустим приложение и посмотрим на взаимодействие с каждой из функций умного контракта. В каталоге
``asset-transfer-basic/application-gateway-typescript`` выполните следующую команду:

.. code-block:: bash

  npm start


Шаг 1: установление соединения gRPC с шлюзом
--------------------------------------------
Клиентское приложение устанавливает соединение `gRPC <https://grpc.io/>`_ с шлюзом Fabric и использует его для
взаимодействия с сетью блокчейн. Для установки соединения требуется только адрес конечной точки шлюза Fabric и, если
используется TLS, соответствующие TLS сертификаты. В нашем примере адрес конечной точки шлюза совпадает с адресом
однорангового узла, на котором он работает.

.. note:: Установление соединений gRPC требует значительных накладных расходов, поэтому установленное соединение должно
          быть сохранено приложением и использовано при всех взаимодействиях с шлюзом.

.. warning:: Для обеспечения безопасности любых приватных данных, используемых в транзакциях, приложение должно
             подключаться к шлюзу Fabric той же организации, к которой относятся учетные данные клиента. Если в
             организации нет шлюзов, то следует использовать доверенный шлюз в другой организации.

Приложение, написанное на TypeScript, создает соединение gRPC, используя сертификат TLS удостоверяющего центра, чтобы
можно было проверить подлинность сертификата TLS шлюза.

Чтобы соединение TLS было успешно установлено, адрес конечной точки, используемый клиентом, должен совпадать с адресом
в сертификате TLS шлюза. Поскольку клиент обращается к Docker-контейнеру шлюза по адресу ``localhost``, настройка gRPC
указывает, что адрес конечной точки должен интерпретироваться как сконфигурированное имя узла шлюза.

.. code-block:: TypeScript

  const peerEndpoint = 'localhost:7051';

  async function newGrpcConnection(): Promise<grpc.Client> {
      const tlsRootCert = await fs.readFile(tlsCertPath);
      const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
      return new grpc.Client(peerEndpoint, tlsCredentials, {
          'grpc.ssl_target_name_override': 'peer0.org1.example.com',
      });
  }


Шаг 2: создание соединение с шлюзом
-----------------------------------
Затем приложение создает соединение с шлюзом (``Gateway``), которое будет использоваться для доступа к сетям
(``Networks`` - аналогу каналов), доступных для шлюза Fabric, и далее - к умным контрактам (``Contracts``), развернутым
в этих сетях. У соединения ``Gateway`` есть три требования:

  1. Соединение gRPC к шлюзу Fabric.
  2. Учетные данные клиента, используемые для работы с сетью.
  3. Реализация создания цифровых подписей на основе учетных данных клиента.

Данный пример приложения использует сертификат X.509 пользователя из организации Org1 в качестве учетных данных клиента
и создание подписи на основе закрытого ключа этого пользователя.

.. code-block:: TypeScript

  const client = await newGrpcConnection();

  const gateway = connect({
      client,
      identity: await newIdentity(),
      signer: await newSigner(),
  });

  async function newIdentity(): Promise<Identity> {
      const credentials = await fs.readFile(certPath);
      return { mspId: 'Org1MSP', credentials };
  }

  async function newSigner(): Promise<Signer> {
      const privateKeyPem = await fs.readFile(keyPath);
      const privateKey = crypto.createPrivateKey(privateKeyPem);
      return signers.newPrivateKeySigner(privateKey);
  }


Шаг 3: получение доступа к умному контракту, который будет вызван
-----------------------------------------------------------------
Пример приложения использует соединение ``Gateway`` для получения ссылки на сеть (``Network``) и затем - на контракт
по умолчанию (``Contract``) в чейнкоде, развернутом в этой сети.

.. code-block:: TypeScript

  const network = gateway.getNetwork(channelName);
  const contract = network.getContract(chaincodeName);

Если пакет чейнкода включает в себя несколько умных контрактов, вы можете указать и имя чейнкода, и имя требуемого
контракта в качестве аргументов при вызове метода `getContract() <https://hyperledger.github.io/fabric-gateway/main/api/node/interfaces/Network.html#getContract>`_.
Например:

.. code-block:: TypeScript

  const contract = network.getContract(chaincodeName, smartContractName);


Шаг 4: заполнение реестра образцами активов
-------------------------------------------
Сразу после первоначального развертывания пакета чейнкода, реестр пустой. Приложение вызывает метод ``submitTransaction()``,
чтобы выполнить функцию транзакции ``InitLedger``, которая заполняет реестр образцами активов. Метод ``submitTransaction()``
использует шлюз Fabric для:

  1. Одобрения предложения транзакции.
  2. Отправки одобренной транзакции в службу упорядочения.
  3. Ожидания записи транзакции в реестр и обновление состояния реестра.

Вызов функции ``InitLedger`` в приложении выглядит так:

.. code-block:: TypeScript

  await contract.submitTransaction('InitLedger');


Шаг 5: вызов функций транзакции для чтения и записи активов
-----------------------------------------------------------
Теперь приложение готово выполнить бизнес-логику запросов, создания новых активов и обновления активов в реестре,
вызывая функции транзакции в умном контракте.

Запрос всех активов
~~~~~~~~~~~~~~~~~~~
Приложение вызывает метод ``evaluateTransaction()`` для запроса данных из реестра, делая вызов транзакции только на
чтение. Метод ``evaluateTransaction()`` использует шлюз Fabric для вызова функции транзакции и возврата ее результата.
Транзакция не отправляется в службу упорядочения, обновление реестра в этом случае не происходит.

В примере ниже приложение получает все активы, созданные на одном из предыдущих шагов, когда заполнялся реестр.

Вызов функции ``GetAllAssets`` из приложения:

.. code-block:: TypeScript

  const resultBytes = await contract.evaluateTransaction('GetAllAssets');

  const resultJson = utf8Decoder.decode(resultBytes);
  const result = JSON.parse(resultJson);
  console.log('*** Result:', result);

.. note:: Результаты функций транзакций всегда возвращаются в виде последовательности байтов, поскольку могут быть
          данными любого типа. Часто функции возвращают строковые значения или, как в примере выше, данные JSON в
          кодировке UTF-8. Ответственность за правильную интерпретацию этой байтовой последовательности лежит на
          приложении.

В терминале должен появиться примерно такой вывод:

.. code-block:: text

  *** Result: [
    {
      AppraisedValue: 300,
      Color: 'blue',
      ID: 'asset1',
      Owner: 'Tomoko',
      Size: 5,
      docType: 'asset'
    },
    {
      AppraisedValue: 400,
      Color: 'red',
      ID: 'asset2',
      Owner: 'Brad',
      Size: 5,
      docType: 'asset'
    },
    {
      AppraisedValue: 500,
      Color: 'green',
      ID: 'asset3',
      Owner: 'Jin Soo',
      Size: 10,
      docType: 'asset'
    },
    {
      AppraisedValue: 600,
      Color: 'yellow',
      ID: 'asset4',
      Owner: 'Max',
      Size: 10,
      docType: 'asset'
    },
    {
      AppraisedValue: 700,
      Color: 'black',
      ID: 'asset5',
      Owner: 'Adriana',
      Size: 15,
      docType: 'asset'
    },
    {
      AppraisedValue: 800,
      Color: 'white',
      ID: 'asset6',
      Owner: 'Michel',
      Size: 15,
      docType: 'asset'
    }
  ]

Создание нового актива
~~~~~~~~~~~~~~~~~~~~~~
Приложение отправляет транзакцию для создания нового актива.

Вызов функции ``CreateAsset`` из приложения:

.. code-block:: TypeScript

  const assetId = `asset${Date.now()}`;

  await contract.submitTransaction(
      'CreateAsset',
      assetId,
      'yellow',
      '5',
      'Tom',
      '1300',
  );

.. note:: В примере кода выше, что очень важно, вызов функции транзакции ``CreateAsset`` производится с тем же
          количеством аргументов и их типами, которые ожидает чейнкод, а также с их верной последовательностью. В данном
          случае верная последовательность аргументов такая:

          .. code-block:: text

            assetId, "yellow", "5", "Tom", "1300"

          Соответствующая функция ``CreateAsset`` умного контракта ожидает следующую последовательность аргументов,
          определяющих объект актива:

          .. code-block:: text

            ID, Color, Size, Owner, AppraisedValue

Обновление актива
~~~~~~~~~~~~~~~~~
Приложение отправляет транзакцию для изменения владельца созданного актива. На этот раз транзакция отправляется
вызовом метода ``submitAsync()``, который возвращает результат после успешной отправки одобренной транзакции в службу
упорядочения, а не ожидает ее записи в реестр. Такой подход позволяет приложению выполнить работу с результатами
транзакции, пока ожидается результат ее записи в реестр.

Вызов функции ``TransferAsset`` из приложения:

.. code-block:: TypeScript

  const commit = await contract.submitAsync('TransferAsset', {
      arguments: [assetId, 'Saptha'],
  });
  const oldOwner = utf8Decoder.decode(commit.getResult());

  console.log(`*** Successfully submitted transaction to transfer ownership from ${oldOwner} to Saptha`);
  console.log('*** Waiting for transaction commit');

  const status = await commit.getStatus();
  if (!status.successful) {
      throw new Error(`Transaction ${status.transactionId} failed to commit with status code ${status.code}`);
  }

  console.log('*** Transaction committed successfully');

Вывод в терминале:

.. code-block:: text

  *** Successfully submitted transaction to transfer ownership from Tom to Saptha
  *** Waiting for transaction commit
  *** Transaction committed successfully

Запрос обновленного актива
~~~~~~~~~~~~~~~~~~~~~~~~~~
Затем приложение оценивает результаты запроса обновленного актива, показывая, что он был создан с описанными свойствами,
а потом передан новому владельцу.

Вызов функции ``ReadAsset`` из приложения:

.. code-block:: TypeScript

  const resultBytes = await contract.evaluateTransaction('ReadAsset', assetId);

  const resultJson = utf8Decoder.decode(resultBytes);
  const result = JSON.parse(resultJson);
  console.log('*** Result:', result);

Вывод в терминале:

.. code-block:: text

  *** Result: {
      AppraisedValue: 1300,
      Color: 'yellow',
      ID: 'asset1639084597466',
      Owner: 'Saptha',
      Size: 5
  }

Обработка ошибок транзакций
~~~~~~~~~~~~~~~~~~~~~~~~~~~
В конце давайте посмотрим на обработку ошибок при отправке транзакций. В примере ниже приложение осуществляет попытку
отправить транзакцию с вызовом функции ``UpdateAsset``, но указывает идентификатор несуществующего актива. Функция
транзакции возвращает ошибку в ответе и вызов метода ``submitTransaction()`` завершается неудачей.

Неудачное завершение метода ``submitTransaction()`` может вернуть несколько разных типов ошибок, указывающих, в какой
точке исполнения транзакции произошел сбой, и содержащих дополнительную информацию, позволяющую приложению должным
образом отреагировать на ошибку. Обратитесь к `документации по API <https://hyperledger.github.io/fabric-gateway/main/api/node/interfaces/Contract.html#submitTransaction>`_
для получения дополнительной информации о разных типах возникающих ошибок.

Неудачный вызов функции ``UpdateAsset`` из приложения:

.. code-block:: TypeScript

  try {
      await contract.submitTransaction(
          'UpdateAsset',
          'asset70',
          'blue',
          '5',
          'Tomoko',
          '300',
      );
      console.log('******** FAILED to return an error');
  } catch (error) {
      console.log('*** Successfully caught the error: \n', error);
  }

Вывод терминала (без трассировки стека для наглядности):

.. code-block:: text

  *** Successfully caught the error:
  EndorseError: 10 ABORTED: failed to endorse transaction, see attached details for more info
      at ... {
    code: 10,
    details: [
      {
        address: 'peer0.org1.example.com:7051',
        message: 'error in simulation: transaction returned with failure: Error: The asset asset70 does not exist',
        mspId: 'Org1MSP'
      }
    ],
    cause: Error: 10 ABORTED: failed to endorse transaction, see attached details for more info
        at ... {
      code: 10,
      details: 'failed to endorse transaction, see attached details for more info',
      metadata: Metadata { internalRepr: [Map], options: {} }
    },
    transactionId: 'a92980d41eef1d6492d63acd5fbb6ef1db0f53252330ad28e548fedfdb9167fe'
  }

Тип ошибки ``EndorseError`` означает, что сбой произошел на этапе одобрения, но приложению удалось успешно обратиться к
шлюзу Fabric, о чем говорит `код статуса gRPC <https://grpc.github.io/grpc/core/md_doc_statuscodes.html>`_ ``ABORTED``.
Коды статуса gRPC ``UNAVAILABLE`` или ``DEADLINE_EXCEEDED`` означали бы недоступность шлюза Fabric или то, что ответ не
был получен в определенный период ожидания и поэтому целесообразно повторить операцию.


Очистка
=======
Когда вы закончили работать с примером asset-transfer, вы можете свернуть тестовую сеть с помощью сценария ``network.sh``.

.. code-block:: bash

  ./network.sh down

Эта команда остановит удостоверяющие центры, одноранговые узлы и узлы службы упорядочения сети блокчейн, которую мы
запустили ранее. Имейте в виду, что все данные реестра будут потеряны. И если вы хотите пройти это руководство еще раз,
вы можете начать с чистого начального состояния.


Заключение
==========
Мы рассмотрели настройку сети блокчейн, запустив тестовую сеть и развернув в ней умный контракт. Затем мы запустили
клиентское приложение и рассмотрели его код, чтобы понять, как оно использует клиентский API шлюза Fabric для запроса и
обновления данных в реестре путем подключения к шлюзу Fabric и вызова функций транзакций в развернутом умном контракте.
