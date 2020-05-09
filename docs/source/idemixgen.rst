身份混合器（Identity Mixer） MSP 配置生成器（idemixgen）
======================================================

本文讲述了 ``idemixgen`` 工具的用法，它用来根据 MSP 为身份混合器创建配置文件。有两个可用的命令，一个用来创建新的 CA 密钥对，另一个用来根据之前生成的 CA 密钥创建 MSP 配置。

目录结构
-------------------

``idemixgen`` 工具将根据下边的结构创建目录：

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

``ca`` 目录包含发布者的私钥（包括已撤销的密钥）并且应该只代表一个 CA。``msp`` 目录包含用于验证 idemix 签名的 MSP 信息。``user`` 目录指定一个默认的签名者。

CA 密钥生成
-----------------

身份混合器的 CA（发布者） 密钥套件可以使用 ``idemixgen ca-keygen`` 命令创建。这将会在工作目录创建 ``ca`` 和 ``msp`` 目录。

添加默认签名者
-----------------------

在使用 ``idemixgen ca-keygen`` 命令创建 ``ca`` 和 ``msp`` 目录后，可以使用 ``idemixgen signerconfig`` 向配制中添加 ``user`` 目录中的一个用户为默认签名者。

.. code:: bash

    $ idemixgen signerconfig -h
    usage: idemixgen signerconfig [<flags>]

    Generate a default signer for this Idemix MSP

    Flags:
        -h, --help               Show context-sensitive help (also try --help-long and --help-man).
        -u, --org-unit=ORG-UNIT  The Organizational Unit of the default signer
        -a, --admin              Make the default signer admin
        -e, --enrollment-id=ENROLLMENT-ID
                                 The enrollment id of the default signer
        -r, --revocation-handle=REVOCATION-HANDLE
                                 The handle used to revoke this signer

例如，我们可以创建组织单元 “OrgUnit1” 中的一个成员为默认签名者，他的注册身份是 “johndoe”， 撤销句柄为 “1234”，并且是一个管理员，创建的命令如下：

.. code:: bash

    idemixgen signerconfig -u OrgUnit1 --admin -e "johndoe" -r 1234

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
