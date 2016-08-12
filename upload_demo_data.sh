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
cookie="required!"
example_count=0

while getopts ":a:b:c:e:" opt; do
  case $opt in
    # number of minimal examples
    e) example_count="$OPTARG"
    ;;
    # URL for POST requests
    a) api_endpoint="$OPTARG"
    ;;
    b) bagtainers+=("$OPTARG")
    ;;
    c) cookie="$OPTARG"
    ;;
    \?)
    echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac
done

echo "Endpoint: " $api_endpoint " Cookie: " $cookie

# upload n many of the success-load example from o2r-muncher
a=1
while [ "$a" -le "$example_count" ]
do
  echo
  echo "Uploading" $a "of" $NUMBER_OF_COMPENDIA
  curl -# --cookie "connect.sid=$cookie" -F "compendium=@/bagtainers/success-load.zip;type=application/zip" -F "content_type=compendium_v1" $api_endpoint 
  a=`expr $a + 1`
done

# upload selected example bagtainers from o2r-bagtainers

if [ "${#bagtainers[@]}" -gt "0" ]
then
  echo
  echo ${#bagtainers[@]} "bagtainers will be zipped and uploaded:" ${bagtainers[*]}

  for bagtainer in ${bagtainers[@]}; do
    # zip
    zip -r -q $bagtainer.zip $bagtainer/*
    # upload
    echo
    echo "Uploading bagtainer" $bagtainer
    curl -# --cookie "connect.sid: $cookie" -F "compendium=@/bagtainers/$bagtainer.zip;type=application/zip" -F "content_type=compendium_v1" $api_endpoint
  done
fi
echo
echo 
echo "Done."

exit 0