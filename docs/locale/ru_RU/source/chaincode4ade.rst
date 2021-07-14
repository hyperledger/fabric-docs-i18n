Чейнкод для разработчиков
=========================

Что такое чейнкод
-----------------

Чейнкод - это программный код, написанный с использованием языков программирования
`Go <https://golang.org>`_, `Node.js <https://nodejs.org>`_, или `Java <https://java.com/en/>`_
и реализующий необходимые интерфейсы. Чейнкод выполняется в отдельном от однорангового узла процессе
и инициализирует и управляет состоянием реестра посредством транзакций, отправляемых приложениями.

Чейнкод обычно обрабатывает бизнес-логику, согласованную участниками сети, поэтому его можно рассматривать
как «смарт-контракт». Чейнкод можно вызвать для изменения или считывания данных из реестра с помощью предложений
транзакций. При наличии соответствующего разрешения чейнкод может вызывать другой чейнкод, как в том же канале,
так и в разных каналах, для доступа к его состоянию. Обратите внимание — если вызываемый чейнкод находится
в другом канале, чем вызывающий чейнкод, разрешен только запрос чтения данных. То есть, если вызываемый чейнкод
сделает какие-то изменения, они не будут участвовать в проверке достоверности состояния и не попадут в реестр.

В следующих разделах мы рассмотрим чейнкод глазами разработчика приложений. Мы представим простой пример чейнкода
и рассмотрим назначение каждого метода в API Chaincode Shim. Если вы являетесь оператором сети, который развертывает
чейнкод в работающей сети, обратитесь к руководству :doc:`deploy_chaincode` и разделу :doc:`chaincode_lifecycle`.

В этом руководстве представлен обзор низкоуровневых API, предоставляемых Fabric Chaincode Shim API. Вы также
можете использовать API более высокого уровня, предоставляемые Fabric Contract API. Чтобы узнать больше
о разработке смарт-контрактов с использованием API контрактов Fabric, обратитесь к разделу :doc:`developapps/smartcontract`.

API чейнкода
------------

Каждая программа чейнкода должна реализовывать интерфейс ``Chaincode``, методы которого вызываются в ответ
на полученные транзакции. По ссылкам ниже вы можете найти справочную документацию по API Chaincode Shim для разных языков:

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeInterface.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/Chaincode.html>`__

Независимо от языка программирования ``Invoke`` вызывается клиентами для отправки запросов на транзакцию.
Этот метод позволяет использовать чейнкод для чтения и записи данных в реестре канала.

Также в чейнкод необходимо включить метод ``Init``, который предназначен для инициализации. Эта функция
требуется интерфейсом чейнкода, но не обязательно должна вызываться вашими приложениями. В процессе
жизненного цикла чейнкода Fabric можно указать необходимость вызова функции ``Init`` перед вызовами функции ``Invoke``.
Дополнительная информация приведена в описании параметра инициализации в подразделе
`Утверждение определения чейнкода <chaincode_lifecycle.html#step-three-approve-a-chaincode-definition-for-your-organization>`__
документации по жизненному циклу чейнкода Fabric.

Другой интерфейс из API-интерфейсов оболочки чейнкода — это ``ChaincodeStubInterface``:

  - `Go <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__
  - `Node.js <https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeStub.html>`__
  - `Java <https://hyperledger.github.io/fabric-chaincode-java/{BRANCH}/api/org/hyperledger/fabric/shim/ChaincodeStub.html>`__

Этот интерфейс используется для доступа и изменения реестра, а также вызова чейнкода другим чейнкодом.

В этом руководстве рассматривается использование указанных API (версия Go) для создания простого чейнкода, который
управляет простыми «активами».

.. _Simple Asset Chaincode:

Чейнкод с простыми активами
---------------------------
Наше приложение - простой пример чейнкода для создания активов (пар «ключ-значение») в реестре.

Выбор расположения кода
^^^^^^^^^^^^^^^^^^^^^^^

Если вы ранее не использовали язык Go, установите и правильно настройте `Go <https://golang.org>`_ в вашей системе.
Используемая версия Go должна поддерживать модули.

Создадим каталог для чейнкода.

Для простоты воспользуемся следующей командой:

