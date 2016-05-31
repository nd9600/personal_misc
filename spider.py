import urllib2
import time
import re
from urlparse import urlparse
import Queue

hitNetlocs = ["reddit.com"]
urlQueue = Queue.Queue()
urlQueue.put("http://www.reddit.com")

count = 0

headers = { 'User-Agent' : 'Mozilla/5.0' }
while (not urlQueue.empty()):
    
    originalURL = urlQueue.get()
    headers = { 'User-Agent' : 'Mozilla/5.0' }
    request = urllib2.Request(originalURL, None, headers)
    try:
        html = urllib2.urlopen(request).read()
        links = re.findall('"((http)s?://.*?)"', html)
        links = [link[0] for link in links]

        for link in links:
            oldNetloc = urlparse(originalURL).netloc
            newNetloc = urlparse(link).netloc
                
            if (newNetloc not in hitNetlocs):

                hitNetlocs.append(newNetloc)
                count = count + 1
                
                newScheme = urlparse(link).scheme
                newURL = newScheme + "://" + newNetloc
                urlQueue.put(newURL)
                print ""
                print "hitNetlocs:", hitNetlocs
                print count
                #time.sleep(0.1)
    except Exception:
        pass