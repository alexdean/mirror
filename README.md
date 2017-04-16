## Mirror

Mirror is two things:

  1. A background process to upload files from a local directory to a WebDAV
     server.
  2. An OSX Automator service to generate the proper remote URL for each
     file via a Finder action.

## Basic Usage

  1. Drop an image file into a local directory.
  2. Mirror uploads this file to your web server.
  3. Right-click on the image. Mirror provides a context menu to copy the URL
     to this image.
  4. Paste image URL into your chat room of choice.
  5. LOL.

## Setup

### Configure a WebDAV server

This is my nginx configuration, which utilizes the [ngx_http_dav_module](http://nginx.org/en/docs/http/ngx_http_dav_module.html).

```
location /dav/public/ {
  root /var/www/webdav;

  limit_except GET {
    auth_basic "webdav";
    auth_basic_user_file /var/www/webdav/users.htpasswd;
  }

  autoindex off;

  dav_methods PUT DELETE;
  dav_access group:rw all:r;

  client_max_body_size 0;
  client_body_temp_path /var/www/webdav/tmp;
  create_full_put_path  on;
}
```

Make sure to create the basic auth password file.

### Set up ruby

```
cd mirror
rvm install ruby-2.3.3
gem install bundler
bundle
```

### Add an Automator Service

I don't currently know of a convenient way to distribute Automator scripts,
but recreating this one should be pretty easy.

![screenshot](support/automator-screenshot.jpg)

### Set up configuration file

```
cp config.example.yml config.yml
```

And now populate `config.yml` with valid values.

### Start background process

Lots of paths need to be adjusted in the .plist file.

Open an issue if you actually want me to make this simpler to set up. At this
point I'm assuming that I'm basically talking to myself in this document.

```
cp support/org.deanspot.mirror.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/org.deanspot.mirror.plist
```

### Add some images to your local directory

Copy some image files into your local directory.
Watch the log file for activity.

### Use Finder to get URLs to the uploaded files

This Finder action will place a URL on your clipboard.

![screenshot](support/copy-url-screenshot.png)
