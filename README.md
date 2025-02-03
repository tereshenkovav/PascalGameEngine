Игровой движок для Delphi и FreePascalCompiler на основе SFML.\
SFML-based game engine for Delphi and FreePascalCompiler.

## О проекте

Движок позволяет организовать игровой цикл на основе переключаемых сцен,
а также предоставляет полезные процедуры и классы для разработки игр.
Таким образом, разработчик игры концентрируется на логике отдельных сцен и
их переключении,
а не на создании окна и рендере/просчете игрового цикла, как это необходимо
при работе с низкоуровневыми графическими библиотеками.
В качестве библиотеки используется [SFML](https://www.sfml-dev.org) 
и его доработанные биндинги для Паскаля [PasSFML](https://github.com/CWBudde/PasSFML). 

Разработка проектов на основе движка для Windows возможна как при помощи Delphi, 
так и при помощи [FreePascalCompiler](https://www.freepascal.org). 
Работа под Linux возможна только через FreePascalCompiler.

## Состав репозитория

* `csfml` - содержит скомпилированные библиотеки CSFML из репозитория [PasSFML](https://github.com/CWBudde/PasSFML) 
* `engine` - исходный код движка в виде модулей для Delphi и FreePascalCompiler.
* `example` - исходный код примера использования движка в виде проектов для Delphi и FreePascalCompiler.
* `sfml` - содержит код биндинга SFML из репозитория [PasSFML](https://github.com/CWBudde/PasSFML) 

## Инструменты сборки

Для сборки игр на движке нужен либо установленный
[Delphi](https://delphi.embarcadero.com/)
(проверено с версиями 10, 11, 12),
либо [FreePascalCompiler](https://www.freepascal.org)
(требует версии не ниже 3.2.2)

## Сборка примера

Для сборки проекта примера в Windows при помощи Delphi нужно открыть проект
`example/ExampleDelphi.dproj` и выполнить его сборку в конфигурации Release.
В каталоге появится исполняемый файл `ExampleDelphi.exe`.

Для сборки проекта в Windows при помощи FreePascal нужно открыть каталог
`example` и запустить файл `make_win32.bat` или `make_win64.bat`.
В каталоге появится исполняемый файл `ExampleFPC.exe`.

В обоих случаях для запуска потребуется скопировать библиотеки из каталога
`csfml/win32` или `csfml/win64` в каталог с исполнимым файлом.
Разрядность библиотек должна соответствовать разрядности сборки.
Из внешних ресурсов нужны только
файл шрифта `arial.ttf` и файл спрайта `logo.png`, они уже есть в каталоге.

Для сборки проекта в Linux при помощи FreePascal нужно открыть каталог
`example` и запустить файл `make_linux64.sh`.
В каталоге появится исполняемый файл `ExampleFPC`.
Чтобы выполнить сборку и последующий запуск, понадобятся установленные
библиотеки `sfml` и `csfml`.
