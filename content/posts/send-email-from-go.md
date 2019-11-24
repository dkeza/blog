---
title: "How to send E-Mail from Go"
date: 2019-04-21T10:21:19+02:00
draft: false
staticpage: "no"
---
I wanted to create small service in Go, which should asynchronously send E-Mails created on web site.

<!--more-->

Web site is actually a reservation web page for hotel, where guests can directly book reservations, without going to some channel provider web site, like booking.com, hotels.com etc.

At the end, when reservation is confirmed, user receives E-Mail with conformation. Currently E-Mail is send directly from server, in same thread, and guest must wait until E-Mail is received by SMTP server.

I know this is not a good practice, and I wanted to change this. Lastly I am using Go for such cases, mostly because of single binary which ca be easily be installed as service on client site. For this, I also use [nssm.exe](https://nssm.cc/) which allows any executable to be started as Windows service.

# Code it all self in Go, or use third party library?

Every choice has it benefits. At first, I tried to send E-Mail using code examples from standard library. I had some success, but there are some issues when sending E-Mail over Gmail SMTP server on port 465. As it turns out, on port 567 is used *Submission for Simple Mail Transfer* (submission) and on port 465 is used *smtp protocol over TLS* (smtps).

OK, it is not so simple, so I checked is there some third party solution for this on Github.

I found on Github [Gomail](https://github.com/go-mail/mail) project. This is fork of original Gomail project, and it is actively maintained.

# How to install Gomail

As usual, use go get command:
```golang
go get -v gopkg.in/mail.v2
```

# Example how to use it

Here is basic example, how we can use Gomail
{{< highlight go >}}
package main

import (
	"bytes"
	"crypto/tls"
	"io/ioutil"

	gomail "gopkg.in/mail.v2"
)

func main() {
    m := gomail.NewMessage()
    
    // Set E-Mail sender
    m.SetHeader("From", "mymail@example.com")
    
    // Set E-Mail receivers
    m.SetHeader("To", "someguy@example.com")
    m.SetHeader("Cc", "anotherguy@example.com")
    m.SetHeader("Bcc", "office@example.com", "anotheroffice@example.com")
    
    // Set E-Mail subject
    m.SetHeader("Subject", "Test E-Mail 2")
    
    // Set E-Mail body. You can set plain text or html with text/html
    m.SetBody("text/plain", "Test E-Mail Body")
    
    // Attach some file
    m.Attach("myfile1.pdf")

    // Settings for SMTP server
    d := gomail.NewDialer("mail.example.com", 465, "mymail@example.com", "secret")
    
    // This is only needed when SSL/TLS certificate is not valid on server.
    // In production this should be set to false.
    d.TLSConfig = &tls.Config{InsecureSkipVerify: true}

    // Save E-Mail in mymail.txt file

    // Get directory where binary is started
    dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
    if err != nil {
            panic(err)
    }

    // Write contents of E-Mail into mymail.txt.
    // This is useful for debuging.
    var b bytes.Buffer
    m.WriteTo(&b)
    err := ioutil.WriteFile(dir + `mymail.txt`, b.Bytes(), 0777)
    if err != nil {
        panic(err)
    }

    // Now send E-Mail
    if err := d.DialAndSend(m); err != nil {
        panic(err)
    }

    return
}
{{< /highlight >}}

`panic` command is here used because this is simple example, but in production is better to return err to caller.


# Bottom line

Until now Gomail is working without issues. I can only recommend it.
So, give it a try!