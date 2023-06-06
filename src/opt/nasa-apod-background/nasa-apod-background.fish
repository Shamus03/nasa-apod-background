#!/usr/bin/fish

argparse --name=nasa-apod-background 'f/force' -- $argv
or return

set config_dir /opt/nasa-apod-background
set date_file $config_dir/date.txt
set api_url_file $config_dir/api.url

set img_full $config_dir/apod_full.jpg
set img_desktop $config_dir/apod_desktop.jpg
set img_lock $config_dir/apod_lock.jpg

if not test -f $api_url_file
  echo "Api url file not found - please create a file $api_url_file containing the NASA API url"
  return
end
set api_url (cat $api_url_file)

set apod (curl --silent $api_url)

set apod_json (echo $apod | jp @)
if test "$apod_json" = null
  echo "APOD returned invalid json: $apod"
  return
end

set apod_error (echo $apod | jp -u error)
if test "$apod_error" != null
  echo "APOD error: $apod_error"
  return
end

set apod_url (echo $apod | jp -u url)
set apod_hdurl (echo $apod | jp -u hdurl)
set apod_explanation (echo $apod | jp -u explanation)
set apod_date (echo $apod | jp -u date)
set apod_media_type (echo $apod | jp -u media_type)

set last_downloaded_date (cat $date_file 2>/dev/null)

if string length -- $_flag_force; or test "$apod_date" != "$last_downloaded_date"
  rm -f $date_file

  if test "$apod_media_type" = video
    echo "Today's APOD is a video, will not download"
  else
    if not wget -O $img_full $apod_hdurl
      echo "HD image not found: $apod_hdurl"
      echo "Will download low quality version"
      wget -O $img_full $apod_url
    end

    # Resize full image to fit screen
    and convert -background black -resize 1920x1080 -extent 1920x1080 -gravity center -quiet $img_full $img_desktop

    # Create captioned image for lock screen
    and convert $img_desktop \( -background none -size 1920x -fill white -undercolor black -pointsize 20 caption:(string replace --all "'" "\'" $apod_explanation) \) -gravity southwest -compose over -composite $img_lock
  end

  and echo $apod_date > $date_file
end

