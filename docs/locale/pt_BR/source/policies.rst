Políticas no Hyperledger Fabric
===============================

A configuração de uma rede blockchain Hyperledger Fabric é gerenciada por políticas. Essas políticas geralmente residem na 
configuração do canal. O objetivo principal deste documento é explicar como as políticas são definidas e interagem com a 
configuração do canal. No entanto, as políticas também podem ser especificadas em alguns outros locais, como chaincodes, 
portanto, essas informações podem ser de interesse fora do escopo da configuração do canal.

O que é uma política?
---------------------

No nível mais básico, uma política é uma função que aceita como entrada um conjunto de dados assinados e avalia com sucesso,
ou retorna um erro porque algum aspecto dos dados assinados não satisfaz a política.

Mais concretamente, as políticas testam se o assinante ou assinantes de alguns dados atendem a alguma condição necessária 
para que essas assinaturas sejam consideradas 'válidas'. Isso é útil para determinar se as partes corretas concordaram com
uma transação ou alteração.

Por exemplo, uma política pode definir qualquer o seguinte: \* Administradores de 2 organizações das 5 possíveis devem assinar. 
\* Qualquer membro de qualquer organização deve assinar. \* Dois certificados específicos devem assinar.

É claro que esses são apenas exemplos, e outras regras mais poderosas podem ser construídas.

Tipos de política
-----------------

Atualmente, existem dois tipos diferentes de políticas implementadas:

1. **SignaturePolicy**: esse tipo de política é o mais poderoso e especifica uma combinação de regras de avaliação para
   MSP Principals . Ele suporta combinações arbitrárias de *AND*, *OR* e *NOutOf*, permitindo a construção de regras 
   extremamente poderosas como: "Um administrador da organização A e 2 outros administradores ou 11 de 20 administradores da 
   organização".
2. **ImplicitMetaPolicy**: esse tipo de política é menos flexível que SignaturePolicy e é válido apenas no contexto da configuração. 
   Ele agrega o resultado da avaliação de políticas mais profundas na hierarquia de configuração, que são definidas em última análise 
   por SignaturePolicies. Ele suporta boas regras padrão, como "A maioria das políticas de administração da organização".

As políticas são codificadas em uma mensagem ``common.Policy``, conforme definido em ``fabric-protos/common/policy.proto``. 
Eles são definidos pelo seguinte mensagem:

::

    message Policy {
        enum PolicyType {
            UNKNOWN = 0; // Reserved to check for proper initialization
            SIGNATURE = 1;
            MSP = 2;
            IMPLICIT_META = 3;
        }
        int32 type = 1; // For outside implementors, consider the first 1000 types reserved, otherwise one of PolicyType
        bytes policy = 2;
    }

Para codificar a política, basta escolher o tipo de política ``SIGNATURE`` ou ``IMPLICIT_META``, defina-o no campo ``type`` e empacote
a implementação de política correspondente no ``policy``.

Configuração e políticas
------------------------

A configuração do canal é expressa como uma hierarquia de grupos de configurações, cada um dos quais com um conjunto de valores e políticas 
associados a eles. Para um canal de aplicativo configurado validamente com duas organizações de aplicativos e uma organização de ordens, a 
configuração é minimamente da seguinte maneira:

::

    Channel:
        Policies:
            Readers
            Writers
            Admins
        Groups:
            Orderer:
                Policies:
                    Readers
                    Writers
                    Admins
                Groups:
                    OrdereringOrganization1:
                        Policies:
                            Readers
                            Writers
                            Admins
            Application:
                Policies:
                    Readers
    ----------->    Writers
                    Admins
                Groups:
                    ApplicationOrganization1:
                        Policies:
                            Readers
                            Writers
                            Admins
                    ApplicationOrganization2:
                        Policies:
                            Readers
                            Writers
                            Admins

Considere a política de Escrita (Writers) mencionada com a marca ``------->`` no exemplo acima. Esta política pode ser referida pela notação
abreviada ``/Channel/Application/Writers``. Observe que os elementos semelhantes aos componentes de diretório são nomes de grupos, enquanto 
o último componente semelhante a um nome de arquivo é o nome da política.

Diferentes componentes do sistema se referirão a esses nomes de política. Por exemplo, para chamar ``Deliver`` no ordenador, a assinatura na 
solicitação deve atender à política ``/Channel/Readers``. No entanto, para a comunicação com um nó par, será necessário que a política 
``/Channel/Application/Readers`` seja cumprida.

Ao definir essas políticas diferentes, o sistema pode ser configurado com controles de acesso avançados.

Construindo uma SignaturePolicy
------------------------------

Como em todas as políticas, o SignaturePolicy é expresso como protobuf.

