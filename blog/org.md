## Overview

Another daring, exciting, and shocking [#CloudGuruChallenge](https://acloudguru.com/blog/engineering/cloudguruchallenge-your-resume-on-gcp). This challenge is brought to us by my favorite GCP instructor at [acloudguru](acloudguru.com) Mattias Andersson. Similar to the [Apr, 21 #CloudGuruChallenge](https://dev.to/wheelerswebsites/apr-21-cloudguruchallenge-3fch) and the original [Cloud Resume Challenge](https://forrestbrazeal.com/2020/04/23/the-cloud-resume-challenge/) we were challenged to create our digital resume. The catch this time was that it had to be hosted on GCP! Well that along with a handful of other creative twists. 

Specifically: 
* the video call presentation :astonished:
* the GitOps-style approach to CI/CD :dizzy_face:

At the start of this challenge I found myself contemplating how I can leverage the work I did back in Apr, 21. When I participated in that challenge I took it very seriously with the intention of using that product as my living Resume. So you can understand my dilemma when I did not want to create an alternate digital Resume that would essentially be throw away. After days of mental deliberations and some great feedback I came to the conclusion that I would expand my original project and host my digital Resume on three cloud providers (AWS, Azure, and GCP) simultaneously. 

That discussion grew into it's own thing called the ["Meta Resume Challenge"](https://dev.to/wheelerswebsites/meta-resume-challenge-5a1a). With that in mind I took a unique approach to completing this challenge that I hope will be clear to everyone. 

First, I cloned my original repository from Apr, 21 as the base and archived the original for future memories. This repository will evolve into the Meta Resume Challenge so all of the changes had to fit that vision. 

* Cloud agnostic solutions
* Uniform technology stack
* etc.

> https://github.com/wheelers-websites/Resume

Next, I created brand new repositories specifically for this challenge. When I had to implement some requirement that fell outside of my vision for the Meta Resume Challenge I implemented that here. Admittedly though the web code in these repositories does not make up my resume. Instead I built a simple Vue app that redirects to my Meta Resume Challenge website. 

> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-app
> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-env
> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-web

Both entities are still their own completely isolated websites. That's proven by the fact that I deployed both sets of infrastructure into separate GCP projects and managed them in separate Terraform Cloud workspaces. I did reuse a majority of the Terraform templates as the GCP infrastructure is alike. 

![GCP Projects List](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/pvjpapxbo4wjxwa0kq42.PNG)

![Terraform Workspace List](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/m1vsrawcq8tt1jf3hmul.PNG)

## Splitting Requirements

These requirements were fine to leverage as part of the Meta Resume Challenge so I implemented them there.
* Cloud CDN
* Cloud Load Balancer
* Cloud Run
* Cloud Storage
* GitHub Actions
* Terraform

These requirements were not fine as part of the Meta Resume Challenge so they were implemented in the other repositories. I will even elaborate on why I think that.

* Cloud Build
* Cloud Source Repositories
I am already using GitHub Actions for CI/CD for the frontend and backend. I didn't want to implement multiple CI/CD solutions for a single application. Furthermore, I didn't want to use a cloud provider specific product when I am trying to create fault tolerance through cloud provider failures.

* Cloud DNS
* Cloud Domains
I am already using Route 53 for DNS registration and management. The multi-cloud routing is extra complicated since I am planning to use features like weighted routing and health checking. It may be true that these do exist within GCP, it is equally true that I am not as comfortable with them as I am with Route 53. 

* Python
I am already using Java for the backend. I didn't want the effort of managing multiple backend technologies for this single application. 

____

## Architecture

I registered a domain name to use temporarily for the website with Cloud Domain and created a hosted zone on Cloud DNS for routing. That DNS name is: `wheelersadvice`. I was thinking of repurposing this name if I ever get into personal consulting. Side note I would love your thoughts on that idea?  

* Backend: https://api.wheelersadvice.com
* Frontend: https://www.wheelersadvice.com

The static Vue content is hosted in a Cloud Storage bucket. I setup a Cloud Load Balancer and Cloud CDN in front of that. I am using Cloud Build to automatically provide CI/CD for frontend deployments. I had to split the web code into it's own repository since unlike GitHub Actions I could not find a clean way to only trigger builds when a sub-directory changes. I started with a mono repository and got tired of my web code deploying every time I changed the backend or infrastructure.

I re-wrote the backend visitor implementation in Python, after I already had it working in Java. I did this because Mattias hinted towards a Python preference and I knew some people also working with Python for the same project that I wanted to better assist. The visitor count is stored in Firestore. 

Authentication between Cloud Run and Firestore is being done through the service account JSON key credentials being provided through an environment variable. I'll admit that this may not be the most secure solution. At the time it seemed that Secrets Manager was still in beta and would've added extra complexity. The Cloud Run container images are stored in Container Registry instead of the Artifact Registry called out in the requirements. Like Secrets Manager it seems Artifact Registry is still in beta so I chose the former option.

I did manage to get the GitOps-style CI/CD deployment working at the very last minute (only hours before I am writing this). This by far was the most confusing piece for me. I implemented Cloud Source Repository mirroring for the GitHub app and web repositories. All of the infrastructure, including the service account and the enabling of the GCP services, was managed by Terraform and Terraform Cloud. 

____

## Conclusion

Yes this challenge is over, but I am not done yet... Unfortunately I didn't make as much progress as I was originally expecting due to personal time constraints. I will continue to improve both of these projects over the next couple weeks. 

Look forward for further communication on those updates when I am able to provide them. Happy Clouding! Curious about something or just want to chat? Let's connect on LinkedIn. 

* [LinkedIn](https://www.linkedin.com/in/wheelers-websites/)
* [GitHub](https://github.com/wheelers-websites)
* [Website](https://www.wheelersadvice.com)
 