#!/bin/bash
# This entrypoint is to be kept really simple. No need to get fancy.
#

notSet () {
	echo "${1} not set in enviroment!";
	return 0;
}

total_mem=$(free -gh | awk '/Mem:/{print $2}');
max_mem=${RAM:?Please specify how much ram you are allocating to ${NAME} with the RAM env var. You have ${total_mem} in your system. Choose wisely. :-)};
port=${PORT:?notSet "PORT"};




# Adapted from https://docs.papermc.io/paper/aikars-flags
java_args="
	-Xms${max_mem} \
	-Xmx${max_mem} \
	-XX:+UseG1GC \
	-XX:+ParallelRefProcEnabled \
	-XX:MaxGCPauseMillis=200 \
	-XX:+UnlockExperimentalVMOptions \
	-XX:+DisableExplicitGC \
	-XX:+AlwaysPreTouch \
	-XX:G1NewSizePercent=30 \
	-XX:G1MaxNewSizePercent=40 \
	-XX:G1HeapRegionSize=8M \
	-XX:G1ReservePercent=20 \
	-XX:G1HeapWastePercent=5 \
	-XX:G1MixedGCCountTarget=4 \
	-XX:InitiatingHeapOccupancyPercent=15 \
	-XX:G1MixedGCLiveThresholdPercent=90 \
	-XX:G1RSetUpdatingPauseTimePercent=5 \
	-XX:SurvivorRatio=32 \
	-XX:+PerfDisableSharedMem \
	-XX:MaxTenuringThreshold=1 \
	-Dusing.aikars.flags=https://mcflags.emc.gs \
	-Daikars.new.flags=true \
	-jar";

paper_args="
	--nogui \
	-p ${port} \
";


# Start the server with the above args
java ${java_args} /app/paper.jar ${paper_args};