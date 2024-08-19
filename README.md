# Use Amazon S3 Bucket as an Amazon EKS Cluster Filesystem
This repository contains code to deploy a solution that uses an Amazon S3 bucket as a filesystem from within an Amazon EKS cluster.

## Prerequisites
The following are required to implement this solutions.

- AWS Account

- Terraform

- Kubectl CLI

## Implementation
1. Clone this repository using  

    ``  
      git clone https://github.com/nivleshc/blog-amazon-s3-filesystem-for-amazon-eks-cluster.git  
    ``

2. Update the values in the **locals.tf** file.

3. Run the following command to initialise Terraform  

   ``  
      terraform init
   ``
4. Run the following command to see the changes that will be applied to your AWS Account. When requested, provide the name of the environment that you are deploying into, for example, dev, test, uat , preprod or prod
    
    ``
      terraform plan
    ``
5. To deploy the changes into your AWS Account, run the following command. At the prompt, type yes and press enter.  

    ``
      terraform apply
    ``

Full documentation is available at:  
https://nivleshc.wordpress.com/2024/08/18/use-amazon-s3-bucket-as-an-amazon-eks-cluster-filesystem-part-1-terraform-root-module/

https://nivleshc.wordpress.com/2024/08/18/use-amazon-s3-bucket-as-an-amazon-eks-cluster-filesystem-part-2-terraform-child-module-vpc/

https://nivleshc.wordpress.com/2024/08/18/use-amazon-s3-bucket-as-an-amazon-eks-cluster-filesystem-part-3-terraform-child-module-eks/


