#!/bin/bash

###### Install jq if not available ##########
which jq || brew install jq

# Set variables
ORGANISATION="<ORGANISATION NAME>"
PROJECT="<PROJECT NAME>"
PIPELINE_NAME="<PIPELINE NAME>"
ARTIFACT_NAME="<ARTIFACTS NAME>"
USERNAME="<USERNAME>"
PAT="<PERSONAL ACCESS TOKEN>"
ENDPOINT="https://dev.azure.com/$ORGANISATION/$PROJECT/_apis"


################################### iOS ##########################################
# Get pipeline id
pipelineID=$(curl -u $USERNAME:$PAT "$ENDPOINT/pipelines?api-version=7.0" | jq '.value[] | select(.name == "'"$PIPELINE_NAME"'") | .id')
echo "pipeline id: $pipelineID"


############################
# Get EU-iOS Build id
# .status == "completed" and .result == "succeeded" to find stable build
# and .reason == "schedule" to find only the dev branch
# .id' to find only id
# head -n 1 to get latest build
buildID=$(curl -u $USERNAME:$PAT "$ENDPOINT/build/builds?definitions=$pipelineID&api-version=7.0" | jq '.value[] | select(.status == "completed" and .result == "succeeded" and .reason == "schedule") | .id' | head -n 1)
echo "buildID: $buildID"


##############################
# Download artifacts
###### iOS #########
# .resource.downloadUrl to get download URL
# sed 's/"$//' --- remove " from string
downloadURL=$(curl -u $USERNAME:$PAT "$ENDPOINT/build/builds/$buildID/artifacts?artifactName=$ARTIFACT_NAME&api-version=7.0" | jq -r '.resource.downloadUrl' | sed 's/"$//')
echo "downloadURL: $downloadURL"
curl -J -u $USERNAME:$PAT -L $downloadURL -o ~/Desktop/Artifacts.zip

