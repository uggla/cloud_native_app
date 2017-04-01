This environment allows you to deploy a Docker Registry container supporting SSL communication without hassle !

Issue:

```
git clone https://github.com/bcornec/Labs.git
cd Labs/Docker/registry
./deploy_registry.sh
```

This will check your configuration for dependencies
then use the `docker-compose.yml` file to create 2 containers
one from the registry Docker Hub container
another one running a web server, in which the SSL configuration is also done

The only parameter you need to give is the FQDN of the system hosting the registry (as SSL certificates are picky on names)
