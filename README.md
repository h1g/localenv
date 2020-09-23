### Универсальное локальное окружение разработчика
### Особенности
- Кросплатформенность - Linux, MacOS, Windows(wsl2)
- Минимальные требования - для работы нужен Docker Desktop и make
- Простота развертывания - make install и окружение готово к работе
- Развертывание микросервисов(проектов) одной командой
- Возможность запуска и работы большого количества микросервисов
- Простой интерфейс работы с локальным окружение
- Автодополнение команд локального окружение по двойному TAB
- Автоматическое добавление/удаление доменных имен в хост системе
- Кеширование пакетных менеджеров composer/bundler/npm

---
#### Зависимости для всех операционных систем:
 - [docker](https://docs.docker.com/install)
 - [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
#### Зависимости для MacOS
 - [brew](https://brew.sh/)
 - [brew shell completion](https://docs.brew.sh/Shell-Completion)
#### Зависимости для Windows
 - [wsl2](https://docs.microsoft.com/ru-ru/windows/wsl/install-win10)
 - [docker wsl2 backend](https://docs.docker.com/docker-for-windows/wsl/)
 - [windows terminal](https://docs.microsoft.com/en-us/windows/terminal/)
#### Зависимости для Linux(Ubuntu 18.04)
 - [make](https://www.howtoinstall.me/ubuntu/18-04/make/)
### Подготовка к развертыванию:
### Для всех операционных систем:
```shell
# Создаем ssh ключи (с пустой passphrase, ssh-agent пока не поддерживается)
ssh-keygen
# Задаем глобальные настройки git
git config --global user.name 'John Deploy'
git config --global user.email 'johndeploy@example.com'
```
#### Linux
```shell
# Добавляем текущего пользователя в группу docker
sudo usermod -aG docker ${USER}
# Подключаем текущего пользователя к группе docker,
# но лучше перезагузить пэвм, или перелогинится в систему
newgrp docker ${USER}
```
#### MacOS
```shell
#Добававляем текущего пользователя в группу whell
sudo dseditgroup -o edit -a ${USER} -t user wheel
#Разрешаем группе whell редактировать файл /etc/hosts
sudo chmod 664 /etc/hosts
```
#### Windows
```shell
#Разрешаем текущему пользователю редактировать
#файл: %SYSTEMROOT%\System32\drivers\etc\hosts
#Выполнять надо:
# - в хост системе(windows)
# - в интерпритаторе cmd
# - cmd должены быть запущенном с правами администратора
cacls %SYSTEMROOT%\System32\drivers\etc\hosts /e /p %username%:w
```

#### Сценарий развертывания локального окружения разработчика:
```shell
# Первоначальное получения кода локального окружения
git clone https://github.com/h1g/localenv.git
# Все команды выполняются из директории в которую был клонирован
# код локального окружения разработчика
cd localenv
# Сборка докер образа для запуска локального окружени,
# рендер Makefile.deploy и деплой необходимых сервисов
# локального окружения разработчика
make install
```
#### Умолчания принятые в универсальном локальном окружении разработчика:
```shell
1. Окружение разрабатывалось для работы с GitLab
2. Project - наймспейс в котором абстрактная команда ведет разработку
   необходимых ей микросервисов
3. Repo_name - название репозитория с кодом микросервиса разрабатываемого
   абстрактной командой в командном наймспейсе
4. Репозиторий с исходным кодом проекта доступен
   по урл : https://gitlab.tld/project/repo_name
5. Репозиторий с исходным кодом конфигов проекта доступен
   по урл: https://gitlab.tld/project/configs/repo_name
6. После развертывания мироксервис будет доступен по урл как из хост системы,
   так и для других микросервисов: http://repo_name.project.localenv
7. Внутри микросервиса - сервисы доступны по коротким именам,
   например: reids,mysql,fpm,nginx,cli
8. Сервисы стороннего микросервиса будут доступны по полным именам,
    например: nginx.docs.laravel.localenv, laravel-docs-nginx,
              laravel-laravel-mysql, mysql.laravel.laravel.localenv
9. Любое умолчание можно переопределить как на уровне проекта, так и на уровне микросервиса
```

##### Запуск локального деплоймента произвольного проекта:
```shell
# доступно автодополнение по двойному нажатию TAB, после make должен быть введен пробел!
make deploy-project-repo_name
```

##### Достуные команды управления работой произвольного проекта(доступны после выполнения деплоймента проекта):
```shell
make project-repo_name-render		# рендеринг сервисных файлов проекта (Makefile,docker-compose.yml) и директорий с файлами описывающими процесс сборки docker-compose сервисов

make project-repo_name-deploy		# мета таргет включающий в себя: получение исходго кода, конфигов и сборку проекта
make project-repo_name-deploy-sources	# получение исходного кода проекта(актуально для всех технологий, кроме service)
make project-repo_name-deploy-configs	# получение исходного кода конфигов и их линковка в проект
make project-repo_name-deploy-build	# установка необходимых библиотек для заданного проекта, может переопределяться в переменной: build_command

make project-repo_name-publish-mysql	# публикация порта mysql для подключения к сервису из хост системы(актульно только для wsl/osx)
make project-repo_name-publish-redis	# публикация порта redis для подключения к сервису из хост системы(актульно только для wsl/osx)

make project-repo_name-exec		# запуск интерпритатора bash внутри CLI контейнера c UID текущего пользователя хост системы
make project-repo_name-exec-fpm		# запуск интерпритатора bash внутри FPM контейнера c UID текущего пользователя хост системы
make project-repo_name-exec-redis-cli	# запуск redis-cli внутри REDIS контейнера
make project-repo_name-exec-workers	# запуск интерпритатора bash внутри WORKER контейнера c UID текущего пользователя хост системы

make project-repo_name-restart		# перезапуск всех контейнеров заданного проекта
make project-repo_name-down		# останов всех контейнеров заданного проекта
make project-repo_name-up		# запуск всех контейнеров заданного проекта
make project-repo_name-images-pull	# обновление докер образов для заданного проекта
```
##### Пример для фреймворка Laravel:
```shell
make deploy-example-laravel
```
-----------------
##### После развертывания проекта, если сервис предполагает http доcтуп, он доступен по адресу:
http://repo_name.project.localenv

например, для проекта example, laravel микросервис будет доступен по данному урлу:

http://laravel.example.localenv

а docs микросервис, для проекта example, будет доступен по данному урлу:

http://docs.example.localenv

### Структура универсального локального окружения разработчика
```shell
localenv                              # Рабочая директория локального окружения
├── sources                           # Исходный код проектов
│   ├── example_laravel               # Исходный код фреймворка Laravel
│   └── example_docs                  # Исходный код документации к фреймворку Laravel
├── configs                           # Исходный код конфигов проектов
│   └── example_laravel               # Конфиги фреймворка Laravel
│       ├── develop                   # Конфиги для ветки master
│       └── master                    # Конфиги для ветки develop
├── services                          # Сервисная директория с посервисными папками для каждого сервиса
│   ├── example_laravel               # Сервисная директория для проекта example_laravel
│   │    ├── docker-compose.yml       # Docker-compose файл проекта example_laravel
│   │    ├── Makefile                 # Файл инструкций для make проекта example_laravel
│   │    ├── cli                      # Директория с файлами описывающими процесс сборки docker-compose сервиса cli
│   │    └── nginx                    # Директория с файлами описывающими процесс сборки docker-compose сервиса nginx
│   └── example_docs                  # Сервисная директория для проекта laravel_docs
│         ├── docker-compose.yml      # Docker-compose файл проекта example_laravel
│         ├── Makefile                # Файл инструкций для make проекта example_laravel
│         └── nginx                   # Директория с файлами описывающими процесс сборки docker-compose сервиса nginx
└── projects                          # Директория с описаниями проектов в yaml формате
      ├── dev.yml                     # Описание микросервисов проекта: Универсального локального окружения разработчика
      └── example.yml                 # Описание микросервисов проекта: Example
