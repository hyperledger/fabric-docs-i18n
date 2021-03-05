Генератор конфигурации Identity Mixer MSP (idemixgen)
=====================================================

Этот документ описывает использование программы
``idemixgen``, которую можно использовать для создания файлов конфигурации Idemix MSP
Доступны две команду: одна для создания новой пары ключей CA, одна для
создания конфига MSP, основывающегося на созданных до этого ключах.

Структура директории
--------------------

``idemixgen`` создает директории со следующей структурой:

.. code:: bash

    - /ca/
        IssuerSecretKey
        IssuerPublicKey
        RevocationKey
    - /msp/
        IssuerPublicKey
        RevocationPublicKey
    - /user/
        SignerConfig

Директория ``ca`` содержит секретный ключ и ключ отзыва издателя (issuer) и должна присутствовать только у CA.
Директория ``msp`` содержит информацию, необходимую для установки MSP, который будет проверять подписи Idemix.
Директория ``user`` указывает стандартного пописанта (signer).

Генерация ключей CA
-------------------

Ключи CA (издатель, issuer), подходящие для Idemix, могут быть созданы командой
``idemixgen ca-keygen``. Она создаст директории ``ca`` и ``msp`` в текущей рабочей директории.

Добавление стандартного signer'а
--------------------------------

После генерации директорий ``ca`` и ``msp`` с помощью
``idemixgen ca-keygen``, signer может быть сгенерирован ``idemixgen signerconfig``.

.. code:: bash

    $ idemixgen signerconfig -h
    usage: idemixgen signerconfig [<flags>]

    Generate a default signer for this Idemix MSP

    Flags:
        -h, --help               Показать контекстную помощь. (также попробуйте --help-long и --help-man)
        -u, --org-unit=ORG-UNIT  Organizational Unit (Организационное подразделение) стандартного signer'а
        -a, --admin              Сделать signer'а администратором
        -e, --enrollment-id=ENROLLMENT-ID
                                 Enrollment id стандартного signer'а
        -r, --revocation-handle=REVOCATION-HANDLE
                                 Строка, необходимая для отзыва signer'а

Например, мы может создать стандартного signer'а, который будет членом организационного подразделения
"OrgUnit1", с enrollment identity "johndoe", строкой отзыва (revocation handle) "1234",
и который будет являться администратором, следующей командой:

.. code:: bash

    idemixgen signerconfig -u OrgUnit1 --admin -e "johndoe" -r 1234

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
