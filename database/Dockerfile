FROM centos:7

RUN yum -y install boost-python
RUN yum -y install boost-serialization 
RUN yum -y install numpy
RUN yum -y install boost 

RUN mkdir /opt/calc_server
ADD chemistrycalculationservice/calc_server.py /opt/calc_server/
ADD chemistrycalculationservice/test_calc_server.py /opt/calc_server/

ADD chemistrycalculationservice/calc_server.conf /etc/init/calc_server.conf

LABEL name="crunchydata/postgres" \
        vendor="crunchy data" \
	PostgresVersion="11" \
	PostgresFullVersion="11.4" \
	Version="7.6" \
	Release="2.4.1" \
        url="https://crunchydata.com" \
	summary="PostgreSQL 11.4 (PGDG) on a Centos7 base image" \
        description="Allows multiple deployment methods for PostgreSQL, including basic single primary, streaming replication with synchronous and asynchronous replicas, and stateful sets. Includes utilities for Auditing (pgaudit), statement tracking, and Backup / Restore (pgbackrest, pg_basebackup)." \
        io.k8s.description="postgres container" \
        io.k8s.display-name="Crunchy postgres container" \
        io.openshift.expose-services="" \
        io.openshift.tags="crunchy,database"

#ENV PGVERSION="11" PGDG_REPO="pgdg-redhat-repo-latest.noarch.rpm" PGDG_REPO_DISABLE="pgdg10,pgdg96,pgdg95,pgdg94" \
#    BACKREST_VERSION="2.13" PG_MODE="primary" PG_DATABASE="testdb" PG_PRIMARY_PORT="5432" PG_USER="demo" PG_PASSWORD="demo" \
#    PG_PRIMARY_USER="replication" PG_PRIMARY_PASSWORD="replication" PG_ROOT_PASSWORD="admin" PROTEAX_CORE_6_HOME="/opt/Biochemfusion/PgCartridge/v6/"
    
ENV PGVERSION="11" PGDG_REPO="pgdg-redhat-repo-latest.noarch.rpm" PGDG_REPO_DISABLE="pgdg10,pgdg96,pgdg95,pgdg94" \
    BACKREST_VERSION="2.13" PG_MODE="primary" PG_PRIMARY_PORT="5432"  PG_PRIMARY_USER="postgres" \
    PG_ROOT_PASSWORD="" PROTEAX_CORE_6_HOME="/opt/Biochemfusion/PgCartridge/v6/"    

RUN rpm -Uvh https://download.postgresql.org/pub/repos/yum/${PGVERSION}/redhat/rhel-7-x86_64/${PGDG_REPO}

RUN yum -y update \
 && yum -y install epel-release \
 && yum -y update glibc-common \
 && yum -y install bind-utils \
    gettext \
    hostname \
    procps-ng  \
    rsync \
    psmisc openssh-server openssh-clients \
 && yum -y install --disablerepo="${PGDG_REPO_DISABLE}" \
    postgresql11-server postgresql11-contrib postgresql11 \
    pgaudit13_11 \
    pgbackrest-"${BACKREST_VERSION}" \
 && yum -y clean all

RUN yum -y install postgresql11-plpython 

ENV PGROOT="/usr/pgsql-${PGVERSION}"

# add path settings for postgres user
# bash_profile is loaded in login, but not with exec
# bashrc to set permissions in OCP when using exec
# HOME is / in OCP
ADD conf/.bash_profile /var/lib/pgsql/
ADD conf/.bashrc /var/lib/pgsql
ADD conf/.bash_profile /
ADD conf/.bashrc /

RUN mkdir -p /opt/cpm/bin /opt/cpm/conf /pgdata /pgwal /pgconf /recover /backrestrepo

#RUN chmod 700 /pgdata

RUN chown -R postgres:postgres /opt/cpm /var/lib/pgsql \
    /pgdata /pgwal /pgconf /recover /backrestrepo &&  \
    chmod -R g=u /opt/cpm /var/lib/pgsql \
    /pgdata /pgwal /pgconf /recover /backrestrepo

