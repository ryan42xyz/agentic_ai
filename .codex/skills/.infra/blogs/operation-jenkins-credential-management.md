
get credential
```
kwest exec -it $(kwest get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -n jenkins -c jenkins -- bash
cat /var/jenkins_home/config.xml
cat /var/jenkins_home/credentials.xml
```

If change dockerfile @slave
    1. change dockerfile
    2. old jenkins to build new image / slave
    3. change new version in new jenkins config / cloud template 
    4. run new build and check @ctrl-f (new tag)