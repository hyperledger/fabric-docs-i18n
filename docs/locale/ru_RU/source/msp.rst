Membership Service Providers (MSP)
==================================

В этом документе собраны детали по установке MSP, а также связанные с этим best practicies.

MSP --- это компонент Hyperledger Fabric, который абстрагирует membership-операции 
(то есть операции, связанные с участниками сети).

В частности, MSP абстрагирует все криптографические механизмы и протоколы, отвечающие 
за выпуск сертификатов, подтверждение сертификатов и аутентификацию пользователей.
MSP может определить свое понятие identity и правил по управлению ими (identity validation)
и по аутентификации (генерация и верификация подписей).

Блокчейн-сеть Hyperledger Fabirc может управляться одним или несколькими MSP.
Это обеспечивает модульность membership-операций, а также взаимодействие
между несколькими разными membrship-стандартами и архитектурами.

В оставшейся части этого документа поговорим об установке реализации MSP,
поддерживаемой HL Fabric, и обсудим best practicies, связанные с его использованием.

Настройка MSP
-------------

Чтобы установить экземпляр MSP, его конфигурация должна быть указана
локально на каждом пире и orderer'е, чтобы:

- обеспечить подписание пиров и orderer'ов,
- позволить каналам подтверждать identity пиров, orderer'ов и клиентов
- обеспечить проверку соответствующей верификации подписей (то есть 
  обеспечить аутентификацию) всеми участниками каналов всех других участников.

Для начала, каждый MSP должен иметь имя, чтобы на него можно было ссылаться
в сети (например так: ``msp1``, ``org2``, или ``org3.divA``). Это имя, с
помощью которого в канале будут указаны membership rules MSP (правила членства),
представляющего консорциум, организацию или подразделении организации. На это имя
также часто ссылаются как на *MSP Identifier* (идентификатор MSP) или *MSP ID*. 
MSP Identifier должен быть уникальным для каждого экземпляра MSP. Например, если
при создании системного канала обнаружится, что два разных экземпляра MSP имеют 
один и тот же MSP Identifier, то установка orderer-службы будет прервана.

В случае стандартной реализации MSP, необходимо задать некоторый набор параметров,
чтобы можно было проводить валидацию identity (сертификата) и верификацию подписей.
Эти параметры можно определить по `RFC5280 <http://www.ietf.org/rfc/rfc5280.txt>`_,
включая:

- список само-подписанных (X.509) CA-сертификатов для образования *root of trust*
  (основы доверия)
- Список сертификатов X.509, представляющих промежуточные CA, которых данный провайдер
  выбрал для валидации сертификатов; эти сертификаты должны быть сертифицированы
  ровно одним из сертификатов, образующих root of trust; промежуточные CA ---
  опциональные параметры
- Список сертификатов X.509, представляющих администраторов данного MSP с verifiable certificate path (проверяемым сертификационным путем?) к
  ровно одному из образующих root of trust CA сертификатов; владельцы данных сертификатов
  имеют право запросить изменения к данной MSP конфигурации (например к корневым CA, то есть
  тем, которые образовывают root of trust, или к промежуточным CA)
- Список Organizational Units, которые участники данного MSP должны включить в свои
  сертификаты X.509; это опциональный параметр, который используется когда, например,
  несколько организаций использвуют один и тот же root of trust, те же промежуточные CA
  и зарезервировали OU-поля для своих участников
- Список из certificate revocation lists (CRLs, списки аннулирования сертификатов),
  каждый из которых соответствует ровно одному корневому или промежуточному MSP CA;
  это опциональный параметр
- Список само-подписанных (X.509) сертификатов для образования *TLS root of trust* для
  TLS-сертификатов
- Список сертификатов X.509, представляющих промежуточные TLS CA, выбранных данным провайдером;
  эти сертификаты должны быть сертифицированы ровно одним из сертификатов, образующих 
  TLS root of trust; промежуточные CA --- опциональные параметры

*Валидные* identities для данного экземпляра MSP должны удовлетворять следующим требованиям:

- Они должны быть в форме X.509 сертификатов с verifiable certificate path до ровно одного из
  корневых сертификатов;
- Они не должны быть включены ни в один CRL;
- Они должны *перечислить* один или более Organizational Units MSP-конфигурации в поле ``OU``
  в их структуре сертификата X.509.

Для получения дополнительной информации по валидности identities в текущей реализации MSP,
обратитесь к :doc:`msp-identity-validity-rules`.

В дополнение к связанным с верификацией параметров, для того, чтобы позволить узлу, на котором
инстанцирован MSP, подписывать и аутентифицировать, необходимо задать:

- Ключ цифровой подписи (сейчас поддерживаются только ECDSA-ключи), и
- Сертификат X.509 узла, который является валидной, для верификационных параметров данного MSP,
  identity.

