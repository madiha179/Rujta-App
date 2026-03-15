import fs from 'fs';
import { convert } from 'html-to-text';
import nodemailer from 'nodemailer';
import https from 'https';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default class Email {
  constructor(user, otp) {
    this.to = user.email;
    this.firstName = user.name.split(' ')[0];
    this.otp = otp;
    this.from = process.env.EMAIL_FROM;
  }

  async send(template, subject) {
    let html = fs.readFileSync(`${__dirname}/../view/${template}.html`, 'utf-8');
    html = html.replace('{{firstName}}', this.firstName).replace('{{otp}}', this.otp);
    const textContent = convert(html);

    try {
      if (process.env.NODE_ENV === 'production') {
        // Brevo production email (same as before)
        const payload = JSON.stringify({
          sender: { email: this.from, name: 'Rujta' },
          to: [{ email: this.to }],
          subject,
          htmlContent: html,
          textContent
        });

        await new Promise((resolve, reject) => {
          const options = {
            hostname: 'api.brevo.com',
            path: '/v3/smtp/email',
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'api-key': process.env.BREVO_API_KEY,
              'Content-Length': Buffer.byteLength(payload)
            }
          };

          const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => { data += chunk; });
            res.on('end', () => {
              if (res.statusCode >= 200 && res.statusCode < 300) resolve(data);
              else reject(new Error(`Brevo API error: ${res.statusCode} - ${data}`));
            });
          });

          req.on('error', reject);
          req.write(payload);
          req.end();
        });

      } else {
        // Mailtrap development email
        const transporter = nodemailer.createTransport({
          host: process.env.EMAIL_HOST,
          port: Number(process.env.EMAIL_PORT),
          auth: {
            user: process.env.EMAIL_USERNAME,
            pass: process.env.EMAIL_PASSWORD
          }
        });

        await transporter.sendMail({
          to: this.to,
          from: this.from,
          subject,
          html,
          text: textContent
        });
      }

    } catch (err) {
      console.error('Email send error:', err);
      throw new Error('There was an error sending the email. Try again later!');
    }
  }

  async sendResetPassword() {
    await this.send('resetPassEmail', 'Your Password reset OTP valid for only 10 minutes');
  }

  async sendOTP() {
    await this.send('sendOTP', 'Send OTP verification');
  }
}