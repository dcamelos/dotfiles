#!/usr/bin/env bash
#	default color: 178984
oldglyph=#5a4d47
newglyph=#5a4d47

#	Front
#	default color: 36d7b7
oldfront=#9c867c
newfront=#9c867c

#	Back
#	default color: 1ba39c
oldback=#6b5c55
newback=#6b5c55

sed -i "s/#524954/$oldglyph/g" $1
sed -i "s/#9b8aa0/$oldfront/g" $1
sed -i "s/#716475/$oldback/g" $1
sed -i "s/$oldglyph;/$newglyph;/g" $1
sed -i "s/$oldfront;/$newfront;/g" $1
sed -i "s/$oldback;/$newback;/g" $1
