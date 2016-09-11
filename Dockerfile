FROM clouder/clouder-base
MAINTAINER Yannick Buron yburon@goclouder.net

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install git nginx logrotate

RUN useradd -d /home/git  -s /bin/bash git
RUN mkdir /home/git
RUN chown git:git /home/git
RUN touch /home/git/.pgpass

ADD sources/default /etc/default/gitlab
RUN rm /etc/nginx/sites-enabled/default
ADD sources/logrotate /etc/logrotate.d/gitlab

RUN mkdir -p /opt/gitlab/data/uploads
RUN chmod -R 700 /opt/gitlab/data/uploads
RUN mkdir -p /opt/gitlab/data/builds
RUN mkdir -p /opt/gitlab/data/artifacts
RUN mkdir -p /opt/gitlab/config
RUN mkdir -p /opt/gitlab/var/log
RUN mkdir -p /opt/gitlab/var/tmp

ADD sources/gitlab.yml /opt/gitlab/config/gitlab.yml
ADD sources/secrets.yml /opt/gitlab/config/secrets.yml
ADD sources/resque.yml /opt/gitlab/config/resque.yml
ADD sources/database.yml /opt/gitlab/config/database.yml
RUN chmod 0600 /opt/gitlab/config/secrets.yml
ADD sources/unicorn.rb /opt/gitlab/config/unicorn.rb
ADD sources/rack_attack.rb /opt/gitlab/config/rack_attack.rb

RUN chown -R git:git /opt/gitlab

USER git

RUN mkdir /home/git/repositories
RUN chmod -R 770 /home/git/repositories
RUN chmod -R ug-s /home/git/repositories/

# Configure Git global settings for git user
# 'autocrlf' is needed for the web editor
RUN git config --global core.autocrlf input

# Disable 'git gc --auto' because GitLab already runs 'git gc' when needed
RUN git config --global gc.auto 0
