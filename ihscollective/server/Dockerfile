FROM wasdev/ferret
ADD serverOverride.xml /config/configDropins/overrides/
RUN installUtility install --acceptLicense defaultServer
ADD startWorker /opt/ibm/docker/
ENTRYPOINT ["/opt/ibm/docker/startWorker"]
CMD ["/opt/ibm/docker/docker-server", "run", "defaultServer" ]
