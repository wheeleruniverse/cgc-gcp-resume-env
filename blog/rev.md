## High Level

Another daring, exciting, and shocking [#CloudGuruChallenge](https://acloudguru.com/blog/engineering/cloudguruchallenge-your-resume-on-gcp). This challenge is brought to us by my favorite GCP instructor at [acloudguru](acloudguru.com) Mattias Andersson. Similar to the [Apr, 21 #CloudGuruChallenge](https://dev.to/wheelerswebsites/apr-21-cloudguruchallenge-3fch) and the original [Cloud Resume Challenge](https://forrestbrazeal.com/2020/04/23/the-cloud-resume-challenge/) we were challenged to create our digital resume. The catch this time was that it had to be hosted on GCP! Well that along with a handful of other creative twists.

Specifically:
* the video call presentation :astonished:
* the GitOps-style approach to CI/CD :dizzy_face:

At the start of this challenge I found myself contemplating how I can leverage the work I did back in Apr, 21. I developed two projects this month. The first, is what will someday become my solution to the ["Meta Resume Challenge"](https://dev.to/wheelerswebsites/meta-resume-challenge-5a1a). The second, is the aspects that are specific to this challenge. The former is a work in progress. I will spend this blog post focusing on the latter, which is completed. Even though, I did purchase a domain name for this website it's merely a façade, a portal to my actual resume. Keep in mind that the façade website is temporary. I will be tearing down that environment when it no longer suits me. My real resume is here to stay for the foreseeable future.

![Website Façade](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wbb7bgkd9coxzv1t9qo9.PNG)

![App Swagger](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/lty82z4yedyx0cbuaxrj.PNG)

Façade Web: https://wheelersadvice.com/
Façade App: https://api.wheelersadvice.com/

Resume Web: https://gcp.wheelercloudguru.com/
Resume App: https://api.gcp.wheelercloudguru.com/swagger-ui.html

____

## Run-Time Architecture

![Website Architecture](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t18ytw96pdcunknlo3bb.png)

### DNS

* Cloud Domains: used to register the domain name
* Cloud DNS: used to route traffic from the user to a destination
    * wheelersadvice.com is routed to the Cloud CDN and Cloud Load Balancer
    * api.wheelersadvice.com is routed to Cloud Run

### Frontend

* Cloud CDN: used to cache content and deliver content closer to the end users
* Cloud Load Balancer: used to route traffic from the user to a destination; in this case a Cloud Storage bucket
* Cloud Storage: used to house website content

### Backend

* Cloud Run: used to run a container image in a [serverless](https://cloud.google.com/serverless) way
* Container Registry: used to store container images

### Database

* Firestore: used to store the visitor counter

____

## Infrastructure as Code (IaC)

* [Terraform](https://www.terraform.io/) was used to create the GCP infrastructure.
* [Terraform Cloud](https://www.terraform.io/cloud) was used to store the Terraform state.

I divided the infrastructure into two separate implementations that managed the following resources. Each was managed independently in a Terraform Cloud workspace. I felt that this isolation was crucial since I have had a lot of heartache in past specifically due to [google_project_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service). When doing a `terraform destroy` when this type of resource in your template you can disable a GCP service. The effect of that action is that all of the resources using that service are deleted. By managing these entities separately I was able to have much more control over which resources are changed, and when.

![Terraform Cloud Workspaces](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/a9x9f52vgx2fdixwnq8k.PNG)

### Services

* ensure the required gcp services are enabled
* service account and json key
* iam role mappings for the service accounts used

I used the [count](https://www.terraform.io/docs/language/meta-arguments/count.html) meta-argument to iterate through a list of pre-defined values to create similar resources in a loop multiple times. This was a much cleaner solution in my opinion that replicating the resource blocks, but you need to take special care to not re-arrange the elements in the list. When the elements in the list change so does their index causing Terraform to attempt to re-create the resources again.

```
locals {
  core_roles = [
    "compute.loadBalancerAdmin",
    "containerregistry.ServiceAgent",
    "iam.serviceAccountUser",
    "run.admin",
    "storage.admin",
    "storage.objectAdmin"
  ]
}

resource "google_project_iam_member" "core" {
  count  = length(local.core_roles)
  member = "serviceAccount:${google_service_account.this.email}"
  role   = "roles/${local.core_roles[count.index]}"
}
```

> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-env/tree/main/services

### Core

* backend
* ci/cd
* database
* dns
* frontend

> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-env/tree/main/core

____

## Dev-Time Architecture

![CI/CD Architecture](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/j5duguvfc8o9g3hlzitb.png)

Since it was called out as a requirement I implemented a [GitOps-style](https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build) approach to CI/CD. This was probably the most complicated part of the project. That could just be because I have never done this sort of deployment before. It took extra time to get the concept wrapped clearly around my head. I will do my best to explain that to you...

First, I created two repositories. One repository for the application code and one repository specifically for the CI/CD aspect. The application code is managed by GitHub, but mirrored into Cloud Source Repositories. The CI/CD code only exists within Cloud Source Repositories and is not to be manipulated manually.

> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-app
> https://github.com/wheelers-websites/CloudGuruChallenge_21.08-web

![Cloud Source Repositories](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/tc20u3kjcgiau82z6rja.PNG)

1. developer pushes to GitHub (main)
2. GCP mirrors the GitHub code to CSR
3. Cloud Build triggers a deployment using the [cloudbuild.yml](https://github.com/wheelers-websites/CloudGuruChallenge_21.08-app/blob/main/cloudbuild.yml)
    1. docker build using the [Dockerfile](https://github.com/wheelers-websites/CloudGuruChallenge_21.08-app/blob/main/Dockerfile)
    2. docker push to container registry
    3. git checkout CI/CD repository
    4. git push to CI/CD repository (candidate)
4. Cloud Build triggers a deployment using a different `cloudbuild.yml`
    1. cloud run deployment
    2. git checkout CI/CD repository
    3. git push to CI/CD repository (production)

```
gcr.io/cloudguruchallenge-2108/wheelersadvice:f4ebca392260911e7ed225f252c1d642e1ad23b3
```
> wheelersadvice/cicd/app/image.txt

```
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    args: 
      - '-c'
      - |
        gcloud run deploy wheelersadvice --image $(cat image.txt) --region us-central1
    entrypoint: /bin/sh
    timeout: 300s
  
  - name: 'gcr.io/cloud-builders/git'
    args:
      - '-c'
      - |
        git config --global user.email "98767786228@cloudbuild.gserviceaccount.com"
        git config --global user.name "Cloud Build Service Account"
        git fetch origin production
        git checkout production
        git checkout $COMMIT_SHA image.txt
        git commit -m "app deployment for $COMMIT_SHA"
        git push -u origin production
    entrypoint: /bin/sh
    timeout: 300s
```
> wheelersadvice/cicd/app/cloudbuild.yml

The benefits of this approach is that the `candidate` branch will track all deployment attempts, whereas the `production` branch will only track successful deployments. It's true that I have not completed this style deployment for the `web` architecture yet, I do plan on mimicking this soon in the `web` tier for consistency sake.

____

## Key Tradeoffs

Along this crazy journey there were countless tradeoffs as there typically is. I'll share some of the most memorable tradeoffs I made along with my reasoning on why.

### Terraform vs. Pulumi

I have been curious about [Pulumi](https://www.pulumi.com/) recently. I had even debated using it on this project. I settled on Terraform for these multiple reasons:
* Mattias specifically mentioned Terraform in the requirements
* I have experience with Terraform
* I have existing Terraform templates

### Vue vs. Angular

I have never used [Vue](https://vuejs.org/) before and thought this would be the excellent project to give it a go. I knew I was only crafting a web façade so I knew the frontend coding would be minimal. I decided to spend the extra cycles to learn a bit of Vue instead of using a framework that I am already much more comfortable with like Angular.

### Cloud Build vs. GitHub Actions

There was a call out in the requirements that GitHub Actions would have been acceptable for the frontend deployments. It was also tempting since I have prior experience with GitHub Actions already, including existing templates that I could've repurposed. Ultimately, I decided against mixing the technologies. I knew that Cloud Build was the intention for the backend builds and chose uniformity over ease of use here.

____

## Next Steps

### Web CI/CD

As I stated before, if I had more time to spend I would update the web CI/CD to follow the app example of the GitOps-style approach. I don't like that the web CI/CD is not aligned to the app methodologies. Uniformity in projects is imperative to me. I strongly believe that I will return to this project later to correct this disjunction.

### Fancier Vue Code

Understandably since I only just started my Vue journey, you may realize that I was unable to make the UI as fancy as I could've. I would wager that I will benefit from more time on the Vue code to create a more appealing frontend along with some much needed Vue skills.

### Expanded Terraform

Lastly, there are more resources I could put into Terraform that would improve the GCP environment.

1. replace the gcp json credentials environment variable with a secret
2. create a gcp budget in terraform to track cloud spend

____

## Lessons Learned

It's kind of scary to think about all of the things I learned on this project. It's inevitable that I will forget one or two learnings in this post, but I will carry them with me forever. For that I will be forever grateful!

### Cost Control

From an AWS background I was expecting a similar architecture would run up a similar bill. Unfortunately, I was terribly mistaken. I am not sure what vendetta GCP has against independent developers. The minimum costs to run a serverless website that receives no traffic on GCP is around ~$18/month. Compared to a serverless website on AWS that receives no traffic costing ~$0/USD. The main difference here is that the HTTPS Load Balancer in GCP is charged hourly and cannot scale to zero, yet is required to enable HTTPS. Furthermore, where AWS CloudFront supports HTTP-to-HTTPS redirection for free, GCP asks that you construct a second load balancer that listens to HTTP traffic and forwards it to HTTPS. Thus, doubling the minimum operating cost to ~$36/month. Of course with pricing this is all subject to change and I for one truly hopes that it does.

> https://cloud.google.com/vpc/network-pricing#lb
> https://cloud.google.com/load-balancing/docs/https/setting-up-http-https-redirect

![GCP HTTP-to-HTTPS Diagram](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4pp7qk494bdulx512fp2.PNG)

### CI/CD with Cloud Build

Switching from GitHub Actions to Cloud Build wasn't the easy transition I was expecting. The syntax and semantics used in Cloud Build are much different. One specific gotcha I found was that in Cloud Build the trigger can't be set on a subdirectory. When I originally started with a mono-repository I would have multiple triggers firing for each commit. Committing to web would deploy the app code and vice versa. There were some complicated solutions on [Stack Overflow](https://stackoverflow.com/), although the simplest was to split my repositories... so that's what I did.

```
on:
  push:
    branches: [main]
    paths:
    - app/gcp/**
```
> https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions#onpushpull_requestpaths

### If I Started Today

If I were to redo this project with the knowledge I have now it's obvious that it would go much faster. I would like to think that I wouldn't make as many mistakes... the truth is that I would probably change up some aspects to keep the project interesting to me such as using Pulumi as IaC instead of Terraform. In doing so I would be exposing myself to more failures and more learnings. Not that it's a bad thing I just know that I would push myself to mix it up.

### My Biggest Regrets

* the system I created is not as polished as I would've preferred
* I didn't complete the project as quickly as I would've liked to

____

## Conclusion

This challenge was incredibly difficult. I'm undecided if it's the most difficult #CloudGuruChallenge to date or not. With that said I learned so much during this challenge. It's been entertaining to see all of the participants in the [acloudguru Discord Server](https://discord.gg/NwfDnNj54T) post their completed projects. I truly hope that more people rise to the occasion. If anyone wants to talk about this project, or cloud in general with me, then please reach out to me on LinkedIn. I am always down to discuss cloud and love pushing other people to achieve their full potential.

* https://github.com/wheelers-websites
* https://www.linkedin.com/in/wheelers-websites/

Thanks for reading! Happy clouding.