.. code:: bash

  mkdir sacc && cd sacc

Теперь создадим модуль и файл с исходным кодом:

.. code:: bash

  go mod init sacc
  touch sacc.go

Подготовка
^^^^^^^^^^

Начнем с подготовки. Любой чейнкод реализует интерфейс `Chaincode <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Chaincode>`_
в частности методы ``Init`` и ``Invoke``. Используем операторы импорта Go для добавления необходимых
зависимостей чейнкода. Импортируем пакет оболочки чейнкода и `пакет peer protobuf <https://godoc.org/github.com/hyperledger/fabric-protos-go/peer>`_.
Далее добавим структуру ``SimpleAsset`` в качестве приемника функций чейнкода.

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric-chaincode-go/shim"
    	"github.com/hyperledger/fabric-protos-go/peer"
    )

    // SimpleAsset реализует простой чейнкод для управления активом
    type SimpleAsset struct {
    }

Инициализация чейнкода
^^^^^^^^^^^^^^^^^^^^^^

Далее реализуем функцию ``Init``:

.. code:: go

  // Функция Init вызывается при создании экземпляра чейнкода для инициализации данных.
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {

  }

.. note:: Обратите внимание, что эта функция также вызывается при обновлении чейнкода.
          При написании обновленной версии чейнкода следует соответствующим образом изменить метод ``Init``.
          В частности, метод ``Init`` должен быть пустым, если не осуществляется «миграция» или
          в процессе обновления не требуется инициализация.

Далее получим аргументы для вызова ``Init`` с помощью функции
`ChaincodeStubInterface.GetStringArgs <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetStringArgs>`_
и произведем соответствующую проверку. В нашем случае должна быть пара «ключ-значение».

  .. code:: go

    // Функция Init вызывается при создании экземпляра чейнкода для инициализации 
    // Обратите внимание, что при обновлении чейнкода эта функция также вызывается для сброса
    // или миграции данных. Поэтому будьте осторожны, чтобы избежать
    // непреднамеренного удаления данных реестра!
    func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
      // Получение аргументов из запроса на транзакцию
      args := stub.GetStringArgs()
      if len(args) != 2 {
        return shim.Error("Неверное количество аргументов. Должны быть ключ и значение")
      }
    }

