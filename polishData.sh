#!/bin/bash

jq '.[] | .[] | .[] | .c' $1.json > $1.txt
