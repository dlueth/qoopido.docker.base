FROM phusion/baseimage:latest
MAINTAINER Dirk Lüth <info@qoopido.com>

# Initialize environment
	CMD ["/sbin/my_init"]
	ENV DEBIAN_FRONTEND noninteractive

# configure defaults
	COPY ./configure.sh /
	ADD ./config /config
	RUN chmod +x /configure.sh \
    	&& chmod 755 /configure.sh
    RUN /configure.sh \
    	&& chmod +x /etc/my_init.d/*.sh \
    	&& chmod 755 /etc/my_init.d/*.sh

# alter my_init
	RUN sed -i -e 's/KILL_PROCESS_TIMEOUT = 5/KILL_PROCESS_TIMEOUT = 600/g' /sbin/my_init \
		&& sed -i -e 's/KILL_ALL_PROCESSES_TIMEOUT = 5/KILL_ALL_PROCESSES_TIMEOUT = 600/g' /sbin/my_init

# install packages
	RUN apt-get -qy update \
		&& apt-get -qy upgrade \
    	&& apt-get -qy dist-upgrade \
    	&& apt-get -qy install deborphan

# cleanup
    RUN dpkg -l linux-{image,headers}-* | awk '/^ii/{print $2}' | egrep '[0-9]+\.[0-9]+\.[0-9]+' | awk 'BEGIN{FS="-"}; {if ($3 ~ /[0-9]+/) print $3"-"$4,$0; else if ($4 ~ /[0-9]+/) print $4"-"$5,$0}' | sort -k1,1 --version-sort -r | sed -e "1,/$(uname -r | cut -f1,2 -d"-")/d" | grep -v -e `uname -r | cut -f1,2 -d"-"` | awk '{print $2}' | xargs apt-get -qy purge \
	    && apt-get -qy autoremove \
	    && deborphan | xargs apt-get -qy remove --purge \
		&& rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /usr/share/doc/* /usr/share/man/* /tmp/* /var/tmp/* /configure.sh \
		&& find /var/log -type f -name '*.gz' -exec rm {} + \
		&& find /var/log -type f -exec truncate -s 0 {} +