Выяснив, что вызов функции правильный, сохраним исходное состояние в реестре. Для этого вызовем
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.PutState>`_,
передав пару «ключ-значение» в качестве аргументов. При успешном выполнении вернем объект peer.Response,
который указывает на успешное завершение инициализации.

.. code:: go

  // Функция Init вызывается при создании экземпляра чейнкода для инициализации
  // данных. Обратите внимание, что при обновлении чейнкода эта функция также вызывается для сброса
  // или миграции данных. Поэтому будьте осторожны, чтобы избежать
  // непреднамеренного удаления данных реестра!
  func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
    // Получение аргументов из запроса на транзакцию
    args := stub.GetStringArgs()
    if len(args) != 2 {
      return shim.Error("Неверное количество аргументов. Должны быть ключ и значение")
    }

    // Определите любые переменные или активы, вызвав stub.PutState()

    // Сохранение ключа и значения в реестре
    err := stub.PutState(args[0], []byte(args[1]))
    if err != nil {
      return shim.Error(fmt.Sprintf("Ошибка создания актива: %s", args[0]))
    }
    return shim.Success(nil)
  }

Вызов чейнкода
^^^^^^^^^^^^^^

Сперва добавим сигнатуру функции ``Invoke``.

.. code:: go

    // Функция Invoke вызывается в каждой транзакции чейнкода. Каждая транзакция
    // может выполнять метод 'get' или 'set' для актива, созданного функцией Init.
    // Метод 'set' также позволяет создать новый актив, указав новую пару ключ-значение.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

    }

Также как и в случае с функцией ``Init`` выше, нам нужно получить аргументы из ``ChaincodeStubInterface``.
Аргументом функции ``Invoke`` будет название функции чейнкода, которую требуется вызвать. В нашем случае
в приложении будет две функции: ``set`` и ``get``, позволяющие устанавливать значение актива или получать
его текущее состояние. Сперва вызовем
`ChaincodeStubInterface.GetFunctionAndParameters <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetFunctionAndParameters>`_,
чтобы извлечь имя функции и параметры для этого метода.

.. code:: go

    // Функция Invoke вызывается в каждой транзакции чейнкода. Каждая транзакция
    // может выполнять метод 'get' или 'set' для актива, созданного функцией Init.
    // Метод 'set' также позволяет создать новый актив, указав новую пару ключ-значение.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Функции и аргументы извлекаются из запроса на транзакцию
    	fn, args := stub.GetFunctionAndParameters()

    }

Далее проверим, что переданное имя функции - это ``set`` или ``get``, а затем вызовем соответсвующую
функцию приложения, возвращая ее ответ с помощью ``shim.Success`` или ``shim.Error``, которые сериализуют
ответ функции в сообщение формата gRPC protobuf.

.. code:: go

    // Функция Invoke вызывается в каждой транзакции чейнкода. Каждая транзакция
    // может выполнять метод 'get' или 'set' для актива, созданного функцией Init.
    // Метод 'set' также позволяет создать новый актив, указав новую пару ключ-значение.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Функции и аргументы извлекаются из запроса на транзакцию
    	fn, args := stub.GetFunctionAndParameters()

    	var result string
    	var err error
    	if fn == "set" {
    		result, err = set(stub, args)
    	} else {
    		result, err = get(stub, args)
    	}
    	if err != nil {
    		return shim.Error(err.Error())
    	}

    	// Возврат результата при успешном выполнении
    	return shim.Success([]byte(result))
    }

Реализация логики чейнкода
^^^^^^^^^^^^^^^^^^^^^^^^^^

Как говорилось ранее, наше приложение реализует две функции, которые могут быть вызваны с помощью функции ``Invoke``.
Давайте теперь реализуем эти функции. Вспомним, что для получения доступа к состоянию реестра используются функции
`ChaincodeStubInterface.PutState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.PutState>`_
и `ChaincodeStubInterface.GetState <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetState>`_
API Chaincode Shim.

.. code:: go

    // Функция Set сохраняет актив (как пару «ключ-значение») в реестре.
    // Если ключ уже существует, функция перезапишет значение
    func set(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 2 {
    		return "", fmt.Errorf("Неверные аргументы. Должны быть ключ и значение")
    	}

    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return "", fmt.Errorf("Ошибка изменения актива: %s", args[0])
    	}
    	return args[1], nil
    }

    // Функция Get возвращает значение по указанному ключу актива
    func get(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 1 {
    		return "", fmt.Errorf("Неверные аргументы. Должны быть ключ")
    	}

    	value, err := stub.GetState(args[0])
    	if err != nil {
    		return "", fmt.Errorf("Нет доступа к активу: %s ошибка: %s", args[0], err)
    	}
    	if value == nil {
    		return "", fmt.Errorf("Актив не найден: %s", args[0])
    	}
    	return string(value), nil
    }

.. _Chaincode Sample:

Финальный результат
^^^^^^^^^^^^^^^^^^^

Теперь добавим функцию ``main``, которая вызывает функцию `shim.Start <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#Start>`_.
Ниже приводится весь код программы чейнкода.

