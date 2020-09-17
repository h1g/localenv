# Универсальное локальное окружение разработчика
## Зависимости:
 - [docker](https://docs.docker.com/install/)
## Использование
### Подготовка к развертыванию универсального локального окружения разработчика
```shell
# Добавляем текущего пользователя в группу docker и перезагружаем пэвм или перелогиниваемся в систему
sudo usermod -aG docker ${USER}
# Устанавливаем make и git
sudo apt install -y make git
```
#### Универсальный сценарий развертывания универсального локального окружения разработчика:
```shell
# Первоначальное получения кода универсального локального окружения
git clone git@github.com:h1g/localenv.git
# Все команды выполняются из директории в которую был клонирован код универсального локального окружения разработчика
cd localenv
# Сборка докер образа для запуска локального окружени, рендер Makefile.deploy и деплой необходимых сервисов универсального локального окружения разработчика
make install
```
### Умолчания принятые в универсальном локальном окружении разработчика:
1. Окружение разрабатывалось для использоваться вместе с GitLab
2. Project - наймспейс в котором абстрактная команда ведет разработку необходимых ей микросервисов
3. Repo_name - название репозитория с кодом микросервиса разрабатываемого абстрактной командой
4. Репозиторий с исходным кодом проекта доступен по урл: https://gitlab.tld/project/repo_name
5. Репозиторий с исходным кодом конфигов проекта доступен по урл: https://gitlab.tld/project/configs/repo_name
6. После развертывания мироксервис будет доступен по урл: http://repo_name.project.localenv
7. Внутри микросервиса - сервисы доступны по коротким именам, например: reids,mysql,fpm,nginx,cli
8. Сервисы стороннего микросервиса будут доступны по полным именам, например: nginx.docs.laravel.localenv, laravel-docs-nginx, laravel-laravel-mysql, mysql.laravel.laravel.localenv
9. Локальное окружение изначально создавалось для поддержки php,nodejs,ruby микросервисов, но может быть легко адаптированно для других техноголий
10. Локальное окружение изначально создавалось для использования только под Linux, но теперь работает под Windows и OSx

Любое умолчание можно переопределить как на уровне проекта, так и на уровне микросервиса
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
make project-repo_name-render		# рендеринг сервисных файлов проекта (Makefile,docker-compose.yml) и директорий с файлами описывающими процесс сборки docker-compose сервисов
make project-repo_name-deploy		# мета таргет включющий в себя: получение исходго кода, конфигов и сборку проекта
make project-repo_name-deploy-sources	# получение исходного кода проекта(актуально для всех технологий, кроме service)
make project-repo_name-deploy-configs	# получение исходного кода конфигов и их линковка в проект
make project-repo_name-deploy-build	# установка необходимых библиотек для заданного проекта, может переопределяться в переменной: build_command

make project-repo_name-publish-mysql	# публикация порта mysql для подключения к сервису из хост системы(актульно только для windows/osx)
make project-repo_name-publish-redis	# публикация порта redis для подключения к сервису из хост системы(актульно только для windows/osx)

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
make deploy-laravel-laravel
```

-----------------



##### После развертывания проекта, если сервис предполагает http доcтуп, он доступен по адресу:
http://repo_name.project.localenv

например, для проекта laravel, laravel микросервис будет доступен по данному урлу:

http://laravel.laravel.localenv

а docs сервис, для проекта laravel, будет доступен по данному урлу:

http://docs.laravel.localenv

### Структура универсального локального окружения разработчика
```shell
localenv                              # Рабочая директория локального окружения
├── sources                           # Исходный код проектов
│   ├── laravel_laravel               # Код фреймворка Laravel
│   └── laravel_docs                  # Код документации к фреймворку Laravel
├── configs                           # Исходный код конфигов проектов
│   └── laravel_laravel               # Конфиги фреймворка Laravel
│       ├── develop                   # Конфиги для ветки master
│       └── master                    # Конфиги для ветки develop
├── services                          # Сервисная директория с посервисными папками для каждого сервиса
│   ├── laravel_laravel               # Сервисная директория для проекта laravel_laravel
│   │    ├── docker-compose.yml       # Docker-compose файл проекта laravel_laravel
│   │    ├── Makefile                 # Файл инструкций для make проекта laravel_laravel
│   │    ├── cli                      # Директория с файлами описывающими процесс сборки docker-compose сервиса cli
│   │    └── nginx                    # Директория с файлами описывающими процесс сборки docker-compose сервиса nginx
│   └── laravel_docs                  # Сервисная директория для проекта laravel_docs
│         ├── docker-compose.yml      # Docker-compose файл проекта laravel_laravel
│         ├── Makefile                # Файл инструкций для make проекта laravel_laravel
│         └── nginx                   # Директория с файлами описывающими процесс сборки docker-compose сервиса nginx
└── projects                          # Директория с описаниями проектов в yaml формате
      ├── dev.yml                     # Описание микросервисов проекта: Универсального локального окружения разработчика
      └── laravel.yml                 # Описание микросервисов проекта: Laravel
