import json

with open('/home/pi/rpi4mediaserver/nnlk-tmp/yt-metadata/VvChqBmsTTY.json') as json_file:
    data = json.load(json_file)
    print('id: ' + data['id'])
