# CloudApp Export

A quick way to grab all the data you have stored in [CloudApp](https://www.getcloudapp.com/).


## Credentials

The script requiests the following environment variables. These are easiest to
set via the .env file in this directory which will be automatically detected.

```
export CLOUDAPP_API_HOST="my.cl.ly"
export CLOUDAPP_USERNAME="YOUR_EMAIL"
export CLOUDAPP_PASSWORD="YOUR_PASSWORD"
```


## API Output Format

Each item will have the following attributes

```
slug: 3a1X1J383340
name: marcqualie-nyc-2017.jpg
created_at: '2017-07-06T17:48:01Z'
updated_at: '2017-07-06T17:48:02Z'
long_link: true
item_type: image
view_counter: 0
content_url: http://share.marcqualie.com/3a1X1J383340/marcqualie-nyc-2017.jpg
redirect_url:
remote_url: http://f.cl.ly/items/292o1N3J3s0A281O3Y2x/marcqualie-nyc-2017.jpg
source: CloudApp/4.2.4 (1054) (Mac OS X 10.12.5)
thumbnail_url: https://d1dqt6infcio59.cloudfront.net/3a1X1J383340/010428f967be2109bac41acfae90cb55
share_url: http://share.marcqualie.com/3a1X1J383340
```

You can download the direct file via `remote_url`


## LICENSE

[MIT](LICENSE)
