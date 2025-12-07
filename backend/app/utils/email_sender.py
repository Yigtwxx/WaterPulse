import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# TODO: Kullanıcı bu bilgileri doldurmalı
EMAIL_USER = "YOUR_EMAIL@gmail.com"
EMAIL_PASSWORD = "YOUR_APP_PASSWORD"  # Gmail için App Password gerekli

def send_email(to_email: str, subject: str, body: str):
    if "YOUR_EMAIL" in EMAIL_USER:
        print(f"[WARNING] Email credentials not set. Skipping email to {to_email}.")
        print(f"Subject: {subject}")
        print(f"Body: {body}")
        return

    try:
        msg = MIMEMultipart()
        msg['From'] = EMAIL_USER
        msg['To'] = to_email
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        # Gmail SMTP sunucusu
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(EMAIL_USER, EMAIL_PASSWORD)
        text = msg.as_string()
        server.sendmail(EMAIL_USER, to_email, text)
        server.quit()
        print(f"[SUCCESS] Email sent to {to_email}")
    except Exception as e:
        print(f"[ERROR] Failed to send email: {e}")
