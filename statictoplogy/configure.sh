# For each liberty server
for i in $(docker ps --filter "label=liberty" -q)
do
    # Get the plugin config
    docker exec -it $i bash -c "/opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer"
    docker cp $i:/opt/ibm/wlp/output/defaultServer/plugin-cfg.xml ./merge/configs/$i.xml
done

# Build and run the merge
docker build --no-cache -t merge merge/
docker run --rm merge > plugin-cfg.xml

# For each IHS
for i in $(docker ps --filter "label=ihs" -q)
do
    # Give them the merged cofig
    echo "Configuring IHS container $i"
    docker cp ./plugin-cfg.xml $i:/opt/IBM/WebSphere/Plugins/config/webserver1/plugin-cfg.xml
    docker stop $i
    docker start $i
done

# Clean up
rm ./merge/configs/*
rm ./plugin-cfg.xml
docker rmi merge
