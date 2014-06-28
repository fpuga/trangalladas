#!/usr/bin/python
# -*- coding: utf-8 -*-

import urllib2

with open("list.txt") as f:
    for url in f:
        url = url.rstrip('\n')
        try:
            response = urllib2.urlopen(url)
            print "{} \t\t\t - OK".format(url)
        except urllib2.HTTPError, e:
            print "Error Code: ", e.code
            print e.info()
        except urllib2.URLError, e2:
            print "Error Code: ", e2.reason
        finally:
            response.close()



