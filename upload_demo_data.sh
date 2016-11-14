#!/bin/bash
#
# (C) Copyright 2016 The o2r project. https://o2r.info
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

api_endpoint="http://172.17.0.1/api/v1/compendium"
example_count=0
steps=0 # boolean

while getopts ":a:b:e:c:s" opt; do
  case $opt in
    # number of minimal examples
    e) example_count="$OPTARG"
    ;;
    # URL for POST requests
    a) api_endpoint="$OPTARG"
    ;;
    b) bagtainers+=("$OPTARG")
    ;;
    s) steps=1
    ;;
    c) cookie="$OPTARG"
    ;;
    \?)
    echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac
done

echo "Running bagtainer upload container using endpoint: '"$api_endpoint"' and cookie: '"$cookie"'"

# upload n many of the success-load example from o2r-muncher
a=1
while [ "$a" -le "$example_count" ]
do
  echo
  echo "Uploading" $a "of" $NUMBER_OF_COMPENDIA
  curl -# --cookie "connect.sid=$cookie" -F "compendium=@/bagtainers/success-load.zip;type=application/zip" -F "content_type=compendium_v1" $api_endpoint | jq .
  a=`expr $a + 1`
done

# upload selected example bagtainers from o2r-bagtainers
if [ "${#bagtainers[@]}" -gt "0" ]
then
  echo
  echo ${#bagtainers[@]} "bagtainers will be zipped and uploaded:" ${bagtainers[*]}

  for bagtainer in ${bagtainers[@]}; do
    # go to directory
    cd /bagtainers/$bagtainer
    # zip contents
    zip upload.zip * --recurse-paths --quiet
    # upload zip file
    echo
    echo "Uploading bagtainer" $bagtainer
    curl -# --cookie "connect.sid=$cookie" -F "compendium=@/bagtainers/$bagtainer/upload.zip;type=application/zip" -F "content_type=compendium_v1" $api_endpoint | jq .
  done
fi

# upload all of the "steps" from the tests in o2r-muncher
if [ "$steps" -gt "0" ]
then
  echo
  echo "Example steps will be zipped and uploaded."

  declare -a steps=("step_zero" "step_validate_bag" "step_validate_compendium" "step_image_build" "step_image_execute" "step_image_prepare")

  for step in ${steps[@]}; do
    # go to directory
    cd /bagtainers/$step
    # zip contents
    zip upload.zip * --recurse-paths --quiet
    # upload zip file
    echo
    echo "Uploading step example '"$step"'"
    curl -# --cookie "connect.sid=$cookie" -F "compendium=@/bagtainers/$step/upload.zip;type=application/zip" -F "content_type=compendium_v1" $api_endpoint | jq .
  done
fi

echo
echo 
echo "Done."

exit 0