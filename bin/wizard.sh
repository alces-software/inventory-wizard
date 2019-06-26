#!/bin/bash

BASEPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
echo -n "Do you want to perform actions on racks, assets or configure? [rack|asset|config] "

read action

case $action in
	rack)
		$BASEPATH/rack.rb
		;;
	asset)
		$BASEPATH/asset.rb
		;;
	config)
		$BASEPATH/config.rb
		;;
	*)
		echo "Invalid option specified - failing"
		exit 1
		;;
esac

