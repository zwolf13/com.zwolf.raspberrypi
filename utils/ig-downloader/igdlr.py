import re
import requests
import json
import shutil
import sys
from datetime import datetime
from http.cookiejar import MozillaCookieJar

OUTPUT_FOLDER = '/home/pi/tmp/ig-downloader/downloads'

def get_cookie_header():
    csrftoken = 'Z5opmD9LaNKbZiHr0OGHYFpgkE7gfj6W'
    mid = 'YjxsUgAEAAH3n1g3uBCKQwAF5hCv'
    ig_did = 'ACB08B6F-D252-4FC7-81ED-4EECFE23CBB6'
    built = f'csrftoken={csrftoken}; mid={mid}; ig_did={ig_did}; ig_nrcb=1; fbm_124024574287414=base_domain=.instagram.com; ds_user_id=3452129080; sessionid=3452129080%3AHISxmbMWZysBkB%3A25; shbid="19869\0543452129080\0541684933480:01f7da7dc0bcdb4ef933fb3a1f24f2f3766053bde9cfb0c75996e4cae6b9a043615aa460"; shbts="1653397480\0543452129080\0541684933480:01f7ec716c837804dade3e17f2831651e9c7fe837d855bb4c33752c93a962ae14c07bdb1"; fbsr_124024574287414=hBFgbp8_-csv9ZMPEgO9bTth-Jj8pcrApcYDjHMSPgs.eyJ1c2VyX2lkIjoiNjAyNjE5Nzg2IiwiY29kZSI6IkFRQmRUaEFjbDFBWGNmN3ktQ1BhdHRzbGs3ZE1ZMWo0YUROekdtSHpJVUZRdkE1Nk1tc2pBSHB6d2htSzd2MDFEdlZZbF9tZUhwUTBfcVNyQXgyWEVIOFhHUVFNQ3g4eDlrb1JHdjVzdE8xOVozMHpWNUtQWWNDRGJuQUlfbngyX0hBczBacFRCWlJrQzNDdzFmZk9ad0xtZ3NwcS0wMHU5eHlWelBGaGZERmVBVTAtV2U3U2MyM0J4R3FuZHE0ekpMV043Zm13RGp3dk5iYTVqbm5VTXV0a3VXZnpfR04wNEJPbURfdWgyTzFzSHRSZnJwOHFGbXFvSTlPb1R0Vm5UVkRQQXRzZndKUXloWFJpZXEwcXU1SmNuX1NNZ0Z4dUhMMzhxQndKemVRMmNZd1JJN2NRcFRwdnJOdHVUTldZOGkwIiwib2F1dGhfdG9rZW4iOiJFQUFCd3pMaXhuallCQUFTbjZVMHFoQnBpaVpBeHhrZnA5MWVEbGI3RHhsNjFqQU5lcGJIU0psTEllWkNHaEVxNk1yckk4Vmd6U3JDVW52SzFRbXZtNkVHYmk3VXpZbXhnTlpDeHV3ZEZMT2p2SjdhbUtCSFpDd292cFhtalk1dVVtbVN3WTQ3OHdSZTJaQko1c3JlSzRsTTh1SkRZMXF5MVpCMTVPbFJCWkJUUHp0aFhrTHpWdzNlIiwiYWxnb3JpdGhtIjoiSE1BQy1TSEEyNTYiLCJpc3N1ZWRfYXQiOjE2NTM1OTI3ODV9; rur="NCG\0543452129080\0541685128538:01f79d1a9ee1aa131793acd9c7d2255efe098c75ca7d7ca5ce3f76774b51d2acbfe3904e"'

    return 'csrftoken=Z5opmD9LaNKbZiHr0OGHYFpgkE7gfj6W; mid=YjxsUgAEAAH3n1g3uBCKQwAF5hCv; ig_did=ACB08B6F-D252-4FC7-81ED-4EECFE23CBB6; ig_nrcb=1; fbm_124024574287414=base_domain=.instagram.com; ds_user_id=3452129080; sessionid=3452129080%3AHISxmbMWZysBkB%3A25; shbid="19869\0543452129080\0541684933480:01f7da7dc0bcdb4ef933fb3a1f24f2f3766053bde9cfb0c75996e4cae6b9a043615aa460"; shbts="1653397480\0543452129080\0541684933480:01f7ec716c837804dade3e17f2831651e9c7fe837d855bb4c33752c93a962ae14c07bdb1"; fbsr_124024574287414=hBFgbp8_-csv9ZMPEgO9bTth-Jj8pcrApcYDjHMSPgs.eyJ1c2VyX2lkIjoiNjAyNjE5Nzg2IiwiY29kZSI6IkFRQmRUaEFjbDFBWGNmN3ktQ1BhdHRzbGs3ZE1ZMWo0YUROekdtSHpJVUZRdkE1Nk1tc2pBSHB6d2htSzd2MDFEdlZZbF9tZUhwUTBfcVNyQXgyWEVIOFhHUVFNQ3g4eDlrb1JHdjVzdE8xOVozMHpWNUtQWWNDRGJuQUlfbngyX0hBczBacFRCWlJrQzNDdzFmZk9ad0xtZ3NwcS0wMHU5eHlWelBGaGZERmVBVTAtV2U3U2MyM0J4R3FuZHE0ekpMV043Zm13RGp3dk5iYTVqbm5VTXV0a3VXZnpfR04wNEJPbURfdWgyTzFzSHRSZnJwOHFGbXFvSTlPb1R0Vm5UVkRQQXRzZndKUXloWFJpZXEwcXU1SmNuX1NNZ0Z4dUhMMzhxQndKemVRMmNZd1JJN2NRcFRwdnJOdHVUTldZOGkwIiwib2F1dGhfdG9rZW4iOiJFQUFCd3pMaXhuallCQUFTbjZVMHFoQnBpaVpBeHhrZnA5MWVEbGI3RHhsNjFqQU5lcGJIU0psTEllWkNHaEVxNk1yckk4Vmd6U3JDVW52SzFRbXZtNkVHYmk3VXpZbXhnTlpDeHV3ZEZMT2p2SjdhbUtCSFpDd292cFhtalk1dVVtbVN3WTQ3OHdSZTJaQko1c3JlSzRsTTh1SkRZMXF5MVpCMTVPbFJCWkJUUHp0aFhrTHpWdzNlIiwiYWxnb3JpdGhtIjoiSE1BQy1TSEEyNTYiLCJpc3N1ZWRfYXQiOjE2NTM1OTI3ODV9; rur="NCG\0543452129080\0541685128538:01f79d1a9ee1aa131793acd9c7d2255efe098c75ca7d7ca5ce3f76774b51d2acbfe3904e"'

