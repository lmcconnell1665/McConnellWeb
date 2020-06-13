![Continuous Deployment](https://github.com/lmcconnell1665/McConnellWeb/workflows/Continuous%20Deployment/badge.svg)

# McConnellWeb
A website built using [Hugo](https://gohugo.io) and the theme [LoveIt](https://hugoloveit.com).

For Development:
- source into the virtual environment containing the dependencies using  `source ~/.HugoWebsite/bin/activate` (for my dev environment only)
- use `curl ipinfo.io` to find the ip address of the development machine
- replace the baseURL with the ip address and run `hugo serve --bind=0.0.0.0 --port=8080 --baseURL=http://54.196.202.85 --disableFastRender`

For Production:
- push code into the master branch and it will be automatically deployed to the AWS S3 bucket (assuming all tests are passed) using the GitHub Actions.