::

    message SignaturePolicyEnvelope {
        int32 version = 1;
        SignaturePolicy policy = 2;
        repeated MSPPrincipal identities = 3;
    }

    message SignaturePolicy {
        message NOutOf {
            int32 N = 1;
            repeated SignaturePolicy policies = 2;
        }
        oneof Type {
            int32 signed_by = 1;
            NOutOf n_out_of = 2;
        }
    }

A chave ``SignaturePolicyEnvelope`` define uma versão (atualmente apenas ``0`` é suportada), um conjunto de identidades expressas como 
``MSPPrincipal``\ s e uma ``policy`` que define a regra de política, referenciando as ``identities`` por índice. Para obter mais detalhes 
sobre como especificar MSP Principals, consulte a seção MSP Principals.

O ``SignaturePolicy`` é uma estrutura de dados recursiva que representa um único requisito de assinatura de um ``MSPPrincipal`` específico 
ou uma coleção de ``SignaturePolicy``\ s, exigindo que ``N`` deles sejam atendidos. .

Por exemplo:

::

    SignaturePolicyEnvelope{
        version: 0,
        policy: SignaturePolicy{
            n_out_of: NOutOf{
                N: 2,
                policies: [
                    SignaturePolicy{ signed_by: 0 },
                    SignaturePolicy{ signed_by: 1 },
                ],
            },
        },
        identities: [mspP1, mspP2],
    }

Isso define uma política de assinatura sobre os principais MSP ``mspP1`` e ``mspP2``. Requer que exista tanto uma assinatura que satisfaça 
``mspP1``, quanto uma assinatura que satisfaça `` mspP2``.

Como um exemplo mais complexo:

::

    SignaturePolicyEnvelope{
        version: 0,
        policy: SignaturePolicy{
            n_out_of: NOutOf{
                N: 2,
                policies: [
                    SignaturePolicy{ signed_by: 0 },
                    SignaturePolicy{
                        n_out_of: NOutOf{
                            N: 1,
                            policies: [
                                SignaturePolicy{ signed_by: 1 },
                                SignaturePolicy{ signed_by: 2 },
                            ],
                        },
                    },
                ],
            },
        },
        identities: [mspP1, mspP2, mspP3],
    }

Isso define uma política de assinatura sobre os usuários do MSP ``mspP1``,``mspP2`` e ``mspP3``. Requer uma assinatura que satisfaça ``mspP1`` 
e outra assinatura que satisfaça ``mspP2`` ou ``mspP3``.

Espero que esteja claro que uma lógica complicada e relativamente arbitrária pode ser expressa usando o tipo de política SignaturePolicy. Para 
um código que construa uma política de assinatura, consulte ``fabric/common/cauthdsl/cauthdsl_builder.go``.

---------

**Limitações**: Ao avaliar uma política de assinatura em relação a um conjunto de assinaturas, as assinaturas são 'consumidas', na ordem em 
que aparecem, independentemente de satisfazerem vários princípios de política.

Por exemplo. Considere uma política que exija

::

 2 of [org1.Member, org1.Admin]

A intenção desta política ingênua é exigir que um administrador e um membro assinem. Para o conjunto de assinaturas

::

 [org1.MemberSignature, org1.AdminSignature]

a política é avaliada como verdadeira, exatamente como esperado. No entanto, considere o conjunto de assinaturas

::

 [org1.AdminSignature, org1.MemberSignature]

Este conjunto de assinaturas não atende à política. Essa falha ocorre porque quando ``org1.AdminSignature`` satisfaz a função, ``org1.Member``, 
é considerado 'consumido' pelo requisito ``org1.Member``. Como o principal ``org1.Admin`` não pode ser satisfeito pelo ``org1.MemberSignature``, 
a política é avaliada como falsa.

Para evitar essa armadilha, as identidades devem ser especificadas da mais privilegiada para a menos privilegiada na especificação de 
identidades de política e as assinaturas devem ser ordenadas da menos privilegiada para a mais privilegiada no conjunto de assinaturas.

MSP Principals
--------------

O MSP Principal é uma noção generalizada de identidade criptográfica. Embora a estrutura MSP seja projetada para trabalhar com outros tipos 
de criptografia que não sejam o X.509, para os fins deste documento, a discussão assumirá que a implementação do MSP subjacente é o tipo 
padrão do MSP, com base na criptografia X.509.

Um MSP Principal é definido em ``fabric-protos/msp_principal.proto`` como segue:

::

    message MSPPrincipal {

        enum Classification {
            ROLE = 0;
            ORGANIZATION_UNIT = 1;
            IDENTITY  = 2;
        }

        Classification principal_classification = 1;

        bytes principal = 2;
    }

O ``principal_classification`` deve ser definido como ``ROLE`` ou ``IDENTITY``. A ``ORGANIZATIONAL_UNIT`` não está implementado no momento 
da redação deste documento.

