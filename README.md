# ElasticStack step by step
Centralize Logging with ElasticStack Demo

## Prerequisite
* Virtualbox
* Vagrant
* Docker for Desktop

## Vagrant command for setup and destroy
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
    vagrant ssh [vm-name]
    ```

4. Shutdown VM
    ```vstscli
    vagrant halt [vm-name]
    ```

5. Remove VM
    ```vstscli
    vagrant destroy [vm-name]
    ```

## Docker compose command for setup and destroy
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