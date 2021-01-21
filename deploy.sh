#!/bin/sh

v app.v
rsync -avzP --delete ./ profullstack:www/bitchin.net
