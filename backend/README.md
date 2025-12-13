# Eventaura Notification Server (FREE)

A simple Node.js backend that watches Firestore and sends FCM notifications. Deploy it for free on Railway, Render, or any other platform.

## Setup Instructions

### 1. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/project/eventaura-8bf9c/settings/serviceaccounts/adminsdk)
2. Navigate to: **Project Settings** > **Service Accounts**
3. Click **"Generate New Private Key"**
4. Save the downloaded JSON file as `serviceAccountKey.json` in this `backend` folder

### 2. Install Dependencies Locally (for testing)

```bash
cd backend
npm install
```

### 3. Test Locally

```bash
npm start
```

You should see:
```
🚀 Notification server started
👀 Watching Firestore for new notifications...
```

### 4. Deploy for FREE

#### Option A: Railway (Recommended - Easiest)

1. Create account at [Railway.app](https://railway.app)
2. Click **"New Project"** > **"Deploy from GitHub repo"**
3. Connect your GitHub account and select this repository
4. Set **Root Directory** to `backend`
5. Add **Environment Variable**:
   - Click **Variables**
   - Add your `serviceAccountKey.json` content as a JSON string (Railway will handle it)
   - OR upload the file directly via Railway dashboard

**Alternative (using Railway CLI):**
```bash
npm install -g @railway/cli
railway login
railway init
railway up
```

#### Option B: Render

1. Create account at [Render.com](https://render.com)
2. Click **"New +"** > **"Background Worker"**
3. Connect your GitHub repo
4. Set **Root Directory** to `backend`
5. Set **Build Command**: `npm install`
6. Set **Start Command**: `npm start`
7. Add **Environment Variables** or upload `serviceAccountKey.json` as a secret file

#### Option C: Fly.io

1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Login: `fly auth login`
3. Deploy:
```bash
cd backend
fly launch --no-deploy
fly secrets set GOOGLE_APPLICATION_CREDENTIALS="$(cat serviceAccountKey.json)"
fly deploy
```

#### Option D: Your Own VPS (DigitalOcean, Linode, etc.)

```bash
# SSH into your server
cd /opt
git clone <your-repo>
cd Eventaura-flutter-app/backend
npm install

# Install PM2 for process management
npm install -g pm2
pm2 start index.js --name eventaura-notifications
pm2 startup
pm2 save
```

### 5. Verify It's Working

1. Create a booking in your app
2. Check the server logs:
   - Railway: Dashboard > Deployments > Logs
   - Render: Dashboard > Logs
   - Local: Terminal output

You should see:
```
📤 Sending notification to token: xxxxx...
✅ Notification sent successfully
✓ Marked as read
```

## How It Works

1. User creates a booking in the app
2. App writes notification doc to Firestore `notifications` collection
3. This server (running 24/7 for free) detects the new document
4. Server sends FCM push notification using HTTP v1 API
5. Server marks the notification as `read: true`
6. User receives notification even if app is closed!

## Free Tier Limits

- **Railway**: 500 hours/month (enough for 24/7), 512MB RAM
- **Render**: 750 hours/month, auto-sleeps after 15min inactivity (spins up in seconds)
- **Fly.io**: 3 shared-cpu VMs, 256MB RAM each

All are free forever, no credit card required (Railway now requires credit card but doesn't charge).

## Troubleshooting

**Server not receiving notifications?**
- Check Firestore rules allow reading `notifications` collection
- Verify `serviceAccountKey.json` is valid
- Check server logs for errors

**Notifications not delivered?**
- Verify FCM tokens are valid
- Check device has internet connection
- Ensure app has notification permissions

**Railway/Render sleeping?**
- Railway: Stays awake 24/7 on free tier
- Render: Sleeps after 15min, wakes on Firestore activity (may have slight delay)
- Solution: Upgrade to paid plan (~$5/month) or use Railway

## Security Notes

- `serviceAccountKey.json` has admin access - keep it secure!
- Never commit it to git (already in `.gitignore`)
- Use environment variables on hosting platforms
- Consider rotating keys periodically in Firebase Console