Важно заметить, что MSP identities никогда не просрочиваются; они могут быть аннулированы только
добавлением в подходящие CRLs. Также в данный момент не поддерживается аннулирование TLS-сертификатов.

Как сгенерировать MSP сертификаты и ключи цифровой подписи?
-----------------------------------------------------------

`Openssl <https://www.openssl.org/>`_ может использоваться, чтобы генерировать X.509
сертификаты и ключи. Заметьте, что Hyperledger Fabric не поддерживать RSA ключи и сертификаты.

Также можно использовать программу ``cryptogen``, описанную в :doc:`getting_started`.

`Hyperledger Fabric CA <http://hyperledger-fabric-ca.readthedocs.io/en/latest/>`_
также может использоваться, чтобы генерировать необходимые для настройки MSP ключи и сертификаты.

Установка MSP на стороне пира и orderer'а
-----------------------------------------

Чтобы установить локальную MSP (или для пира, или для orderer'а), администратор должен создать
директорию (например ``$MY_PATH/mspconfig``), содержащую 6 поддиректорий и 1 файл:

1. директория ``admincerts``, чтобы хранить PEM-файлы, каждый из которых соответствует сертификату администратора
2. директория ``cacerts`` , чтобы хранить PEM-файлы, каждый из которых соответствует корневому CA-сертификату
3. (опционально) директория ``intermediatecerts`` , чтобы хранить PEM-файлы, каждый из которых соответствует
   промежуточному CA-сертификату
4. (опционально) файл ``config.yaml`` для настройки поддерживаемых Organizational Units
   и identity classifications (смотрите соответствующие секции ниже).
5. (опционально) директория ``crls`` , чтобы хранить CRLs
6. директория ``keystore`` , чтобы хранить PEM-файл с ключом цифровой подписи узла.
   Обращаем внимание, что RSA-ключи не поддерживаются
7. директория ``signcerts`` , чтобы хранить PEM-файл X.509 сертификатом узла
8. (опционально) директория ``tlscacerts`` , чтобы хранить PEM-файлы, каждый из которых соответствует
   корневому TLS-сертификату
9. (опционально) директория ``tlsintermediatecerts`` , чтобы хранить PEM-файлы, каждый из которых соответствюет
   промежуточному TLS-сертификату

В концигурационном файле узла (``core.yaml`` для пира, и ``orderer.yaml`` для orderer'а),
необходимо указать путь к ``mspconfig`` директории, а также MSP идентификатор для MSP узла.
Ожидается, что путь к ``mspconfig`` будет относителен ``FABRIC_CFG_PATH`` и будет дан как
значение параметра ``mspConfigPath`` для пира, и ``LocalMSPDir`` для orderer'а. Идентификатор
MSP узла задается как параметр ``localMspId`` для пира and ``LocalMSPID`` для orderer'a.
Эти переменные могут быть переопределены через переменные окружения с использованием префикса ``CORE``
для пира (например CORE_PEER_LOCALMSPID) и ``ORDERER`` префикса для orderer'a (например
OrDERER_GENERAL_LOCALMSPID). Заметьте, что установки orderer'a необходимо сгенерировать и передать
orderer'у genesis-блок системного канала. Нужды MSP-конфигурации в этом блоке указаны детально
в следующей секции.

*Перенастройка* локальной MSP возможна только вручную, и нуждается в перезагрузке пира или orderer'а.
В следующих релизах мы планируем добавить online/динамическую реконфигурацию
(например без нужды в остановке узла с помощью управляемого узлом системного chaincode'а).

Organizational Units
--------------------

In order для настройки the list of Organizational Units that valid members of this MSP should
include in their X.509 certificate, the ``config.yaml`` file
needs to specify the organizational unit (OU, for short) identifiers. You can find an example
below:

::

   OrganizationalUnitIdentifiers:
     - Certificate: "cacerts/cacert1.pem"
       OrganizationalUnitIdentifier: "commercial"
     - Certificate: "cacerts/cacert2.pem"
       OrganizationalUnitIdentifier: "administrators"

The above example declares two organizational unit identifiers: **commercial** and **administrators**.
An MSP identity is valid if it carries at least one of these organizational unit identifiers.
The ``Certificate`` field refers to the CA or intermediate CA certificate path
under which identities, having that specific OU, should be validated.
The path is relative to the MSP root folder and cannot be empty.

Identity Classification
-----------------------

The default MSP implementation allows organizations to further classify identities into clients,
admins, peers, and orderers based on the OUs of their x509 certificates.

* An identity should be classified as a **client** if it transacts on the network.
* An identity should be classified as an **admin** if it handles administrative tasks such as
  joining a peer to a channel or signing a channel configuration update transaction.
* An identity should be classified as a **peer** if it endorses or commits transactions.
* An identity should be classified as an **orderer** if belongs to an ordering node.

In order to define the clients, admins, peers, and orderers of a given MSP, the ``config.yaml`` file
needs to be set appropriately. You can find an example NodeOU section of the ``config.yaml`` file
below:

::

   NodeOUs:
     Enable: true
     # For each identity classification that you would like to utilize, specify
     # an OU identifier.
     # You can optionally configure that the OU identifier must be issued by a specific CA
     # or intermediate certificate from your organization. However, it is typical to NOT
     # configure a specific Certificate. By not configuring a specific Certificate, you will be
     # able to add other CA or intermediate certs later, without having to reissue all credentials.
     # For this reason, the sample below comments out the Certificate field.
     ClientOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "client"
     AdminOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "admin"
     PeerOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "peer"
     OrdererOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "orderer"

Identity classification is enabled when ``NodeOUs.Enable`` is set to ``true``. Then the client
(admin, peer, orderer) organizational unit identifier is defined by setting the properties of
the ``NodeOUs.ClientOUIdentifier`` (``NodeOUs.AdminOUIdentifier``, ``NodeOUs.PeerOUIdentifier``,
``NodeOUs.OrdererOUIdentifier``) key:

a. ``OrganizationalUnitIdentifier``: Is the OU value that the x509 certificate needs to contain
   to be considered a client (admin, peer, orderer respectively). If this field is empty, then the classification
   is not applied.
b. ``Certificate``: (Optional) Set this to the path of the CA or intermediate CA certificate
   under which client (peer, admin or orderer) identities should be validated.
   The field is relative to the MSP root folder. Only a single Certificate can be specified.
   If you do not set this field, then the identities are validated under any CA defined in
   the organization's MSP configuration, which could be desirable in the future if you need
   to add other CA or intermediate certificates.

Notice that if the ``NodeOUs.ClientOUIdentifier`` section (``NodeOUs.AdminOUIdentifier``,
``NodeOUs.PeerOUIdentifier``, ``NodeOUs.OrdererOUIdentifier``) is missing, then the classification
is not applied. If ``NodeOUs.Enable`` is set to ``true`` and no classification keys are defined,
then identity classification is assumed to be disabled.

Identities can use organizational units to be classified as either a client, an admin, a peer, or an
orderer. The four classifications are mutually exclusive.
The 1.1 channel capability needs to be enabled before identities can be classified as clients
or peers. The 1.4.3 channel capability needs to be enabled for identities to be classified as an
admin or orderer.

Classification allows identities to be classified as admins (and conduct administrator actions)
without the certificate being stored in the ``admincerts`` folder of the MSP. Instead, the
``admincerts`` folder can remain empty and administrators can be created by enrolling identities
with the admin OU. Certificates in the ``admincerts`` folder will still grant the role of
administrator to their bearer, provided that they possess the client or admin OU.

Channel MSP setup
-----------------

At the genesis of the system, verification parameters of all the MSPs that
appear in the network need to be specified, and included in the system
channel's genesis block. Recall that MSP verification parameters consist of
the MSP identifier, the root of trust certificates, intermediate CA and admin
certificates, as well as OU specifications and CRLs.
The system genesis block is provided to the orderers at their setup phase,
and allows them to authenticate channel creation requests. Orderers would
reject the system genesis block, if the latter includes two MSPs with the same
identifier, and consequently the bootstrapping of the network would fail.

For application channels, the verification components of only the MSPs that
govern a channel need to reside in the channel's genesis block. We emphasize
that it is **the responsibility of the application** to ensure that correct
MSP configuration information is included in the genesis blocks (or the
most recent configuration block) of a channel prior to instructing one or
more of their peers to join the channel.

When bootstrapping a channel with the help of the configtxgen tool, one can
configure the channel MSPs by including the verification parameters of MSP
in the mspconfig folder, and setting that path in the relevant section in
``configtx.yaml``.

*Reconfiguration* of an MSP on the channel, including announcements of the
certificate revocation lists associated to the CAs of that MSP is achieved
through the creation of a ``config_update`` object by the owner of one of the
administrator certificates of the MSP. The client application managed by the
admin would then announce this update to the channels in which this MSP appears.

Best Practices
--------------

In this section we elaborate on best practices for MSP
configuration in commonly met scenarios.

**1) Mapping between organizations/corporations and MSPs**

We recommend that there is a one-to-one mapping between organizations and MSPs.
If a different type of mapping is chosen, the following needs to be to
considered:

- **One organization employing various MSPs.** This corresponds to the
  case of an organization including a variety of divisions each represented
  by its MSP, either for management independence reasons, or for privacy reasons.
  In this case a peer can only be owned by a single MSP, and will not recognize
  peers with identities from other MSPs as peers of the same organization. The
  implication of this is that peers may share through gossip organization-scoped
  data with a set of peers that are members of the same subdivision, and NOT with
  the full set of providers constituting the actual organization.
- **Multiple organizations using a single MSP.** This corresponds to a
  case of a consortium of organizations that are governed by similar
  membership architecture. One needs to know here that peers would propagate
  organization-scoped messages to the peers that have an identity under the
  same MSP regardless of whether they belong to the same actual organization.
  This is a limitation of the granularity of MSP definition, and/or of the peer’s
  configuration.

**2) One organization has different divisions (say organizational units), to**
**which it wants to grant access to different channels.**

