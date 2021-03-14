#! /usr/bin/env python3

import sqlite3
import os.path
import urllib.parse
import keyring
import sys
from Crypto.Cipher import AES
from Crypto.Protocol.KDF import PBKDF2
from datetime import datetime, timedelta

def convertDateFromWebkit(webkit_timestamp):
    epoch_start = datetime(1601, 1, 1)
    delta = timedelta(microseconds = int(webkit_timestamp))

    return epoch_start + delta

def chrome_decrypt(encrypted_value, key=None):
    # Encrypted cookies should be prefixed with 'v10' according to the
    # Chromium code. Strip it off.
    encrypted_value = encrypted_value[3:]

    # Strip padding by taking off number indicated by padding
    # eg if last is '\x0e' then ord('\x0e') == 14, so take off 14.
    # You'll need to change this function to use ord() for python2.
    def clean(x):
        return x[:-x[-1]].decode('utf8')

    cipher = AES.new(key, AES.MODE_CBC, IV=iv)
    decrypted = cipher.decrypt(encrypted_value)

    return clean(decrypted)

def getChromiumCookies(url):
    salt = b'saltysalt'
    iv = b' ' * 16
    password = 'peanuts'.encode('utf8')
    cookie_file = os.path.expanduser('~/.config/chromium/Default/Cookies')
    sql_template = 'SELECT host_key, is_httponly, path, is_secure, expires_utc, name, value, encrypted_value FROM cookies WHERE host_key like "%{}%"'

    # Generating key
    # PBKDF2 parameters: password, salt, length=16, iterations=1
    key = PBKDF2(password, salt, 16, 1)

    # Part of the domain name that will help the sqlite3 query pick it from the Chrome cookies
    domain_tmp = urllib.parse.urlparse(url).netloc
    domain = '.'.join(domain_tmp.split('.')[-2:])

    connection = sqlite3.connect(cookie_file)
    sql = sql_template.format(domain)

    cookies = {}

    with connection:
        cookies_tmp = []
        
        for host_key, is_http_only, path, is_secure, expires_utc, name, value, encrypted_value in conn.execute(sql):
            is_host_only = 'PENDING'
            secure = 'TRUE' if is_secure == 1 else 'FALSE'
            expiration = convertDateFromWebkit(expires_utc)
            decrypted_value = value if value or (encrypted_value[:3] != b'v10') else chrome_decrypt(encrypted_value, key=key)
            
            cookies_tmp.append((host_key, is_host_only, path, secure, expiration, name, decrypted_value))

        cookies.update(cookies_tmp)
    
    print(cookies)

    return cookies

getChromiumCookies('www.youtube.com')