def download_data(igid):
    url = f'https://www.instagram.com/p/{igid}/'
    print(f'Downloading data from: {url}...')

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:100.0) Gecko/20100101 Firefox/100.0',
        'Cookie': get_cookie_header()
    }
    html_page = requests.get(url, headers = headers)

    if html_page.status_code == 200:
        content = html_page.text
#        write_file(content, 'instagram.html')
        page_title = re.search(r"\<title\>$\n(.*?)$\n\<\/title\>", content, re.M).group(1)

        if 'login' in page_title.lower():
            print("Couldn't login :'(")
            return {}
        else:
            print('Parsing additional data loaded...')
            additionalDataLoaded = re.search(f"window\.__additionalDataLoaded\(\'/p/{igid}/\',(.*?)\);<\/script>", content).group(1)
            additional_data = json.loads(additionalDataLoaded)
            return additional_data
    else:
        print("Couldn't download HTML page :'(")
        return {}

def get_item_metadata(item):
    print('Getting iteam metadata...')
    metadata = {}
    metadata['id'] = item['code']
    metadata['uploader_id'] = item['user']['username']
    metadata['title'] = f"Post by {metadata['uploader_id']}"
    metadata['fulltitle'] = metadata['title']
    metadata['description'] = item['caption']['text']
    metadata['timestamp'] = item['caption']['created_at']
    metadata['uploader'] = item['user']['full_name']
    metadata['like_count'] = item['like_count']
    metadata['comment_count'] = item['comment_count']
    metadata['extractor'] = 'Instagram'
    metadata['webpage_url'] = f"https://www.instagram.com/p/{metadata['id']}"
    metadata['webpage_url_basename'] = metadata['id']
    metadata['extractor_key'] = 'Instagram'
    metadata['display_id'] = metadata['id']
    metadata['upload_date'] = datetime.fromtimestamp(metadata['timestamp']).strftime("%Y%m%d")
    return metadata

