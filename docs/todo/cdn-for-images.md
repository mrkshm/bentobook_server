1. Configure S3 for Website Hosting: Enable static website hosting on your S3 bucket. Note the bucket's website endpoint URL.

2. Point Cloudflare to S3: In your Cloudflare DNS settings, create a CNAME record (e.g., cdn.yourdomain.com) that points to the
S3 bucket's website endpoint URL from step 1.

3. Update Rails Configuration: In config/environments/production.rb, set your Active Storage asset host to point to your new
Cloudflare CNAME record. This tells Rails to generate CDN URLs (e.g., https://cdn.yourdomain.com/path/to/file) instead of
direct S3 URLs.


4. Lock Down S3 (Optional but Recommended): To maximize cost savings, update your S3 bucket policy to only allow access from
Cloudflare's IP addresses. This prevents users from bypassing the CDN and accessing your files directly from S3, which would
incur egress fees.