#!/usr/bin/python
# -*- coding: utf-8 -*-

import urllib2

with open("list.txt") as f:
    for url in f:
        url = url.rstrip('\n')
        try:
            response = urllib2.urlopen(url)
            print "{:<42}{:<5}".format(url, '- OK')
        except urllib2.HTTPError, e:
            print "{} \t\t\t - HTTP Error Code: ", e.code
            print e.info()
        except urllib2.URLError, e2:
            print "{} \t\t\t - URL Error Code: ", e2.reason
        finally:
            response.close()



