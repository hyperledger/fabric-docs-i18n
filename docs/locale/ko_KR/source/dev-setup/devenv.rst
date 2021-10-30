개발 환경 설정하기
------------------

사전 필요 사항
~~~~~~~~~~~~~~

-  `Git 클라이언트 <https://git-scm.com/downloads>`__
-  `Go <https://golang.org/dl/>`__ 버전 1.15.x
-  `도커 <https://docs.docker.com/get-docker/>`__ 버전 18.03 또는 그 이상
-  (맥OS) `Xcode 커맨드 라인 도구 <https://developer.apple.com/downloads/>`__
-  `SoftHSM <https://github.com/opendnssec/SoftHSMv2>`__
-  `jq <https://stedolan.github.io/jq/download/>`__


절차
~~~~

사전 필요 사항 설치
^^^^^^^^^^^^^^^^^^^

맥OS를 위해 저희는 개발 사전 필요 사항을 관리하는데 `Homebrew <https://brew.sh>`__ 를
사용하기를 권합니다. Xcode 커맨드 라인 도구는 Homebrew 설치의 일부로 설치될 겁니다.

Homebrew가 준비되면 사전 필요 사항을 설치하는 것은 매우 쉽습니다:

::

    brew install git go jq softhsm
    brew cask install --appdir="/Applications" docker

도커 데스크탑은 설치 완료를 위해 반드시 실행되어야 하므로 설치 후에 실행하는 것을
잊지 마세요:

::

    open /Applications/Docker.app

윈도우즈 상에서 개발하기
~~~~~~~~~~~~~~~~~~~~~~~~

윈도우즈 10 상에서 여러분은 네이티브 도커 배포판을 사용하면서,
윈도우즈 파워쉘을 사용할 수 있습니다. 그러나, ``binaries`` 명령이
잘 실행되려면 ``uname`` 명령이 계속 잘 실행되어야 할 겁니다.
여러분은 Git의 일부로 이를 얻을 수 있습니다만, 64비트 버전만
지원함을 알아두세요.

``git clone`` 명령을 실행하기 전에, 다음을 실행하세요:

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

다음 명령으로 이 파라미터들이 잘 설정되었는지 확인할 수 있습니다:

::

    git config --get core.autocrlf
    git config --get core.longpaths

이들은 각각 ``false`` 그리고 ``true`` 여야 합니다.

Git과 도커 도구상자로부터 받는 ``curl`` 명령은 오래되어서
:doc:`../getting_started` 내에서 사용된 리다이렉션을 제대로 처리하지
않습니다. 여러분이 `cURL 다운로드 페이지
<https://curl.haxx.se/download.html>`__ 에서 받을 수 있는
더 최신 버전을 사용하는지 꼭 확인하세요.

하이퍼레저 패브릭 소스코드 복제
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

먼저 https://github.com/hyperledger/fabric 에 들어가서 오른쪽 위 코너에 있는
fork 버튼을 사용해서 fabric 저장소를 포크하세요. 포크 후에는 이 저장소를
복제하세요.

::

    mkdir -p github.com/<여러분의_github_userid>
    cd github.com/<여러분의_github_userid>
    git clone https://github.com/<여러분의_github_userid>/fabric

.. note::
    윈도우즈를 사용 중이라면, 저장소를 복제하기 전에 다음 명령을 실행하세요:

    ::

        git config --get core.autocrlf

    ``core.autocrlf`` 이 ``true`` 로 설정되어 있으면, 다음을 실행해서 반드시 ``false``
    로 설정하세요:

    ::

        git config --global core.autocrlf false


SoftHSM 설정
^^^^^^^^^^^^

PKCS #11 암호화 토큰 구현이 유닛 테스트를 돌리는데 필요합니다. PKCS #11 API는
패브릭의 bccsp 컴포넌트가 암호화 정보를 저장하고, 암호화 계산을 수행하는
하드웨어 보안 모듈 (HSM: Hardware security modules) 과 통신하는데 사용됩니다.
테스트 환경에서는 SoftHSM이 이 요구사항을 만족시킬 수 있습니다.

SoftHSM은 사용 전에 일반적으로 추가 설정이 필요합니다. 예를 들면, 기본 설정은
권한이 없는 사용자가 저장할 수 없는 시스템 디렉토리 내에 토큰 데이터를
저장하려고 시도할 겁니다.

SoftHSM 설정은 보통 ``/etc/softhsm2.conf`` 를 ``$HOME/.config/softhsm2/softhsm2.conf``
로 복사하고 ``directories.tokendir`` 를 적당한 위치로 바꾸는 것을 포함합니다.
자세한 사항은 ``softhsm2.conf`` 의 man 페이지를 보세요.

SoftHSM이 설정되고 난 후에, 다음 명령이 유닛 테스트에 필요한 토큰을 초기화하는데
사용될 수 있습니다.

::

    softhsm2-util --init-token --slot 0 --label "ForFabric" --so-pin 1234 --pin 98765432

테스트가 여러분의 환경에서 libsofthsm2.so를 찾지 못한다면, 라이브러리 경로, PIN,
그리고 여러분의 토큰 레이블을 적절한 환경 변수 내에 지정하세요.
맥OS를 예로 들면:

::

    export PKCS11_LIB="/usr/local/Cellar/softhsm/2.6.1/lib/softhsm/libsofthsm2.so"
    export PKCS11_PIN=98765432
    export PKCS11_LABEL="ForFabric"

개발 도구 설치
^^^^^^^^^^^^^^

저장소를 복제하고 나면, 여러분은 개발 환경에서 사용되는 몇가지 도구를 설치하기
위해 ``make`` 를 사용할 수 있습니다. 기본적으로 이 도구들은 ``$HOME/go/bin`` 내에
설치될 겁니다. 여러분의 ``PATH`` 가 이 디렉토리를 포함하고 있는지 확인하세요.

::

    make gotools

도구들을 설치하고 나서, 몇가지 명령을 실행해서 빌드 환경을 검증할 수 있습니다.

::

    make basic-checks integration-test-prereqs
    ginkgo -r ./integration/nwo

이 명령들이 완전히 성공하면 출발할 준비가 된 겁니다!

하이퍼레저 패브릭 애플리케이션 SDK를 사용하려고 한다면,
Node.js SDK `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__ 와
Java SDK `README <https://github.com/hyperledger/fabric-gateway-java/blob/master/README.md>`__ 내의
사전 필요 사항도 확인하는 것을 잊지 마세요.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
