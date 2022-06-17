Identity Mixer MSP configuration generator (idemixgen)
======================================================

このドキュメントは、Identity MixerベースのMSP設定ファイルを作成する ``idemixgen`` ユーティリティの利用方法を説明します。
2つのコマンドを使用できます。
1つは新規のCAキーペアを作成するためのコマンド、もう1つは以前に生成されたCAキーを使用してMSP設定を作成するためのコマンドです。

Directory Structure
-------------------

``idemixgen`` ツールは以下の構造を持つディレクトリを作成します。

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

``ca`` ディレクトリには、発行者の秘密鍵(失効鍵を含む)が含まれており、CAに対してのみ存在する必要があります。
``msp`` ディレクトリには、idemixの署名を検証するMSPを設定するために必要な情報が含まれています。
``user`` ディレクトリは、デフォルトの署名者を指定します。

CA Key Generation
-----------------

Identity MixerのためのCA(発行者)の鍵は、 ``idemixgen ca-keygen`` というコマンドを使用して作成できます。
これにより、作業ディレクトリに ``ca`` と ``msp`` というディレクトリが作成されます。

Adding a Default Signer
-----------------------
``idemixgen ca-keygen`` でディレクトリ ``ca`` と ``msp`` を作成後、 ``idemixgen signerconfig`` を実行すると、 ``user`` ディレクトリで指定されたデフォルト署名者が設定に追加されます。

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

例えば、次のコマンドを使用して、組織単位(OU)"OrgUnit1"のメンバーであり、登録ID"johndoe"を持ち、失効ハンドル"1234"を持ち、adminであるデフォルトの署名者を作成できます。

.. code:: bash

    idemixgen signerconfig -u OrgUnit1 --admin -e "johndoe" -r 1234

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
