시작하기
========

.. toctree::
   :maxdepth: 1
   :hidden:

   prereqs
   install
   test_network

시작하기 전에, 아직 아래의 것을 하지 않았다면, 여러분이 블록체인
애플리케이션을 개발하거나 하이퍼레저 패브릭을 운영하려고 하는 플랫폼 상에
:doc:`prereqs` 이 모두 설치되어 있는지 확인하는 것이 좋습니다.

사전 필요 사항을 설치하고 나면, 여러분은 하이퍼레저 패브릭을 다운로드하고
설치할 준비가 됩니다. 우리가 패브릭 바이너리를 위한 실제 설치 프로그램을
개발하는 동안, 여러분의 시스템에 :doc:`install` 위한 스크립트를 제공합니다.
이 스크립트는 또한 여러분의 로컬 레지스트리에 도커 이미지를 다운로드할
겁니다.

시스템에 패브릭 샘플과 도커 이미지를 다운로두 한 후, :doc:`test_network`
튜토리얼과 함께 패브릭 작업을 시작할 수 있습니다.

하이퍼레저 패브릭 스마트 컨트랙트 (체인코드) API
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

하이퍼레저 패브릭은 스마트 컨트랙트 (체인코드) 개발을 지원하는 수많은 API를
다양한 언오로 제공합니다. 스마트 컨트랙트 API는 Go, Node,js, 그리고 Java로
이용 가능합니다.

  * `Go contract-api <https://github.com/hyperledger/fabric-contract-api-go>`__.
  * `Node.js contract API <https://github.com/hyperledger/fabric-chaincode-node>`__ 와 `Node.js contract API 문서 <https://hyperledger.github.io/fabric-chaincode-node/>`__.
  * `Java contract API <https://github.com/hyperledger/fabric-chaincode-java>`__ 와 `Java contract API 문서 <https://hyperledger.github.io/fabric-chaincode-java/>`__.

하이퍼레저 패브릭 애플리케이션 SDK
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

하이퍼레저 패브릭은 애플리케이션 개발을 지원하는 수많은 SDK를 다양한 언어로
제공합니다. SDK는 Node.js와 Java로 이용 가능합니다.

  * `Node.js SDK <https://github.com/hyperledger/fabric-sdk-node>`__ 와 `Node.js SDK 문서 <https://hyperledger.github.io/fabric-sdk-node/>`__.
  * `Java SDK <https://github.com/hyperledger/fabric-gateway-java>`__ 와 `Java SDK 문서 <https://hyperledger.github.io/fabric-gateway-java/>`__.

  SDK로의 개발을 위한 사전 필요 사항은 Node.js SDK `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__ 와 Java SDK `README <https://github.com/hyperledger/fabric-gateway-java/blob/master/README.md>`__ 내에서 찾을 수 있습니다.

추가로, 공식으로 릴리즈되지 않은 (Python과 Go를 위한) 두가지 더 많은 애플리케이션 SDK가 있습니다만, 다운로드해서 테스트해볼 수 있습니다.

  * `Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.

현재 Node.js, Java, Go는 하이퍼레저 패브릭 v1.4에서 도입된 새로운 애플리케이션 모델을 지원합니다.

하이퍼레저 패브릭 CA
^^^^^^^^^^^^^^^^^^^^

하이퍼레저 패브릭은 인증서(certificates)와 키 자료(key material)를 생성하고 여러분의 블록체인 네트워크 내의 신원(identity)을 관리하는 `certificate authority service <http://hyperledger-fabric-ca.readthedocs.io/en/latest>`_ 를 옵션으로 제공합니다. 그러나 ECDSA 인증서를 생성할 수 있는 어떤 CA도 사용 가능합니다.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
