#!/bin/bash
wget https://gitlab.com/abmyii/ubports-godot/-/jobs/artifacts/ut-port-stable/download?job=xenial_${ARCH}_click -O temp.zip
unzip temp.zip
mv godot.ubports.${ARCH} godot