No caso de ``IDENTITY``, o campo ``principal`` é definido como os bytes de um literal de certificado.

No entanto, mais comumente o tipo ``ROLE`` é usado, pois permite que a identidade corresponda a muitos certificados diferentes emitidos pela 
autoridade de certificação do MSP.

No caso de ``ROLE``, o ``principal`` é uma mensagem ``MSPRole`` empacotada, definida da seguinte forma:

::

   message MSPRole {
       string msp_identifier = 1;

       enum MSPRoleType {
           MEMBER = 0; // Represents an MSP Member
           ADMIN  = 1; // Represents an MSP Admin
           CLIENT = 2; // Represents an MSP Client
           PEER = 3; // Represents an MSP Peer
       }

       MSPRoleType role = 2;
   }

O ``msp_identifier`` é definido como o ID do MSP (conforme definido pelo proto ``MSPConfig`` na configuração do canal para uma organização) 
que avaliará a assinatura e o ``Papel`` será definido como ``MEMBER``, ``ADMIN``, ``CLIENT`` ou ``PEER``. Em particular:

1. ``MEMBER`` corresponde a qualquer certificado emitido pelo MSP.
2. ``ADMIN`` corresponde aos certificados enumerados como admin na definição do MSP.
3. ``CLIENT`` (``PEER``) corresponde aos certificados que carregam a unidade organizacional do cliente (par).

(consulte `Documentação do MSP <http://hyperledger-fabric.readthedocs.io/en/latest/msp.html>`_)

Construindo uma ImplicitMetaPolicy
----------------------------------

A ``ImplicitMetaPolicy`` é definida como valida apenas no contexto da configuração do canal. É ``Implicit`` porque é construído implicitamente 
com base na configuração atual, e é ``Meta`` porque sua avaliação não é contra princípios do MSP, mas contra outras políticas. É definido em 
``fabric-protos/common/policies.proto`` da seguinte forma:

::

    message ImplicitMetaPolicy {
        enum Rule {
            ANY = 0;      // Requires any of the sub-policies be satisfied, if no sub-policies exist, always returns true
            ALL = 1;      // Requires all of the sub-policies be satisfied
            MAJORITY = 2; // Requires a strict majority (greater than half) of the sub-policies be satisfied
        }
        string sub_policy = 1;
        Rule rule = 2;
    }

Por exemplo, considere uma política definida em ``/Channel/Readers`` como

::

    ImplicitMetaPolicy{
        rule: ANY,
        sub_policy: "foo",
    }

Essa política selecionará implicitamente os subgrupos de ``/Channel``, neste caso, ``Application`` e ``Orderer``, e recuperará a política do 
nome ``foo``, para fornecer as políticas ``/Channel/Application/foo`` e ``/Channel/Orderer/foo``. Em seguida, quando a política for avaliada, 
ele verificará se ``ANY`` dessas duas políticas será avaliada sem erros. Se a regra fosse ``ALL``, seriam necessárias ambas.

Considere outra política definida em ``/Channel/Application/Writers``, onde existem três organizações de aplicativos definidas, ``OrgA``, 
``OrgB`` e ``OrgC``.

This policy will implicitly select the sub-groups of ``/Channel``, in
this case, ``Application`` and ``Orderer``, and retrieve the policy of
name ``foo``, to give the policies ``/Channel/Application/foo`` and
``/Channel/Orderer/foo``. Then, when the policy is evaluated, it will
check to see if ``ANY`` of those two policies evaluate without error.
Had the rule been ``ALL`` it would require both.

Consider another policy defined at ``/Channel/Application/Writers``
where there are 3 application orgs defined, ``OrgA``, ``OrgB``, and
``OrgC``.

::

    ImplicitMetaPolicy{
        rule: MAJORITY,
        sub_policy: "bar",
    }

Nesse caso, as políticas coletadas seriam ``/Channel/Application/OrgA/bar``, ``/Channel/Application/OrgB/bar`` e ``/Channel/Application/OrgC/bar``. 
Como a regra exige ``MAJORITY``, essa política exigirá que duas das três políticas de ``bar`` da organização sejam atendidas.

Padrões de política
-------------------

A ferramenta ``configtxgen`` usa políticas que devem ser especificadas explicitamente em configtx.yaml.

Observe que as políticas mais altas na hierarquia são definidas como ``ImplicitMetaPolicy``\s, enquanto os nós de folha necessariamente são 
definidos como ``SignaturePolicy``\s. Esse conjunto de padrões funciona bem porque as ``ImplicitMetaPolicies`` não precisam ser redefinidas 
à medida que o número de organizações muda, e as organizações individuais podem escolher suas próprias regras e limites para o que significa 
ser um leitor, gravador e Admin.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

