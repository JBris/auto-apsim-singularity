#!/usr/bin/env bash

###################################################################
# Constants
###################################################################

export SINGULARITY_MAINTAINER=james.bristow@plantandfood.co.nz
export LATEST_VERSION_URL=http://apsimdev.apsim.info/APSIM.Builds.Service/Builds.svc/GetLatestVersion
export LATEST_DEBIAN_DOWNLOAD_URL=http://apsimdev.apsim.info/APSIM.Builds.Service/Builds.svc/GetURLOfLatestVersion?operatingSystem=Debian

###################################################################
# Main
###################################################################

current_release=`cat Singularity`
echo "Current release: $current_release"

export APSIM_VERSION=$(
    curl "$LATEST_VERSION_URL" |\
        xmllint --xpath "/*[local-name()='string']/text()" -
)

new_release="Singularity.${APSIM_VERSION}"

if [ "$new_release" == "$current_release" ]; then
    echo "Most current release: $current_release"
    exit 1
fi

export APSIM_DEBIAN_DOWNLOAD=$(
    curl "$LATEST_DEBIAN_DOWNLOAD_URL" |\
        xmllint --xpath "/*[local-name()='string']/text()" -
)

envsubst '$SINGULARITY_MAINTAINER $APSIM_VERSION $APSIM_DEBIAN_DOWNLOAD' < templates/Singularity.template > "out/${new_release}"

apptainer build "$(pwd)/out/apsim.sif" "$(pwd)/out/${new_release}" 
"$(pwd)/out/apsim.sif"

if [ "$?" -ne 0 ]; then
    echo "Failed to build: $new_release"
    exit 1
fi

echo "$new_release" > Singularity
cp  "out/${new_release}" recipes

echo "$new_release"