Two ways to handle this:

- **Define one MSP to accommodate membership for all organization’s members**.
  Configuration of that MSP would consist of a list of root CAs,
  intermediate CAs and admin certificates; and membership identities would
  include the organizational unit (``OU``) a member belongs to. Policies can then
  be defined to capture members of a specific ``role`` (should be one of: peer, admin,
  client, orderer, member), and these policies may constitute the read/write policies
  of a channel or endorsement policies of a chaincode. Specifying custom OUs in
  the profile section of ``configtx.yaml`` is currently not configured.
  A limitation of this approach is that gossip peers would
  consider peers with membership identities under their local MSP as
  members of the same organization, and would consequently gossip
  with them organization-scoped data (e.g. their status).
- **Defining one MSP to represent each division**.  This would involve specifying for each
  division, a set of certificates for root CAs, intermediate CAs, and admin
  Certs, such that there is no overlapping certification path across MSPs.
  This would mean that, for example, a different intermediate CA per subdivision
  is employed. Here the disadvantage is the management of more than one
  MSPs instead of one, but this circumvents the issue present in the previous
  approach.  One could also define one MSP for each division by leveraging an OU
  extension of the MSP configuration.

**3) Separating clients from peers of the same organization.**

In many cases it is required that the “type” of an identity is retrievable
from the identity itself (e.g. it may be needed that endorsements are
guaranteed to have derived by peers, and not clients or nodes acting solely
as orderers).

