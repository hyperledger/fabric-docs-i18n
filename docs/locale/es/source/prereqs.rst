Prerrequisitos
=============

Antes de comenzar, deberá confirmar que ha instalado todos los prerrequisitos indicados a continuación en la plataforma en la cual se ejecutará Hyperledger Fabric.

.. note:: Estos prerrequisitos se recomiendan para los usuarios de Fabric. Si usted es un desarrollador de Fabric, debe consultar las instrucciones para :doc:`dev-setup/devenv`.

Instalación de Git
-----------
Descarga la última versión de `git
<https://git-scm.com/downloads>`_ si aún no está instalado,
o si tienes problemas para ejecutar los comandos de cURL.

Instalación de cURL
------------

Descarga la última versión de la herramienta `cURL
<https://curl.haxx.se/download.html>`__ si aún no está instalado o si se producen errores al ejecutar los comandos de la documentación de cURL.


.. note:: Si está en Windows, consulte la nota específica a continuación `Windows
   extras`_.

Docker y Docker Compose
-------------------------


Necesitará lo siguiente instalado en la plataforma en la cual estará operando o desarrollando en (o para) Hyperledger Fabric:

  - MacOSX, \*nix, o Windows 10: `Docker <https://www.docker.com/get-docker>`__
    Docker version 17.06.2-ce o superior es requerida.
  - Versiones anteriores de Windows: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ -
    nuevamente, Docker version Docker 17.06.2-ce o superior es requerida.


Puede comprobar la versión de Docker que ha instalado con el siguiente
comando desde la terminal:

.. code:: bash

  docker --version

.. note:: Lo siguiente aplica para los sistemas Linux que ejecutan systemd.

Asegúrese de que el docker daemon se encuentre en ejecución.

.. code:: bash

  sudo systemctl start docker

Opcional: Si desea que el docker daemon se inicialicé cuando comienza el sistema de arranque, utilice lo siguiente:

.. code:: bash

  sudo systemctl enable docker

Agregue el usuario al grupo de docker.

.. code:: bash

  sudo usermod -a -G docker <username>

.. note:: La instalación de Docker para Mac o Windows, o Docker Toolbox también
          instalará Docker Compose. Si Docker ya se encuentra instalado, deberá 
          comprobar que ya cuenta con Docker Compose version 1.14.0 o superior 
          instalado. De no ser así, le recomendamos que instale una versión más 
          reciente de Docker.

Puede comprobar la versión de Docker Compose que ha instalado con el siguiente
comando desde la terminal:

.. code:: bash

  docker-compose --version

.. _windows-extras:

Extras para Windows
--------------

En Windows 10, debe usar la distribución nativa de Docker y
puede utilizar el PowerShell de Windows. Sin embargo, para los comando
``binaries`` para tener éxito aún necesitará tener el comando ``uname``
disponible. Puede obtenerlo como parte de Git, pero tenga en cuenta que 
únicamente la versión de 64 bits está soportada.

Antes de la ejecución de comandos ``git clone``, ejecute los siguientes comandos:

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

Puede comprobar la configuración de estos parámetros con los siguientes comandos:

::

    git config --get core.autocrlf
    git config --get core.longpaths

Estos necesitan ser ``false`` y ``true`` respectivamente.

El comando ``curl`` que viene con Git y Docker Toolbox es antiguo y
no maneja correctamente el redireccionamiento utilizado en
:doc:`getting_started`. Asegúrese de tener y utilizar una versión más reciente
que puede descargar desde la página de descargas de `cURL
<https://curl.haxx.se/download.html>`__

.. note:: Si tiene preguntas que no se tratan en esta documentación, o se encuentra con
          problemas con cualquiera de los tutoriales, por favor visite la página de :doc:`questions` para obtener algunos consejos sobre dónde encontrar ayuda adicional.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
