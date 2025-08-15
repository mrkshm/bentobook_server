# CDN Setup for Image Optimization

This document provides specific instructions for setting up a CDN with Cloudflare in front of S3 as part of our [Image Optimization Strategy](./image-optimization-strategy.md).

## Prerequisites
- A Cloudflare account with your domain configured
- An S3 bucket for storing images
- Rails application with Active Storage configured for S3

## Setup: Cloudflare in front of Rails (recommended)

1. **Put your app behind Cloudflare**
   - Orange-cloud the apex/app host in Cloudflare DNS.
   - No origin host header tricks required; Cloudflare talks to your Rails app.

2. **Add a Cache Rule for Active Storage**
   - Path: `/rails/active_storage/*`
   - Cache level: Cache everything
   - Edge TTL: 1 year (or Respect origin)
   - Origin cache control: On
   - Cache key: Include query string

3. **Rails configuration (already present)**
   - Proxy mode: `config.active_storage.resolve_model_to_route = :rails_storage_proxy`
   - Long expiries: `service_urls_expire_in` and `urls_expire_in` set to `1.year`
   - Cache headers middleware sets `Cache-Control: public, max-age=31536000, immutable` for `/rails/active_storage/*`

4. **S3**
   - Keep the bucket private. No public-read policy needed because Rails fetches from S3 using credentials.
   - Direct uploads continue via Active Storage’s presigned URLs/IAM.

This is the lowest-friction, most stable setup for early-stage scale.

## Alternative: Cloudflare in front of S3 (service URLs)

If you prefer emitting direct service URLs on a CDN host instead of caching Rails routes:

1. **Create a CDN host** (e.g., `cdn.yourdomain.com`) and proxy it through Cloudflare.
2. **Origin mapping**: Use a Cloudflare Origin Rule to set origin hostname and Host header override to your S3 endpoint (`your-bucket.s3.<region>.amazonaws.com`).
3. **Cache Rule**: Cache everything for that CDN host, long TTL, include query string, respect origin.
4. **Rails**: Set `config.active_storage.asset_host = "https://cdn.yourdomain.com"` for URLs that should resolve to the CDN host.
5. **S3 bucket policy (optional)**: Allow reads only from Cloudflare IPs; keep uploads via IAM. Example policy:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "AllowCloudflareReadAccess",
         "Effect": "Allow",
         "Principal": "*",
         "Action": ["s3:GetObject"],
         "Resource": "arn:aws:s3:::your-bucket-name/*",
         "Condition": {
           "IpAddress": { "aws:SourceIp": ["173.245.48.0/20","103.21.244.0/22","103.22.200.0/22","103.31.4.0/22","141.101.64.0/18","108.162.192.0/18","190.93.240.0/20","188.114.96.0/20","197.234.240.0/22","198.41.128.0/17","162.158.0.0/15","104.16.0.0/13","104.24.0.0/14","172.64.0.0/13","131.0.72.0/22"] }
         }
       },
       {
         "Sid": "AllowDirectUploads",
         "Effect": "Allow",
         "Principal": { "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:role/your-upload-role" },
         "Action": ["s3:PutObject","s3:PutObjectAcl"],
         "Resource": "arn:aws:s3:::your-bucket-name/uploads/*"
       }
     ]
   }
   ```

   Notes:
   - Replace placeholders; keep Cloudflare IPs updated: https://www.cloudflare.com/ips/
   - You usually don’t need `s3:ListBucket` for reads; omit to avoid listing.
   - Consider object-level Cache-Control in S3 if you set “Respect origin”.

## Next Steps
- See the [Image Optimization Strategy](./image-optimization-strategy.md) for how this integrates.
- For variant generation and optional two-file strategy, refer to that document.