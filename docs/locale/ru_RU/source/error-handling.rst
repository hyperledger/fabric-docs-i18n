Обработка ошибок
================

Общая информация
----------------

Код HL Fabric должен использовать vendored-пакета **github.com/pkg/errors** вместо стандартного
типа error.
Этот пакет обеспечивает простое создание и отображение трассировки стека сообщений ошибок.

Инструкция по исопльзованию
---------------------------

**github.com/pkg/errors** должен быть использован вместо всех вызовов
``fmt.Errorf()``. Использование этого пакета создаст
стек ошибок, который будет добавлен к сообщению об ошибке.

Использовать этот пакет просто, потребуются лишь немного изменить ваш код.

Для начала нужно будет импортировать **github.com/pkg/errors**.

Далее, для создание всех ошибок использовать функции errors создания ошибок
(errors.New(), errors.Errorf(), errors.WithMessage(), errors.Wrap(), errors.Wrapf()).

.. note:: https://godoc.org/github.com/pkg/errors содержит полную сводку возможных функций создания ошибок.
          Также обратите внимание на секцию General Guidelines ниже.

Наконец, замените во всех строках с форматиранием логгеров или fmt.Printf() ``%s`` на ``%+v``, чтобы
выводить весь стек ошибок вместе с сообщением об ошибке.

Общие принципы обработки ошибок в HL Fabric
-------------------------------------------

- Если вы обрабатываете пользовательский запрос, вы должны записать ошибку в лог и вернуть ее.
- Если ошибка исходит из внешнего ресурса, такого как библиотека Go или vendored-пакет, оберните ошибку с помощью errors.Wrap(), чтобы создать стек с ошибкой.
- Если ошибка исходит из функции Fabric, то, если хотите добавьте контекст вашей функции к этой сообщению этой ошибки с помощью errors.WithMessage(), при этом
  не изменив стек.
- panic не должен передаваться в другие пакеты.

Пример программы
----------------

Следующий пример демонстрирует использование данного пакета:

.. code:: go

  package main

  import (
    "fmt"

    "github.com/pkg/errors"
  )

  func wrapWithStack() error {
    err := createError()
    // когда ошибка исходит из внешнего ресурса:
    return errors.Wrap(err, "wrapping an error with stack")
  }
  func wrapWithoutStack() error {
    err := createError()
    // когда ошибка исходит изнутри кода Fabric и уже имеет трассировочный стек:
    return errors.WithMessage(err, "wrapping an error without stack")
  }
  func createError() error {
    return errors.New("original error")
  }

  func main() {
    err := createError()
    fmt.Printf("print error without stack: %s\n\n", err)
    fmt.Printf("print error with stack: %+v\n\n", err)
    err = wrapWithoutStack()
    fmt.Printf("%+v\n\n", err)
    err = wrapWithStack()
    fmt.Printf("%+v\n\n", err)
  }

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
