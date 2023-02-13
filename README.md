![Continuous Deployment](https://github.com/lmcconnell1665/McConnellWeb/workflows/Continuous%20Deployment/badge.svg)

# [McConnellWeb](http://mcconnellweb.com/)
A static website built using [Hugo](https://gohugo.io) and the theme [LoveIt](https://hugoloveit.com). This website is hosted in an AWS S3 bucket and continuous deployment is provided by GitHub Actions. I have configured the domain name [McConnellWeb.com](http://mcconnellweb.com/) to point to an AWS CloudFront distribution which deploys the contents of the S3 bucket to edge locations all over the world.

[Tutorial on how I am using GitHub Actions to deploy this website](https://mcconnellweb.com/posts/post4/)

For Development:
- source into the virtual environment containing the dependencies using  `source ~/.McConnellWeb/bin/activate` (for my dev environment only)
- use `curl ipinfo.io` to find the ip address of the development machine
- replace the baseURL with the ip address and run `hugo serve --bind=0.0.0.0 --port=8080 --baseURL=http://75.49.173.825 --disableFastRender`

For Production:
- push code into the master branch and it will be automatically deployed to the AWS S3 bucket (assuming all tests are passed) using the GitHub Actions.
