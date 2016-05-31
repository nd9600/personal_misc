# import urllib2
# import time
# import re
# from urlparse import urlparse
# import Queue

# urlQueue = Queue.Queue()
# urlQueue.put("http://www.reddit.com")

# headers = { 'User-Agent' : 'Mozilla/5.0' }
# while (not urlQueue.empty()):
    
    # request = urllib2.Request(, None, headers)
    # html = urllib2.urlopen(request).read()
    # links = re.findall('"((http|https)s?://.*?)"', html)
    # parsedLinks = [urlparse(link[0]) for link in links]


    
# for link in parsedLinks:
    # print "Parsed link:", link.netloc

    
import urllib2
import time
import re
from urlparse import urlparse

originalURL = "http://www.reddit.com"
headers = { 'User-Agent' : 'Mozilla/5.0' }
request = urllib2.Request(originalURL, None, headers)
html = urllib2.urlopen(request).read()
links = re.findall('"((http)s?://.*?)"', html)
links = [link[0] for link in links]

for link in links:
    oldNetloc = urlparse(originalURL).netloc

    newScheme = urlparse(link).scheme
    newNetloc = urlparse(link).netloc
    newURL = newScheme + "://" + newNetloc
    print ""
    print "originalURL:", originalURL
    print "oldNetloc:", oldNetloc
    print "Link:", link
    print "netloc:", newNetloc
    print "newURL:", newURL
    print "oldNetloc != newNetloc: ", oldNetloc != newNetloc
    

#parsedLinks = [link[0] for link in links if urlparse(link[0]).netloc != originalURL]
    
#for link in parsedLinks:
    #print "Parsed link:", link
#time.sleep(2)