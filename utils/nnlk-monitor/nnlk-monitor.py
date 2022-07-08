import urllib.request
import urllib.error
import urllib.parse
from lxml import etree

url = 'https://www.youtube.com/results?search_query=girl+snoring&sp=CAM%253D'
response = urllib.request.urlopen(url)
html = etree.HTML(response.read())
pretty = etree.tostring(html, pretty_print=True, method="html")
print(pretty.decode('UTF-8'))