.. code:: go

    package main

    import (
    	"fmt"

    	"github.com/hyperledger/fabric-chaincode-go/shim"
    	"github.com/hyperledger/fabric-protos-go/peer"
    )

    // SimpleAsset реализует простой чейнкод для управления активом
    type SimpleAsset struct {
    }

    // Функция Init вызывается при создании экземпляра чейнкода для инициализации
    // данных. Обратите внимание, что при обновлении чейнкода эта функция также вызывается для сброса
    // или миграции данных.
    func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
    	// Получение аргументов из запроса на транзакцию
    	args := stub.GetStringArgs()
    	if len(args) != 2 {
    		return shim.Error("Неверное количество аргументов. Должен быть ключ и значение")
    	}

    	// Определите любые переменные или активы, вызвав stub.PutState()

    	// Сохранить ключ и значение в реестре
    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return shim.Error(fmt.Sprintf("Ошибка создания актива: %s", args[0]))
    	}
    	return shim.Success(nil)
    }

    // Функция Invoke вызывается в каждой транзакции чейнкода. Каждая транзакция
    // может выполнять метод 'get' или 'set' для актива, созданного функцией Init.
    // Метод 'set' также позволяет создать новый актив, указав новую пару ключ-значение.
    func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
    	// Функции и аргументы извлекаются из запроса на транзакцию
    	fn, args := stub.GetFunctionAndParameters()

    	var result string
    	var err error
    	if fn == "set" {
    		result, err = set(stub, args)
    	} else { // считаем, что 'get', даже если fn имеет нулевое значение
    		result, err = get(stub, args)
    	}
    	if err != nil {
    		return shim.Error(err.Error())
    	}

    	// Возврат результата при успешном выполнении
    	return shim.Success([]byte(result))
    }

    // Функция Set сохраняет актив (как пару «ключ-значение») в реестре.
    // Если ключ уже существует, функция перезапишет значение
    func set(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 2 {
    		return "", fmt.Errorf("Неверные аргументы. Должны быть ключ и значение")
    	}

    	err := stub.PutState(args[0], []byte(args[1]))
    	if err != nil {
    		return "", fmt.Errorf("Ошибка изменения актива: %s", args[0])
    	}
    	return args[1], nil
    }

    // Функция Get возвращает значение по указанному ключу актива
    func get(stub shim.ChaincodeStubInterface, args []string) (string, error) {
    	if len(args) != 1 {
    		return "", fmt.Errorf("Неверные аргументы. Должны быть ключ")
    	}

    	value, err := stub.GetState(args[0])
    	if err != nil {
    		return "", fmt.Errorf("Нет доступа к активу: %s ошибка: %s", args[0], err)
    	}
    	if value == nil {
    		return "", fmt.Errorf("Актив не найден: %s", args[0])
    	}
    	return string(value), nil
    }

    // Функция main запускает чейнкод в контейнере во время создания экземпляра
    func main() {
    	if err := shim.Start(new(SimpleAsset)); err != nil {
    		fmt.Printf("Ошибка запуска чейнкода SimpleAsset: %s", err)
    	}
    }

Контроль доступа в чейнкоде
---------------------------

Чейнкод может использовать сертификат клиента (отправителя) для принятия решений по управлению доступом,
вызывая функцию GetCreator(). Кроме того, Go shim предоставляет дополнения к API, которые извлекают
идентификационные данные клиента из сертификата отправителя, использующиеся для принятия решений по
управлению доступом, будь то на основе идентификационных данных самого клиента, или идентификационных данных
его организации, или атрибутов идентификационных данных клиента.

Например, актив, представленный как ключ/значение, может включать идентификационные данные клиента как часть
значения (например, как атрибут JSON, указывающий на владельца актива), и только этот клиент может быть
уполномочен делать обновления ключа/значения в будущем. Библиотека идентификации клиента из расширений API
может быть использована в чейнкоде для получения информации об отправителе для принятия таких решений по управлению доступом.
Дополнительная информация приводится в `документации к библиотеке идентификации клиентов (CID) <https://github.com/hyperledger/fabric-chaincode-go/blob/{BRANCH}/pkg/cid/README.md>`_.

Чтобы добавить расширение Client Identity Shim в чейнкод в качестве зависимости, см. :ref:`vendoring`.

.. _vendoring:

Управление внешними зависимостями для чейнкода, написанного на Go
-----------------------------------------------------------------
Наш чейнкод, написанный на Go имеет ряд зависимостей - пакетов Gо (например, Chainсode Shim), которые не входят
в состав стандартной библиотеки. Исходный код этих пакетов должен быть включен в пакет чейнкода при установке
на одноранговых узлах. Если вы оформили свой чейнкод как модуль, самый простой способ —
это воспользоваться командой ``go mod vendor`` перед упаковкой чейнкода.

.. code:: bash

  go mod tidy
  go mod vendor

Эта команда помещает внешние зависимости чейнкода в локальный каталог ``vendor``.

После сохранения зависимостей в каталоге чейнкода, воспользуйтесь командами ``peer chaincode package`` и
``peer chaincode install`` для включения кода зависимостей в пакет чейнкода.
