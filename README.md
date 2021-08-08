# ElasticStack step by step
Centralize Logging with ElasticStack Demo

## Prerequisit
* Virtualbox
* Vagrant
* Docker for Desktop

## Vagrant Setup
1. Install vagrant plugins (vagrant plugin install)
    ```vstscli
    vagrant plugin install vagrant-vbguest
    ```
2. Create virtual machines
    ```vstscli
    vagrant up
    ```
3. Access to virtualbox shell
    ```vstscli
    vagrant ssh [box-name]
    ```

## Docker compose setup
1. Run docker compose
    ```vstscli
    docker-compose up -d
    ```

2. If you want to start docker compose again
    ```vstscli
    docker-compose start
    ```

3. Tear down
    ```vstscli
    docker-compose down
    ```