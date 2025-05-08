# Deployment Guide for LiveTranslator

This guide explains how to deploy the LiveTranslator application on your own server using Docker.

## Prerequisites

- A server with Docker and Docker Compose installed
- Access to GitHub packages (to pull the Docker image)

## Deployment Steps

### 1. Log in to GitHub Container Registry

You'll need to authenticate with GitHub Container Registry to pull the image:

```bash
# Create a Personal Access Token (PAT) on GitHub with 'read:packages' scope
# Then login using that token:
echo $GITHUB_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### 2. Modify docker-compose.yml

Edit the `docker-compose.yml` file to replace `[your-username]` with your actual GitHub username:

```yaml
image: ghcr.io/your-username/livetranslator:latest
```

### 3. Deploy with Docker Compose

```bash
# Pull the latest image and start the container
docker-compose up -d
```

Your application will now be running at `http://your-server-ip:3000`

### 4. Configure HTTPS (Recommended)

For production, it's recommended to set up HTTPS using a reverse proxy like Nginx or Traefik.

#### Example using Nginx:

1. Install Nginx:
   ```bash
   apt update
   apt install -y nginx
   ```

2. Create a Nginx configuration file:
   ```bash
   nano /etc/nginx/sites-available/livetranslator
   ```

3. Add the following configuration:
   ```
   server {
       listen 80;
       server_name your-domain.com;
       
       # Redirect HTTP to HTTPS
       return 301 https://$host$request_uri;
   }

   server {
       listen 443 ssl;
       server_name your-domain.com;
       
       ssl_certificate /path/to/fullchain.pem;
       ssl_certificate_key /path/to/privkey.pem;
       
       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

4. Enable the site and restart Nginx:
   ```bash
   ln -s /etc/nginx/sites-available/livetranslator /etc/nginx/sites-enabled/
   nginx -t
   systemctl restart nginx
   ```

### 5. Security Considerations

- Do not store API keys in the Docker image or environment variables
- The application is designed to let users input their own OpenAI API keys
- Ensure your server has proper firewall rules in place
- Keep your Docker and server updated with security patches

## Updating the Application

When a new version is pushed to GitHub, the GitHub Action will automatically build and push a new Docker image. To update your deployment:

```bash
# Pull the latest image
docker-compose pull

# Restart the container
docker-compose up -d
```

## Troubleshooting

### Check container logs
```bash
docker-compose logs
```

### Verify the container is running
```bash
docker ps
```

### Restart the container
```bash
docker-compose restart
```