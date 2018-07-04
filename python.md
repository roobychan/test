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