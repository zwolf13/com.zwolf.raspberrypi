#! /usr/bin/env python3

import sqlite3
import os.path
import urllib.parse
import keyring
import sys
import math
from Crypto.Cipher import AES
from Crypto.Protocol.KDF import PBKDF2
from datetime import datetime, timedelta

def convertDateFromWebkit(webkit_timestamp):
    epoch_start = datetime(1601, 1, 1)
    delta = timedelta(microseconds = int(webkit_timestamp))
    full_date = epoch_start + delta

    return math.floor(datetime.timestamp(full_date))

def chrome_decrypt(encrypted_value, key=None):
    iv = b' ' * 16

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
    password = 'peanuts'.encode('utf8')
    cookie_file = os.path.expanduser('~/.config/chromium/Default/Cookies')
    sql_template = 'SELECT host_key, is_httponly, path, is_secure, expires_utc, name, value, encrypted_value FROM cookies WHERE host_key like "%{}%"'

    # Generating key
    # PBKDF2 parameters: password, salt, length=16, iterations=1
    key = PBKDF2(password, salt, 16, 1)

    # Part of the domain name that will help the sqlite3 query pick it from the Chrome cookies
    domain_tmp = urllib.parse.urlparse(url).path
    domain = '.'.join(domain_tmp.split('.')[-2:])
    connection = sqlite3.connect(cookie_file)
    sql = sql_template.format(domain)

    cookies = {}

    print("# Netscape HTTP Cookie File");
    print("# https://curl.haxx.se/rfc/cookie_spec.html");
    print("# This is a generated file! Do not edit.\n");

    with connection:
        cookies_tmp = []

        for host_key, is_httponly, path, is_secure, expires_utc, name, value, encrypted_value in connection.execute(sql):
            domain = '#HttpOnly_' + host_key if is_httponly == 1 else host_key
            is_host_only = 'TRUE'
            secure = 'TRUE' if is_secure == 1 else 'FALSE'
            expiration = convertDateFromWebkit(expires_utc) if expires_utc != 0 else expires_utc
            decrypted_value = value if value or (encrypted_value[:3] != b'v10') else chrome_decrypt(encrypted_value, key=key)

            cookies_tmp.append((domain, is_host_only, path, secure, expiration, name, decrypted_value))
            print(f"{domain}\t{is_host_only}\t{path}\t{secure}\t{expiration}\t{name}\t{decrypted_value}")

#        cookies.update(cookies_tmp)

#    print(cookies)

    return cookies

getChromiumCookies('www.youtube.com')
