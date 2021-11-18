샘플, 바이너리, 도커 이미지 설치
================================

저희가 하이퍼레저 패브릭 바이너리의 진짜 인스톨러를 개발하는 동안,
여러분의 시스템에 샘플과 바이너리를 다운로드하고 설치할 스크립트를
제공합니다. 우리는 여러분이 하이퍼레저 패브릭의 능력과 운영에 대해
더 많이 배우는데 유용할 설치된 샘플 애플리케이션을 찾을거라고
생각합니다.


.. note:: 여러분이 **윈도우즈** 를 사용 중이라면, 아래 나올 터미널 명령에
    도커 퀵스타트 터미널을 사용하길 원할 겁니다.
          이전에 이를 설치한 적 없다면 :doc:`prereqs` 로 가보세요.

          도커 툴 박스나 맥OS를 사용 중이라면, 샘플을 설치하고 실행할 때
          ``/Users`` (맥OS) 아래의 위치를 사용해야 할 겁니다.

          맥용 도커를 사용 중이라면, ``/Users``, ``/Volumes``, ``/private``, 나
          ``/tmp`` 아래의 위치를 사용해야 할 겁니다. 다른 위치를 사용하려면
          `파일 공유 <https://docs.docker.com/docker-for-mac/#file-sharing>`__ 를 위한
          도커 문서를 참고하세요.

          윈도우즈용 도커를 사용 중이라면, `공유 드라이브 <https://docs.docker.com/docker-for-windows/#shared-drives>`__ 를
          위한 도커 문서를 참고하시고, 공유 드라이브 하나 아래의 위치를 사용하세요.

여러분의 시스템 상에 `fabric-samples` 을 두길 원하는 위치를 결정하고 터미널 윈도우에서
그 디렉토리로 들어가세요. 아래의 단계를 그 아래의 명령들이 수행합니다:

#. 필요하다면 `hyperledger/fabric-samples <https://github.com/hyperledger/fabric-samples>`_ 저장소를 복제하세요.
#. 적절한 버전 태그를 체크아웃하세요.
#. 하이퍼레저 패브릭 플랫폼 종속적 바이너리와 지정된 버전의 설정 파일들을
   fabric-samples의 /bin 과 /config 디렉토리에 설치하세요.
#. 지정된 버전의 하이퍼레저 패브릭 도커 이미지를 다운로드하세요.

준비가 끝나면, 패브릭 샘플과 바이너리를 설치할 디렉토리 내에서 바이너리와
이미지를 내려받기 위해서 명령을 실행하세요.

.. note:: 최신 프로덕션 릴리즈를 원한다면, 모든 버전 지시자를 생략하세요.

.. code:: bash

  curl -sSL https://bit.ly/2ysbOFE | bash -s

.. note:: 특정 릴리즈를 원한다면, 패브릭과 패브릭-CA 도커 이미지에 버전 지시자를 넣으세요.
          아래 명령은 최신 프로덕션 릴리즈 - **패브릭 v2.2.4** 와 **패브릭 CA v1.5.2** -를
          어떻게 다운로드하는지 보입니다.

.. code:: bash

  curl -sSL https://bit.ly/2ysbOFE | bash -s -- <패브릭_버전> <패브릭-CA_버전>
  curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.4 1.5.2

.. note:: 위 curl 명령을 실행하는데 에러가 발생한다면, 여러분이 리다이렉트를
          처리하지 못하거나 미지원 환경인 오래된 curl 버전을
          사용하고 있을 수 있습니다.

    curl의 최신 버전을 찾거나 맞는 환경을 얻기 위한 추가 정보를 위해
    :doc:`prereqs` 페이지를 참고하세요. 아니면, 줄이지 않은 URL:
    https://raw.githubusercontent.com/hyperledger/fabric/{BRANCH}/scripts/bootstrap.sh 로
    바꿔도 됩니다.

.. note:: 다른 용도로의 사용을 위해서 패브릭 샘플 부트스트랩 스크립트의 도움말과 가능한 명령을
          보기 위해서 -h 플래그를 사용할 수 있습니다. 예를 들면:
          ``curl -sSL https://bit.ly/2ysbOFE | bash -s -- -h``

위의 명령은 여러분이 여러분의 네트워크를 구성하는데 필요한 모든 플랫폼
종속적 바이너리를 다운로드하고 압축을 해제하여 여러분이 위에서 생성한
복제 저장소 안에 두는 bash 스크립트를 다운로드하고 실행합니다. 다음
플랫폼 종속적 바이너리를 받습니다:

  * ``configtxgen``,
  * ``configtxlator``,
  * ``cryptogen``,
  * ``discover``,
  * ``idemixgen``
  * ``orderer``,
  * ``peer``,
  * ``fabric-ca-client``,
  * ``fabric-ca-server``

그리고 이를 현재 작업 디렉토리 아래 ``bin`` 디렉토리에 둡니다.

여러분의 PATH 환경 변수에 이를 추가해서 각 바이너리의 전체 경로를 쓰지 않고
사용할 수 있습니다. 예를 들면:

.. code:: bash

  export PATH=<다운로드한 위치>/bin:$PATH

마지막으로, 스크립트는 하이퍼레저 패브릭 도커 이미지를
`도커 허브 <https://hub.docker.com/u/hyperledger/>` 로부터 여러분의
도커 레지스트리에 다운로드하고 이를 'latest' 로 태그할 겁니다.

스크립트는 맨 마지막에 설치한 도커 이미지를 보여줄 겁니다.

각 이미지의 이름을 보세요; 이들은 우리의 하이퍼레저 패브릭 네트워크를
궁극적으로 구성할 컴포넌트들입니다. 또한 같은 이미지 ID의 두 인스턴스 -
하나는 "amd64-1.x.x", 다른 하나는 "latest" -가
있음을 알게될 겁니다. 1.2.0 이전에는 다운로드된 이미지가 ``uname -m`` 에
의해 결정되었고 "x86_64-1.x.x"라고 보여졌습니다.

.. note:: 다른 아키텍처에서는 여러분의 아키텍처를 식별하는 문자열로
          x86_64/amd64 가 바뀔 겁니다.

.. note:: 이 문서가 다루지 않는 질문이 있거나 이 튜토리얼에서 문제가 있으면,
          추가적인 도움을 받기 위해 :doc:`questions` 페이지로 가보세요.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
