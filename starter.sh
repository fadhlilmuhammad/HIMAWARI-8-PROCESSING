#!/bin/bash

proj="w40"                                                        #Change to your project
uname="xx1234"                                                    #Change to your username

foldername="H8_TUTORIAL"                                          #Don't change

mkdir /g/data/${proj}/${uname}/${foldername}                      #make folder
cp -r /g/data/v46/fm6730/H8_TUTORIAL /g/data/${proj}/${uname}/    #copy folder
