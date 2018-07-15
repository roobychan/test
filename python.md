# Python Note

## Syntax

+ Statement

```python
if condition:
    pass
elif:
    pass
```

```python
while condition:
    pass
    break
    continue
```

+ Type conversion

```python
type()
int()
float()
```

+ Input

```python
#Returns String
a = input("input")
```

+ Regex

```python
import re
match = re.match(r"pattern",str)
if match:
    result = match.group(0)
```

+ Class Attribute

```python
class MyClass:
    aList = []
    def __init__(self):
        aList = []
```

+ Proxy PIP

pip --proxy <http://roochen:Qlmt9axwa@10.94.66.246:8080>

+ Email Function

```python
# Import smtplib for the actual sending function
import smtplib

# Import the email modules we'll need
from email.message import EmailMessage
textfile = 'result.csv'
# Open the plain text file whose name is in textfile for reading.
with open(textfile) as fp:
    # Create a text/plain message
    msg = EmailMessage()
    msg.set_content(fp.read())

# me == the sender's email address
# you == the recipient's email address
msg['Subject'] = 'The contents of %s' % textfile
msg['From'] = 'rooby.chen@adp.com'
msg['To'] = 'rooby.chen@adp.com'

# Send the message via our own SMTP server.
s = smtplib.SMTP('localhost')
s.send_message(msg)
s.quit()
```


+ Socket

```python
import socket

mysock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
mysock.connect(('data.pr4e.org', 80))
cmd = 'GET http://data.pr4e.org/intro-short.txt HTTP/1.0\r\n\r\n'.encode()
mysock.send(cmd)

while True:
    data = mysock.recv(512)
    if len(data) < 1:
        break
    print(data.decode())

mysock.close()
```

+ Parsing HTML

```python
import bs4
from urllib import request
import re

url = 'http://py4e-data.dr-chuck.net/known_by_Brian.html'

name = ''
for i in range(7):
    fh = request.urlopen(url)
    soup = bs4.BeautifulSoup(fh.read(),'html.parser')
    tags = soup('li')
    print(tags[17])
    url = re.findall('href="(.+)"',str(tags[17].contents[0]))[0]
    name = re.findall('>(.+)</a>',str(tags[17].contents[0]))[0]

print(name)
```

+ Parse XML

```python
import urllib.request, urllib.parse, urllib.error
import xml.etree.ElementTree as ET

url = 'http://py4e-data.dr-chuck.net/comments_112268.xml'

tree = ET.fromstring(urllib.request.urlopen(url).read().decode())

counts = []

counts = tree.findall('.//count')
num = 0
for it in counts:
    num = num + int(it.text)

print(num)
```

+ Parsing JSON

```python
import urllib.request, urllib.parse, urllib.error
import json

url = 'http://py4e-data.dr-chuck.net/geojson?'
url = url + urllib.parse.urlencode({'address':'Vilnius Gediminas Technical University'})
data = json.loads(urllib.request.urlopen(url).read().decode())

print(data['results'][0]['place_id'])
```