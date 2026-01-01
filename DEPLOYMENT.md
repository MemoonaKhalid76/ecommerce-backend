# Deployment Guide

This guide details how to deploy your Node.js/Express backend to **Render**, a cloud provider that offers a free tier and easy setup.

## Prerequisites

1.  **Git Repository**: Your code must be pushed to a Git repository (GitHub, GitLab, etc.).
2.  **Render Account**: Create an account at [render.com](https://render.com/).

## Deployment Steps (Render)

1.  **New Web Service**
    *   Click "New +" and select "Web Service".
    *   Connect your GitHub/GitLab account and select your repository `ecommerce`.

2.  **Configure Service**
    *   **Name**: `ecommerce-backend` (or your preferred name)
    *   **Region**: Select the one closest to you.
    *   **Branch**: `main` (or your working branch).
    *   **Root Directory**: `backend` (Important: since your backend is in a distinct folder).
    *   **Runtime**: `Node`
    *   **Build Command**: `npm install`
    *   **Start Command**: `node index.js` (or `npm start`)

3.  **Environment Variables**
    *   Scroll down to the **Environment Variables** section.
    *   Click "Add Environment Variable" for each key in your `.env` file:
        *   `MONGO_URI`: (Your MongoDB connection string - **Make sure to allow access from anywhere (0.0.0.0/0) in MongoDB Atlas Network Access**)
        *   `JWT_SECRET`: (Your secret key)
        *   `EMAIL_USER`: (Your email for OTP)
        *   `EMAIL_PASS`: (Your app password)
        *   `NODE_ENV`: `production`

4.  **Deploy**
    *   Click "Create Web Service".
    *   Render will clone your repo, install dependencies, and start the server.
    *   Watch the logs for "Server running on port ...".

## Troubleshooting

*   **Database Connection Failed**:
    *   Go to **MongoDB Atlas** > **Network Access**.
    *   Add IP Address: `0.0.0.0/0` (Allow Access from Anywhere) to allow Render to connect.
*   **Build Failed**: Check the logs. Ensure `package.json` is valid and dependencies can be installed.

## Other Providers

The setup is similar for Railway, Heroku, or other providers:
*   **Build Command**: `npm install`
*   **Start Command**: `npm start`
*   **Environment Variables**: Must be set in the provider's dashboard.
