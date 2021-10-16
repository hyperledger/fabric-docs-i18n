사전 필요 사항
==============

시작 전에, 여러분이 하이퍼레저 패브릭을 실행하려고 하는 플랫폼 상에 아래의 사전 필요 사항 모두가 설치되었는지 확인하는 것이 좋습니다.

.. note:: 이 사전 필요 사항은 패브릭 사용자를 위해 권장합니다. 여러분이 패브릭 개발자라면 :doc:`dev-setup/devenv` 의 지시를 참고하세요.

Git 설치
--------

설치되어 있지 않거나, curl 명령을 실행하는데 문제가 있다면,
`git <https://git-scm.com/downloads>`_ 의 최신 버전을 다운로드하세요.

cURL 설치
---------

설치되어 있지 않거나, 문서의 curl 명령을 실행하는데 에러가 난다면,
`cURL <https://curl.haxx.se/download.html>`__ 도구의 최신 버전을
다운로드하세요.

.. note:: 윈도우즈를 사용 중이라면, 아래 `windows-extras`_ 상에 지정된
   주석을 보세요.

도커(Docker)와 도커 컴포즈(Docker Compose)
------------------------------------------

여러분이 하이퍼레저 패브릭을 운영하거나 개발할 플랫폼 상에 다음 설치가
필요할 겁니다:

  - 맥 OS X(MacOSX), \*nix, 또는 윈도우즈(Windows) 10: `Docker <https://www.docker.com/get-docker>`__
    도커 버전 17.06.2-ce 또는 그 이상이 필요합니다.
  - 이전 버전의 윈도우즈: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ -
    다시, 도커 버전 17.06.2-ce 또는 그 이상이 필요합니다.

터미널 프롬프트 상에서 다음 명령으로 여러분이 설치했던 도커의 버전을 확인할
수 있습니다:

.. code:: bash

  docker --version

.. note:: 다음은 systemd를 실행하는 리눅스 시스템에 적용됩니다.

도커 데몬(daemon)이 실행 중인지 확인하세요.

.. code:: bash

  sudo systemctl start docker

선택 사항: 시스템이 시작할 때 도커 데몬을 실행하길 원한다면, 다음을 사용하세요:

.. code:: bash

  sudo systemctl enable docker

그리고 여러분의 사용자를 도커 그룹에 추가하세요.

.. code:: bash

  sudo usermod -a -G docker <username>

.. note:: 맥이나 윈도우즈의 도커 설치 또는 도커 툴 박스는 도커 컴포즈도 설치할
          겁니다. 여러분이 이미 도커를 설치했다면 1.14.0이나 그 이상 버전의
          도커 컴포즈가 설치되어 있는지 확인해야 합니다. 아니라면, 더 최근
          버전의 도커를 설치하기를 권합니다.

터미널 프롬프트 상에서 다음 명령으로 여러분이 설치한 도커 컴포즈의 버전을
확인할 수 있습니다:

.. code:: bash

  docker-compose --version

.. _windows-extras:

윈도우즈만의 추가 사항
----------------------

윈도우즈 10 상에서 여러분은 네이티브 도커 배포판을 사용해야 하면서
Windows PowerShell을 사용할 수 있습니다. 그러나 ``binaries`` 명령이
성공하려면 ``uname`` 명령이 사용 가능해야 할 겁니다. 이를 Git의 일부로
얻을 수 있는데 64비트 버전만 지원함을 알고 계세요.

``git clone`` 명령을 실행하기 전에, 다음 명령을 실행하세요:

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

다음 명령으로 이 파라미터들의 설정을 확인할 수 있습니다:

::

    git config --get core.autocrlf
    git config --get core.longpaths

이들은 각각 ``false`` 와 ``true`` 여야 합니다.

Git과 도커 컴포즈에 있는 ``curl`` 명령은 오래되었고,
:doc:`getting_started` 내에 사용된 리다이렉트(redirect)를 제대로
처리하지 못합니다. `cURL 다운로드 페이지
<https://curl.haxx.se/download.html>`__ 에서 다운로드 받을 수 있는
더 최신 버전을 사용하는지 확인하세요.

.. note:: 이 문서에서 다루지 않는 문의 사항, 또는 튜토리얼 상의 문제가 있다면,
          추가적인 도움을 어디서 찾을지에 대한 팁을 위해 :doc:`questions` 페이지를
          방문해 보세요.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
