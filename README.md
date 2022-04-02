# BPM Processmaker on AWS
Deployment and configuration of BPM ProcessMaker 4 on AWS.

![](imgs/remote-devops-desktop-x2go-client-1-arch-packer.png)

## Resources

1. [ProcessMaker BPM Core](https://github.com/ProcessMaker/processmaker): ProcessMaker is an open source, workflow management software suite, which includes tools to automate your workflow, design forms, create documents, assign roles and users, create routing rules, and map an individual process quickly and easily. 
2. [AWS EC2](https://aws.amazon.com): Where ProcessMaker BPM Core will run. An AWS Account will be needed. 
3. [Terraform](https://www.terraform.io/): Terraform is an open-source infrastructure as code software tool that will help us to build and provision ProcessMaker on AWS.


## Steps

1. Install AWS CLI, Terraform CLI, configure your AWS credentials and generate SSH keys. Once completed, run the next commands:

```sh
$ aws configure --profile DS

AWS Access Key ID [None]: AKIA...
AWS Secret Access Key [None]: 0ugi...
Default region name [None]: eu-west-2
Default output format [None]: 

$ export AWS_PROFILE=DS

$ source <(curl -s https://raw.githubusercontent.com/chilcano/how-tos/master/src/import_ssh_pub_key_to_aws_regions.sh)
...
=> SSH Pub Key was imported successfully to all AWS Regions in all AWS Profiles configured.
=> Now, you can use this command to get remote access:
   ssh ubuntu@<IP_ADDRESS> -i ~/.ssh/tmpkey
   ssh ubuntu@<FQDN> -i ~/.ssh/tmpkey
   ssh ubuntu@$(terraform output -json node_ips | jq -r '.[0]') -i ~/.ssh/tmpkey
   ssh ubuntu@$(terraform output node_fqdn) -i ~/.ssh/tmpkey

$ chmod -R 400  ~/.ssh/tmpkey*

$ cd 02-processmaker/

$ terraform init

$ terraform validate

$ terraform plan

$ terraform apply
...
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

instances_workstation = [
  [
    "18.169.162.190",
  ],
]
```

2. Get remote access to the AWS Intance created.

```sh
$ HOST_BPM_IP=$(terraform output -json instances_workstation | jq -r '.[][0]')

$ ssh bitnami@${HOST_BPM_IP} -i ~/.ssh/tmpkey

```

3. Get the backend credentials

???

4. From AWS Console get the Application credentials 

https://docs.bitnami.com/aws/faq/get-started/find-credentials/


## Modeling Business Process

1. [Spanish - Modelando el Proceso de Compras con ProcessMaker, 2019/Oct](https://www.youtube.com/watch?v=JHtiRYgj2bY)
2. [Spanish - Modelando el Proceso de Solicitud de Ausencia, 2020/Oct](https://youtu.be/YLThe2JO5Do?list=PLcekSAwccnFbwfgJ0suNijp-wWQ422hVx&t=777)

## Other BPM tools to review

1. [BPMN-Moddle](https://github.com/bpmn-io/bpmn-moddle): Read and write BPMN 2.0 diagram files in NodeJS and the browser. BPMN-Moddle uses the BPMN 2.0 meta-model to validate the input and produce correct BPMN 2.0 XML.
2. [ProcessMaker Nayra](https://github.com/ProcessMaker/nayra): Nayra is a BPMN workflow engine in PHP. Utilize it in your own projects to have your own complex workflow capabilities. 
3. [ProcessMaker Modeler](https://github.com/ProcessMaker/modeler): Processmaker Modeler is a Vue.js based BPMN modeler scaffolded using [Vue CLI 3](https://cli.vuejs.org/).

