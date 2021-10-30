하이퍼레저 패브릭 빌드하기
--------------------------

다음 지시는 여러분이 :doc:`개발 환경 <devenv>` 을 이미 설정했다고
가정합니다.

하이퍼레저 패브릭을 빌드하기 위해서는:

::

    make dist-clean all

문서 빌드
~~~~~~~~~

여러분이 문서에 기여하고 있다면, 여러분의 로컬 시스템 상에서 패브릭 문서를
빌드할 수 있습니다. 이는 여러분이 풀 리퀘스트를 열기 전에 웹 브라우저를
사용해서 여러분의 변경 사항의 형식을 확인할 수 있도록 합니다.

문서를 빌드하기 전에 다음 사전 필요 사항을 다운로드해야 합니다:

- `Python 3.7 <https://wiki.python.org/moin/BeginnersGuide/Download>`__
- `Pipenv <https://pipenv.readthedocs.io/en/latest/#install-pipenv-today>`__

여러분의 문서 소스 파일을 업데이트하고 나서, 다음 명령을 실행해서 여러분의
변경 사항을 포함하는 빌드를 생성할 수 있습니다:

::

    cd fabric/docs
    pipenv install
    pipenv shell
    make html

이는 ``docs/build/html`` 폴더 안에 모든 html 파일을 생성할 겁니다. 여러분은
브라우저로 어느 파일이든 업데이트된 문서를 열어 보기 시작할 수 있습니다.
문서에 추가적으로 편집하고 싶으면 그 수정 사항을 포함하기 위해 다시
``make html`` 할 수 있습니다.

유닛 테스트 실행
~~~~~~~~~~~~~~~~

모든 유닛 테스트를 실행하려면 다음 명령을 사용하세요:

::

    make unit-test

몇몇 테스트만 실행하고 싶으면, TEST_PKGS 환경 변수를 설정하세요.
패키지 리스트를 (공백으로 구분해서) 지정하세요. 예를 들면:

::

    export TEST_PKGS="github.com/hyperledger/fabric/core/ledger/..."
    make unit-test

특정 테스트를 실행하기 위해서는 ``-run RE`` 플래그를 사용하세요. 여기서
RE는 테스트 케이스 이름에 맞는 정규식입니다. 상세한 출력으로 테스트를
실행하려면 ``-v`` 플래그를 사용하세요. 예를 들어, ``TestGetFoo`` 테스트
케이스를 실행하려면, ``foo_test.go`` 를 포함하는 디렉토리로 들어가서
다음을 호출/실행하세요.

::

    go test -v -run=TestGetFoo


Node.js 클라이언트 SDK 유닛 테스트 실행
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Node.js 클라이언트 SDK가 여러분의 변경으로 깨지지 않았음을 확인하기 위해서
Node.js 유닛 테스트 또한 실행해야 합니다. Node.js 유닛 테스트를 실행하려면
`여기 <https://github.com/hyperledger/fabric-sdk-node/blob/master/README.md>`__
의 지시를 따르세요.

환경 설정
---------

환경 설정은 `viper <https://github.com/spf13/viper>`__ 와
`cobra <https://github.com/spf13/cobra>`__ 라이브러리를 활용합니다.

피어 프로세스를 위한 환경 설정을 포함하는 **core.yaml** 파일이 있습니다.
많은 설정 값들이 그 설정 값들에 맞는 *'CORE\_'* 로 시작하는 환경 변수를
설정함으로써 커맨드 라인 상에서 덮어씌워질 수 있습니다. 예를 들어,
`peer.networkId` 설정은 다음으로 가능합니다:

::

    CORE_PEER_NETWORKID=custom-network-id peer

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