def download_media(url, filename):
    print('Downloading media...')
    image = requests.get(url, stream = True)

    if image.status_code == 200:
        image.raw.decode_content = True
        with open(f'{OUTPUT_FOLDER}/{filename}', 'wb') as f:
            print(f'Saving image file: {filename}')
            shutil.copyfileobj(image.raw, f)
    else:
        print("Couldn't download image :'(")

def write_file(object, filename, is_json = False):
    print(f'Saving file: {filename}...')
    output_text = json.dumps(object, indent = 4) if is_json else object
    with open(f'{OUTPUT_FOLDER}/{filename}', 'w') as f:
        f.write(output_text)

def get_image_url_from_versions(image_versions2, metadata):
    if image_versions2 is None:
        print('No image_versions2 found!')
        return

    candidates = image_versions2['candidates']
    filtered_candidates = [c for c in candidates if c['width'] == metadata['width'] and c['height'] == metadata['height']]
    return candidates[0]['url'] if len(filtered_candidates) == 0 else filtered_candidates[0]['url']

def get_video_url_from_versions(video_versions, metadata):
    if video_versions is None:
        print('No video_versions found!')
        return

    filtered_version = [v for v in video_versions if v['width'] == metadata['width'] and v['height'] == metadata['height']]
    return video_versions[0]['url'] if len(filtered_version) == 0 else filtered_version[0]['url']

def process_carousel(item):
    carousel_media = item.get('carousel_media')

    if carousel_media is None:
        print('No carousel media found!')
        return

    print(f"Processing {item['carousel_media_count']} media item(s) from carousel...")
    for index, cm_item in enumerate(carousel_media):
        process_image(cm_item, carousel_media, index)
        process_video(cm_item, carousel_media, index)

def get_ext_from_url(url):
    return url.split('?')[0].split('.')[-1]

def process_image(item, carousel_media = None, index = None):
    image_versions2 = item.get('image_versions2') if carousel_media is None else carousel_media[index].get('image_versions2')
    if not image_versions2:
        print('No image data to process')
        return

    print('Processing image...')
    media_type = item['media_type']
    print(f'Media type: {media_type}')
    metadata['width'] = item.get('original_width') if carousel_media is None else carousel_media[index].get('original_width')
    metadata['height'] = item.get('original_height') if carousel_media is None else carousel_media[index].get('original_height')
    url = get_image_url_from_versions(image_versions2, metadata)
    metadata['url'] = url
    metadata['ext'] = get_ext_from_url(url)
    base_filename = f"{metadata['uploader_id']} - {metadata['id']}"
    image_filename = f"{base_filename}.{metadata['ext']}" if index is None else f"{base_filename} - {index + 1}.{metadata['ext']}"
    download_media(url, image_filename)
    write_file(metadata, f"{base_filename}.info.json", is_json = True)

def process_video(item, carousel_media = None, index = None):
    video_versions = item.get('video_versions') if carousel_media is None else carousel_media[index].get('video_versions')
    if not video_versions:
        print('No video data to process')
        return

    media_type = item['media_type']
    print(f'Media type: {media_type}')
    metadata['width'] = item.get('original_width') if carousel_media is None else carousel_media[index].get('original_width')
    metadata['height'] = item.get('original_height') if carousel_media is None else carousel_media[index].get('original_height')
    metadata['duration'] = item.get('video_duration') if carousel_media is None else carousel_media[index].get('video_duration')
    url = get_video_url_from_versions(video_versions, metadata)
    metadata['url'] = url
    metadata['ext'] = get_ext_from_url(url)
    base_filename = f"{metadata['uploader_id']} - {metadata['id']}"
    image_filename = f"{base_filename}.{metadata['ext']}" if index is None else f"{base_filename} - {index + 1}.{metadata['ext']}"
    download_media(url, image_filename)
    write_file(metadata, f"{base_filename}.info.json", is_json = True)

if len(sys.argv) < 2:
   print('Error, no IG ID found!')
   exit(0)

igid = sys.argv[1]
data_loaded = download_data(igid)
# write_file(data_loaded, 'data_loaded.json', is_json = True)

for item in data_loaded.get('items', []):
    print('Processing item from data loaded...')
    metadata = get_item_metadata(item)
    process_image(item)
    process_video(item)
    process_carousel(item)
