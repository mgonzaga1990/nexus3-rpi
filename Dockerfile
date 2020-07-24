FROM mjayson/java8-rpi as downloader

ARG NEXUS_VERSION=3.25.0-03
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

ADD "${NEXUS_DOWNLOAD_URL}" "/tmp/nexus.tar.gz"
RUN mkdir /tmp/sonatype && \
    tar -zxf /tmp/nexus.tar.gz -C /tmp/sonatype && \
    mv /tmp/sonatype/nexus-${NEXUS_VERSION} /tmp/sonatype/nexus


FROM mjayson/java8-rpi

COPY start-nexus-repository-manager.sh /opt/sonatype/start-nexus-repository-manager.sh
RUN chmod 755 /opt/sonatype/start-nexus-repository-manager.sh

COPY --from=downloader /tmp/sonatype /opt/sonatype
RUN \
    # Data directory (/nexus-data)
    mv /opt/sonatype/sonatype-work/nexus3 /nexus-data && \
    # Work directory (/opt/sonatype/sonatype-work/nexus3)
    ln -s /nexus-data /opt/sonatype/sonatype-work/nexus3

RUN addgroup -S nexus && adduser -S nexus -G nexus

RUN chown -R nexus:nexus /nexus-data
VOLUME /nexus-data

EXPOSE 8081-8099

USER nexus

ENV INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=/nexus-data/javaprefs"

CMD ["sh", "-c", "/opt/sonatype/start-nexus-repository-manager.sh"]
