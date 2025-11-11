# ddns systemd updater

## Установка вручную

Установка роли выполняется обычным клонированием репозитория

```shell
cd ansible/roles
git clone 'https://github.com/athena210/ansible-role-ddns.git' ddns
```

## Установка списком

Установку можно выполнять из списка в файле `requirements-galaxy.yml`

```yaml
---
roles:
  - name: ddns
    src: https://github.com/athena210/ansible-role-ddns.git
    scm: git
    version: main
```

Запуск установки

```shell
cd ansible
ansible-galaxy install -p roles -r requirements-galaxy.yml
```