# add volumes to allow override of pg_hba.conf and postgresql.conf
# add volumes to offer a restore feature
# add volumes to allow storage of postgres WAL segment files
# add volumes to locate WAL files to recover with
# add volumes for pgbackrest to write to

#VOLUME ["/sshd", "/pgconf", "/pgdata", "/pgwal", "/recover", "/backrestrepo"]
VOLUME ["/var/lib/pgsql/11/data"]


# open up the postgres port
EXPOSE 5432

#ADD setenv.sh /opt/cpm/bin
ADD bin/postgres /opt/cpm/bin
ADD bin/common /opt/cpm/bin
ADD conf/postgres /opt/cpm/conf
# folder does not exists in github repository
# copy files from https://github.com/CrunchyData/pgmonitor/tree/master/exporter/postgres
ADD tools/pgmonitor/exporter/postgres /opt/cpm/bin/modules

RUN chmod g=u /etc/passwd && \
	chmod g=u /etc/group


RUN mkdir /.ssh && chown 26:0 /.ssh && chmod g+rwx /.ssh


RUN chmod +x /opt/cpm/bin/uid_postgres.sh


ENTRYPOINT ["/opt/cpm/bin/uid_postgres.sh"]

# always use COPY for tar files and NOT ADD
COPY rdkit/opt_rdkit.tgz /tmp/opt_rdkit.tgz


# make sure to concatenate cd /opt/ with tar command
RUN mkdir /opt/rdkit && cd /opt && tar -zxf /tmp/opt_rdkit.tgz

ADD rdkit/rdkit.so /usr/pgsql-11/lib/

RUN chmod 755 /usr/pgsql-11/lib/rdkit.so

ADD rdkit/rdkit--3.5.sql /usr/pgsql-11/share/extension

RUN chmod 755 /usr/pgsql-11/share/extension/rdkit--3.5.sql

ADD rdkit/rdkit.control /usr/pgsql-11/share/extension

RUN chmod 755 /usr/pgsql-11/share/extension/rdkit.control

ADD proteax/proteax_pg_cartridge.6.so /usr/pgsql-11/lib/

RUN chmod 755 /usr/pgsql-11/lib/proteax_pg_cartridge.6.so



ADD proteax/proteax--3.0.sql /usr/pgsql-11/share/extension/

RUN chmod 755 /usr/pgsql-11/share/extension/proteax--3.0.sql






ADD proteax/proteax.control /usr/pgsql-11/share/extension/

RUN chmod 755 /usr/pgsql-11/share/extension/proteax.control

RUN mkdir -p /opt/Biochemfusion/PgCartridge/v6/lib/linux/x86_64


# IMPORTANT NOTE: make sure to copy the proteax library from /opt/Biochemfusion/PgCartridge/v6/lib/linux/x86_64/
# folder of HOST since there are big problems if file was copied from windows host to local docker folder
ADD proteax/libproteax_core.6.so /opt/Biochemfusion/PgCartridge/v6/lib/linux/x86_64/

RUN chmod 755 /opt/Biochemfusion/PgCartridge/v6/lib/linux/x86_64/libproteax_core.6.so

ENV PYTHONPATH="/opt/rdkit/" 
#RUN LD_LIBRARY_PATH=$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/opt/rdkit/lib/"

#RUN bash -c "/usr/bin/python /opt/calc_server/calc_server.py &"

#RUN /usr/bin/python /opt/calc_server/test_calc_server.py

#RUN start calc_server
#RUN tail -f /var/log/upstart/calc_server.log

ADD chemrps/createchemrpsusers.sql /tmp
ADD chemrps/chemrpsdb.sql /tmp
#ADD ecrs/assign_privs.sql /tmp
ADD chemrps/define_demodbusers.sql /tmp
#ADD ecrs/2019-09-21_SimilaritySearch.sql /tmp
ADD chemrps/2019-11-21_SimilaritySearch_enhancements.sql /tmp

ADD .env /tmp/chemrpsenv
ADD chemrpsenv.sh /tmp



#USER postgres

#USER 26
#USER root

#CMD ["su", "-", "postgres", "-c", "/bin/bash"]

RUN chmod +x /opt/cpm/bin/start.sh

CMD ["/opt/cpm/bin/start.sh"]

