#!/bin/bash

osvers=$(sw_vers -productVersion | awk -F. '{ print $2 }')

if [[ 6 < ${osvers} && ${osvers} < 9 ]]; then
    gatekeeper_status=$(spctl --status | awk '{ print $2 }')
    echo "${gatekeeper_status}"
else
  echo "Gatekeeper Not Available For This Version Of OS X"
fi
