

# Sender and Recipient Info
$MailFrom = "Good.Time.Annie@rcpa.edu.au"
$MailTo = "braeden.saxon@canaryit.com.au"

# Sender Credentials
$Username = "smtp-backups@rcpa.edu.au"
$Password = "SS"

# Server Info
$SmtpServer = "au-smtp-outbound-1.mimecast.com"
$SmtpPort = "587"

# Message stuff
$MessageSubject = "Live your best life now" 
$Message = New-Object System.Net.Mail.MailMessage $MailFrom,$MailTo
$Message.IsBodyHTML = $true
$Message.Subject = $MessageSubject
$Message.Body = @'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
This is a test message to test email delivery.
</body>
</html>
'@

# Construct the SMTP client object, credentials, and send
$Smtp = New-Object Net.Mail.SmtpClient($SmtpServer,$SmtpPort)
$Smtp.EnableSsl = $true
$Smtp.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
$Smtp.Send($Message)