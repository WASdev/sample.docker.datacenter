FROM websphere-liberty:webProfile7
ADD controller.xml /config/configDropins/overrides/
RUN installUtility install --acceptLicense defaultServer
ADD startController /opt/ibm/docker/
ENTRYPOINT ["/opt/ibm/docker/startController"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer" ]
