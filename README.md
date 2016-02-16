# containerGitLabCE_apacheProxy
Deploying a GitLab CE Server with network access via apache config

We need a machine with apache and docker engine installed.

Now enable the apache modules needed for proxying capabilities:
```
root@machine.local_: # a2enmod proxy
root@machine.local: # a2enmod proxy_http
```

Config the virtual host apache that mapped the docker container with GitLab CE server.
Enabled the reverse proxy too.
Create the file /etc/apache2/sites-available/gitlab.conf with this content:
```
<VirtualHost *:80>
    ServerName gitlab.machine.local #your hostname that use for GitLab Serve access  

    ServerAdmin webmaster@gitlab.machine.local

    <IfModule mod_proxy.c>
        <Proxy *>
            Allow from localhost
        </Proxy>
        ProxyPass / http://localhost:8091/
        ProxyPassReverse / http://localhost:8091/
    </IfModule>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```

Enable the new apache virtual host and restart apache service.
```
root@machine.local: # ln -s /etc/apache2/sites-available/gitlab.conf /etc/apache2/sites-enabled/gitlab.conf
root@machine.local: # /etc/init.d/apache2 force-reload
root@machine.local: # /etc/init.d/apache2 restart
```

Getting the docker image GitLab CE and start a container with the config needed.
```
root@machine.local: # docker pull gitlab/gitlab-ce
root@machine.local: # docker run -d --restart=always --hostname=gitlab.machine.local \
           -p 2234:22 -p 8091:80 -p 4431:443 \
           -v /etc/gitlab:/etc/gitlab \
           -v /var/opt/gitlab:/var/opt/gitlab \
           -v /var/log/gitlab:/var/log/gitlab \
           --name gitlab_server gitlab/gitlab-ce
```
-d :: Start the container in the background
--restart=always :: When the container exits docker engine will restart it.
--hostname=gitlab.machine.local :: Set the hostname that use the container
-p 2234:22 -p 8091:80 -p 4431:443 :: This params config tunnels between host port and container port.
-v /paths/files/host:/path/files/container :: This shared filesystems, binding a mount volume to host source path.
--name gitlab_server :: Set a name to docker container
gitlab/gitlab-ce :: The docker image of GitLab CE to be used


When the container started correctly we can edit the config file /etc/gitlab/gitlab.rb with the params needed.
Set this two values on  /etc/gitlab/gitlab.rb
```
# external_url 'GENERATED_EXTERNAL_URL' # default: http://hostname
external_url "http://gitlab.xendebian.local:80/"
## GitLab Shell settings for GitLab
gitlab_rails['gitlab_shell_ssh_port'] = 2234
```
This configuration will allow to GitLabCE generate the correct links on the web


Now we can browse to http://gitlab.machine.local and the defaults credentials is
user: root
password: 5iveL!fe
