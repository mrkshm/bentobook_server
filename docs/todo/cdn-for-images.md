# CDN Setup for Image Optimization

This document provides specific instructions for setting up a CDN with Cloudflare in front of S3 as part of our [Image Optimization Strategy](./image-optimization-strategy.md).

## Prerequisites
- A Cloudflare account with your domain configured
- An S3 bucket for storing images
- Rails application with Active Storage configured for S3

## Setup Steps

1. **Configure Private S3 Bucket**
   - Create a private S3 bucket (do not enable public access)
   - Note the bucket name and region

2. **Set Up Cloudflare CDN**
   - In your Cloudflare DNS settings, create a CNAME record (e.g., `cdn.yourdomain.com`)
   - Configure Cloudflare to proxy traffic to your S3 bucket
   - Set up a page rule to cache everything with a long TTL

3. **Update Rails Configuration**
   In `config/environments/production.rb`:
   ```ruby
   config.active_storage.service = :amazon
   config.active_storage.asset_host = 'https://cdn.yourdomain.com'
   ```

4. **Secure S3 Access**
   Configure your S3 bucket policy to balance security and functionality. Here's an example policy that:
   - Allows public read access only through Cloudflare's IPs
   - Enables direct uploads with proper authentication
   - Maintains security through IAM policies

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "AllowCloudFrontReadAccess",
               "Effect": "Allow",
               "Principal": "*",
               "Action": ["s3:GetObject", "s3:ListBucket"],
               "Resource": [
                   "arn:aws:s3:::your-bucket-name",
                   "arn:aws:s3:::your-bucket-name/*"
               ],
               "Condition": {
                   "IpAddress": {
                       "aws:SourceIp": [
                           "173.245.48.0/20",
                           "103.21.244.0/22",
                           "103.22.200.0/22",
                           "103.31.4.0/22",
                           "141.101.64.0/18",
                           "108.162.192.0/18",
                           "190.93.240.0/20",
                           "188.114.96.0/20",
                           "197.234.240.0/22",
                           "198.41.128.0/17",
                           "162.158.0.0/15",
                           "104.16.0.0/13",
                           "104.24.0.0/14",
                           "172.64.0.0/13",
                           "131.0.72.0/22"
                       ]
                   }
               }
           },
           {
               "Sid": "AllowDirectUploads",
               "Effect": "Allow",
               "Principal": {
                   "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:role/your-upload-role"
               },
               "Action": [
                   "s3:PutObject",
                   "s3:PutObjectAcl"
               ],
               "Resource": "arn:aws:s3:::your-bucket-name/uploads/*"
           }
       ]
   }
   ```

   **Important Notes**:
   - Replace `your-bucket-name` with your actual S3 bucket name
   - Replace `YOUR_ACCOUNT_ID` with your AWS account ID
   - The `uploads/*` path ensures uploads go to a specific prefix
   - Cloudflare IPs should be kept up-to-date (check [Cloudflare's IP Ranges](https://www.cloudflare.com/ips/))
   - For production, consider using AWS IAM roles with temporary credentials for uploads

   This approach:
   - Ensures secure direct uploads to S3 using IAM roles
   - Restricts downloads to Cloudflare's network
   - Maintains a private bucket with specific, controlled access

## Next Steps
- See the [Image Optimization Strategy](./image-optimization-strategy.md) for details on how this CDN integrates with our overall image handling approach.
- For implementation details on the two-file strategy and variant generation, refer to the main optimization document.