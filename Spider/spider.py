#!/usr/bin/python

from __future__ import with_statement
import urllib2
import time
import re
import Queue
from urlparse import urlparse

#From http://stackoverflow.com/a/1069780

# load tlds, ignore comments and empty lines:
with open("effective_tld_names.dat.txt") as tld_file:
    tlds = set([line.strip() for line in tld_file if line[0] not in "/\n"])

def get_domain(url, tlds):
    url_elements = urlparse(url)[1].split('.')
    # url_elements = ["abcde","co","uk"]

    for i in range(-len(url_elements), 0):
        last_i_elements = url_elements[i:]
        #    i=-3: ["abcde","co","uk"]
        #    i=-2: ["co","uk"]
        #    i=-1: ["uk"] etc

        candidate = ".".join(last_i_elements) # abcde.co.uk, co.uk, uk
        wildcard_candidate = ".".join(["*"] + last_i_elements[1:]) # *.co.uk, *.uk, *
        exception_candidate = "!" + candidate

        # match tlds: 
        if (exception_candidate in tlds):
            return ".".join(url_elements[i:]) 
        if (candidate in tlds or wildcard_candidate in tlds):
            return ".".join(url_elements[i-1:])
            # returns "abcde.co.uk"

    raise ValueError("Domain not in global list of TLDs")
    
firstURL = "http://www.wikipedia.org"
netlocsAlreadyInQueue = [urlparse(firstURL).netloc]
urlQueue = Queue.Queue()
urlQueue.put(firstURL)

numberOfRequests = 0

print ""
print "#################"
print "firstURL:", firstURL

headers = { 'User-Agent' : 'Mozilla/5.0' }
while (not urlQueue.empty()):
    
    hitURL = urlQueue.get()
    hitNetloc = urlparse(hitURL).netloc
    print ""
    print "#################"
    print "hitURL:", hitURL
    time.sleep(2)
    
    headers = { 'User-Agent' : 'Mozilla/5.0' }
    request = urllib2.Request(hitURL, None, headers)
    try:
        openedRequest = urllib2.urlopen(request, timeout = 5)
        html = openedRequest.read()
        numberOfRequests = numberOfRequests + 1
        links = re.findall('"((http)s?://.*?)"', html)
        links = [link[0] for link in links]

        for link in links:
            newNetloc = get_domain(link, tlds)
                
            if (newNetloc not in netlocsAlreadyInQueue):
                netlocsAlreadyInQueue.append(newNetloc)
                
                newScheme = urlparse(link).scheme
                newURL = newScheme + "://" + newNetloc
                urlQueue.put(newURL)
                print ""
                print "netlocsAlreadyInQueue:", netlocsAlreadyInQueue
                print "urlQueue.size():", urlQueue.qsize()
                print "totalQueueSize:", len(netlocsAlreadyInQueue)
                print "numberOfRequests:", numberOfRequests
                #time.sleep(0.5)
    except Exception as e:
        print "Exception:", e
        pass
    finally:
        try:
            openedRequest.close()
        except Exception as e: 
            print "Exception:", e
            pass
