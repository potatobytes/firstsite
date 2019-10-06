#!/bin/bash


##### IMPORTANT #####
#
# Ensure config.sh have the following:
#
#   AWS_ACCESS_KEY_ID=
#   AWS_SECRET_ACCESS_KEY=
#   AWS_DEFAULT_REGION=ap-southeast-2
#   TARGET_BUCKET=s3://{bucket-name}
#
####################

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then 
	DIR="$PWD"; 
fi

. "$DIR/config.sh"

dryrun=--dryrun
mode=all
cache_control=max-age=86400

asset_only=0
style_only=0
force_sync=0

local_source=src/
css_path=css/
img_path=img/
fonts_path=fonts/
js_path=js/

function usage
{
    echo
    echo "Deploy to S3 via AWS-CLI sync. Defaults in --dryrun mode:"
    echo
    echo "      $0 -a -f"
    echo
    echo "Options:"
    echo "  - h Help text (this info)"
    echo "  - a Sync fonts/, img/ folder only"
    echo "  - s Sync css/ folders only (s for Style)"
    echo "  - f Force - no dryrun - actual sync."
    echo
}

while getopts ":fash" opt; do
  case $opt in
    a)
        echo "Syncing asset only..."
        asset_only=1
        mode="asset"
        ;;

    s)
        echo "Syncing styles only..."
        style_only=1
        mode="CSS"
        ;;

    f)
        echo "Force sync activated..."
        force_sync=1
        ;;

    h)
        usage
        exit 1
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        exit 1
        ;;
  esac
done

if [ $force_sync == 1 ]; 
then
    dryrun=""
fi

if [ "$mode" == "all" ];
then
    echo 
    echo "Syncing files..."
    aws s3 sync "$local_source" "$TARGET_BUCKET/" $dryrun  --region "$AWS_DEFAULT_REGION" --exclude "*.jpg" --exclude "*.css" --exclude "png" --exclude ".DS_Store"

    if [ -d "$local_source/$img_path" ];
    then
        echo 
        echo "Syncing img files..."
        aws s3 sync "$local_source/$img_path" "$TARGET_BUCKET/$img_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control"  --exclude ".DS_Store"
    fi

    if [ -d "$local_source/$js_path" ];
    then
        echo 
        echo "Syncing js files..."
        aws s3 sync "$local_source/$js_path" "$TARGET_BUCKET/$img_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi

    if [ -d "$local_source/$fonts_path" ];
    then
        echo 
        echo "Syncing font files..."
        aws s3 sync "$local_source/$fonts_path" "$TARGET_BUCKET/$img_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi

    if [ -d "$local_source/$css_path" ];
    then
        echo 
        echo "Syncing CSS files..."
        aws s3 sync "$local_source/$css_path" "$TARGET_BUCKET/$css_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi
fi

if [ "$mode" == "asset" ];
then

    if [ -d "$local_source/$img_path" ];
    then
        echo 
        echo "Syncing img files..."
        aws s3 sync "$local_source/$img_path" "$TARGET_BUCKET/$img_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi

    if [ -d "$local_source/$fonts_path" ];
    then
        echo 
        echo "Syncing font files..."
        aws s3 sync "$local_source/$fonts_path" "$TARGET_BUCKET/$img_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi
fi

if [ "$mode" == "CSS" ];
then
    if [ -d "$local_source/$css_path" ];
    then
        echo 
        echo "Syncing CSS files..."
        aws s3 sync "$local_source/$css_path" "$TARGET_BUCKET/$css_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi
fi

if [ "$mode" == "JS" ];
then
    if [ -d "$local_source/$js_path" ];
    then
        echo 
        echo "Syncing js files..."
        aws s3 sync "$local_source/$js_path" "$TARGET_BUCKET/$img_path" $dryrun  --region "$AWS_DEFAULT_REGION" --cache-control "$cache_control" --exclude ".DS_Store"
    fi
fi

