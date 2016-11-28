#!/usr/bin/env bash
while read FILE
do
    wget "$FILE"
    PACKAGE=${FILE##*/}
    R CMD INSTALL "$PACKAGE"
    rm "$PACKAGE"
done < forecast_dependencies.txt

