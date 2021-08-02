Руководства
===========

Разработчики приложений могут использовать руководства Fabric на первом шаге разработки
собственных решений. Начните разработку в Fabric с запуска `тестовой сети <./test_network.html>`_
на своей локальной машине. Затем можете выполнить шаги, описанные в руководстве :doc:`deploy_chaincode`,
для запуска и тестирования смарт-контрактов. В руководстве :doc:`write_first_app`
рассказывается о том, как использовать API, предоставляемый Fabric SDK для вызова смарт-контрактов
из ваших клиентских приложений. За подробным обзором взаимодействия приложений Fabric и смарт-контрактов
обратитесь к главе :doc:`developapps/developing_applications`.

Операторы сети могут пользоваться руководством :doc:`deploy_chaincode` и серией руководств
:doc:`create_channel/create_channel_overview` для изучения важных аспектов
администрирования работающей сети. Руководства на темы `приватных данных <./private_data_tutorial.html>`_ и `CouchDB <./couchdb_tutorial.html>`_
могут использовать как операторы сети, так и разработчики приложений для изучения важных функций Fabric.
Когда вы будете готовы развернуть Hyperledger Fabric, ознакомьтесь с руководством :doc:`deployment_guide_overview`.

Для обновления канала есть следующие руководства: :doc:`config_update` и
:doc:`updating_capabilities`. Об обновлении компонентов, таких как одноранговые узлы,
узлы упорядочения, SDK и др., вы можете узнать в руководстве :doc:`upgrading_your_components`.

И, наконец, введение к написанию простейшего смарт-контракта содержится в руководстве :doc:`chaincode4ade`.

.. note:: Если у вас есть вопросы, которые не рассматриваются в этой документации, или
          вы столкнулись с проблемами при работе с любым из руководств, пожалуйста, посетите страницу :doc:`questions`
          для получения подсказок о том, где найти дополнительную помощь.

.. toctree::
   :maxdepth: 1
   :caption: Tutorials

   test_network
   deploy_chaincode.md
   write_first_app
   tutorial/commercial_paper
   private_data_tutorial
   couchdb_tutorial
   create_channel/create_channel_overview.md
   channel_update_tutorial
   config_update.md
   chaincode4ade
   videos

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