There is limited support for such requirements.

One way to allow for this separation is to create a separate intermediate
CA for each node type - one for clients and one for peers/orderers; and
configure two different MSPs - one for clients and one for peers/orderers.
Channels this organization should be accessing would need , чтобы хранить
both MSPs, while endorsement policies will leverage only the MSP that
refers to the peers. This would ultimately result in the organization
being mapped to two MSP instances, and would have certain consequences
on the way peers and clients interact.

Gossip would not be drastically impacted as all peers of the same organization
would still belong to one MSP. Peers can restrict the execution of certain
system chaincodes to local MSP based policies. For
example, peers would only execute “joinChannel” request if the request is
signed by the admin of their local MSP who can only be a client (end-user
should be sitting at the origin of that request). We can go around this
inconsistency if we accept that the only clients to be members of a
peer/orderer MSP would be the administrators of that MSP.

Another point to be considered with this approach is that peers
authorize event registration requests based on membership of request
originator within their local MSP. Clearly, since the originator of the
request is a client, the request originator is always deemed to belong
to a different MSP than the requested peer and the peer would reject the
request.

**4) Admin and CA certificates.**

It is important to set MSP admin certificates to be different than any of the
certificates considered by the MSP for ``root of trust``, or intermediate CAs.
This is a common (security) practice to separate the duties of management of
membership components from the issuing of new certificates, and/or validation of existing ones.

**5) Blocking an intermediate CA.**

As mentioned in previous sections, reconfiguration of an MSP is achieved by
reconfiguration mechanisms (manual reconfiguration for the local MSP instances,
and via properly constructed ``config_update`` messages for MSP instances of a channel).
Clearly, there are two ways to ensure an intermediate CA considered in an MSP is no longer
considered for that MSP's identity validation:

1. Reconfigure the MSP to no longer include the certificate of that
   intermediate CA in the list of trusted intermediate CA certs. For the
   locally configured MSP, this would mean that the certificate of this CA is
   removed from the ``intermediatecerts`` folder.
2. Reconfigure the MSP , чтобы хранить a CRL produced by the root of trust
   which denounces the mentioned intermediate CA's certificate.

In the current MSP implementation we only support method (1) as it is simpler
and does not require blocking the no longer considered intermediate CA.

**6) CAs and TLS CAs**

MSP identities' root CAs and MSP TLS certificates' root CAs (and relative intermediate CAs)
need to be declared in different folders. This is to avoid confusion between
different classes of certificates. It is not forbidden to reuse the same
CAs for both MSP identities and TLS certificates but best practices suggest
to avoid this in production.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
