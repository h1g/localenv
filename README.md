# Локальное окружение разработчика 
## Предустановки:
 - [docker](https://docs.docker.com/engine/install/ubuntu/)
 - [docker-compose](https://docs.docker.com/compose/install/)
 - [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Использование
#### Универсальный сценарий запуска локального окружения:
```shell
# Первоначальное получения кода локального окружения
git clone git@github.com:h1g/localenv.git
# Все команды выполняются из директории в которую склонирован код Локального окружения разработчика
cd localenv
# Рендер Makefile.deploy и деплой сервисов локального окружения
make init
```
### Умолчания принятые в  локальном окружении:
  Название       | Описание
|-------------------|---------
|project| название проекта, например - laravel|
|repo_name| название репозитория в пректе, например - laravel|
| branch | ветка на которую будет переключен проект при деплое  |

-----------------

# Все нижеуказнные команды выполняются в директории в которую склонирован код Локального окружения разработчика
-----------------

##### Запуск локального деплоймента произвольного проекта:
```shell
# доступно автодополнение по двойному нажатию TAB, после make должен быть введен пробел!
make deploy-project-repo_name
```

##### Достуные команды управления работой произвольного проекта(доступны после выполнения деплоймента проекта):
```shell
make project-repo_name-build          # установка необходимых библиотек для заданного проекта, может переопределяться в переменной: build_command
make project-repo_name-pull           # обновление докер образов для заданного проекта
make project-repo_name-up             # запуск всех контейнеров заданного проекта
make project-repo_name-down           # останов всех контейнеров заданного проекта
make project-repo_name-restart        # перезапуск всех контейнеров заданного проекта
make project-repo_name-exec           # запуск интерпритатора bash внутри CLI контейнера c UID текущего пользователя хост системы
make project-repo_name-exec-workers   # запуск интерпритатора bash внутри WORKER контейнера c UID текущего пользователя хост системы
make project-repo_name-exec-fpm       # запуск интерпритатора bash внутри FPM контейнера c UID текущего пользователя хост системы
make project-repo_name-exec-redis-cli # запуск redis-cli внутри REDIS контейнера 
```

##### Пример для бэкенда Colibri: 
```shell
make deploy_laravel_laravel
```

-----------------



##### После развертывания проекта, если сервис предполагает http доcтуп, он доступен по адресу:
http://project.repo_nam.localenv

например, для проекта laravel, laravel микросервис будет доступен по данному урлу:

http://laravel.laravel.localenv

а docs сервис, для проекта laravel, будет доступен по данному урлу:

http://docs.laravel.localenv

### Структура рабочего окружения и описание
```bash
localenv                              # Рабочая директория локального окружения                                         
├── sources                           # Исходный код проектов
│   ├── laravel_laravel               # Код фреймворка Laravel
│   └── laravel_docs                  # Документация к фреймворку Laravel
│    
├── services                          # Сервисная директория посервисными папками для каждого сервиса
│   ├── laravel_laravel               # Директории docker-compose и прочих нужный файлов для colibri_api_s1
│   │    ├── docker-compose.yml       # Docker-compose проекта
│   │    ├── Makefile                 # Скрипт обертки для make
│   │    ├── cli                      # Директория с файлами для docker-compose сервиса cli
│   │    │     ├── bashrc             # Предустановки для интерпритатора командной строки bash для docker-compose сервиса cli
│   │    │     ├── build.sh           # Директивы для сборки проекта для docker-compose сервиса cli
│   │    │     └── Dockerfile         # Докерфайл с директивами сборки докер образа для docker-compose сервиса cli
│   │    └── nginx                    # Директория с файлами для docker-compose сервиса nginx
│   │          ├── nginx.conf         # Конфигурационный файл nginx
│   │          └── Dockerfile         # Докерфайл с директивами сборки докер образа для docker-compose сервиса nginx
│   └── laravel_laravel               # Директории docker-compose и прочих нужный файлов для colibri_api_s1
│         ├── docker-compose.yml      # Docker-compose проекта
│         ├── Makefile                # Скрипт обертки для make
│         └── nginx                   # Директория с файлами для docker-compose сервиса nginx
│               ├── nginx.conf        # Конфигурационный файл nginx
│               └── Dockerfile        # Докерфайл с директивами сборки докер образа для docker-compose сервиса nginx
└── projects
      ├── dev.yml                     # Описание микросервисов проекта: Локального окружения разработчика
      └── laravel.yml                 # Описание микросервисов проекта: Laravel
