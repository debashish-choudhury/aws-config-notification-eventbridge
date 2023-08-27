# AWS Config Notification With Eventbridge


## Description

**AWS Config Notification** is an open source IaC written in **Terraform**. It helps in provisioning infrastucture in **AWS**, allows faculty to get notification if there is any change in AWS Account specified. User will get detailed email notification, information on **who** made **what** kind of changes in AWS Account. **AWS Config** is a service provided by AWS which helps keep track of resource change and perform action based on the same. In this case we send a email notification to the user when there is any kind of change in resource specified by user explicitly.

- To know more in **AWS Config** Service: (https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html)

**By default** AWS Config tracks all the resources when created in terraform. We need to explicitly specify which resources we want to monitor. It is shown in `main.tf` file how we can configure the same.

The config will still send all types of messages `messageType` for resources mentioned in config recorder.

AWS Config message has multiple message types:
```
ConfigurationItemChangeNotification
ConfigurationHistoryDeliveryCompleted
ConfigurationSnapshotDeliveryStarted
ConfigurationSnapshotDeliveryCompleted
ComplianceChangeNotification
OversizedConfigurationItemChangeNotification
OversizedConfigurationItemChangeDeliveryFailed
```

We will use **Eventbridge** to filter AWS Config notification based on `ConfigurationItemChangeNotification`, if we configure SNS directly to config, it will send all the `messageType` email notification. This cloud overflood the inbox.

Look at `aws_cloudwatch_event_rule.config_messages` where we have filtered message that we want to send to SNS.

We can further filter out config messages based on `configurationItemStatus` There are in total 5 configuration item status in config messages:
```
OK | ResourceDiscovered | ResourceNotRecorded | ResourceDeleted | ResourceDeletedNotRecorded
```

Refer `aws_cloudwatch_event_rule.config_messages` resource in `event.tf` where we have `configurationItemStatus` property

To have a custom message in email we can add `input_transformer` in `aws_cloudwatch_event_target.sns` present in `event.tf`


## Installation

#### Manual Installation

1. Download AWS CLI (latest Version)
2. Configure AWS in your machine by using command: `aws configure`
3. Download and install terraform ~1.4.6 or higher.
4. Clone the repository and check out the master branch: `git clone https://github.com/debashish-choudhury/aws-config-notification-eventbridge.git`
5. Change directory the cloned repository: `cd aws-config-notification`
6. Set credentials using the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN` environment variables. \
   ```
   % export AWS_ACCESS_KEY_ID="anaccesskey"
   % export AWS_SECRET_ACCESS_KEY="asecretkey"
   % export AWS_REGION="us-west-2"
   ```
7. Initialize the Terraform: `terraform init` \
   **Optional:**
   Want to use terraform backed? Uncomment the **terraform** block present in `providers.tf` and add bucket name, key and region as shown below: 
   ```
   terraform {
     backend "s3" {
       bucket = "mybucket"
       key    = "path/to/my/key"
       region = "us-east-1"
     }
   }
   ```
8. Run terraform plan: \
   ```bash
   terraform plan -out output.tfplan
   ```

   To get `JSON` output of terraform plan, run the following command:
   ```bash
   terraform show -no-color -json output.tfplan > output.json
   ```

**Important:** If working in team, you must enable state lock. It helps to lock the terraform state file when a member is updating the infra. Create a **Dynamodb Table** with the partition key ID as `LockID`.
Add the table name inside the backend block as show below:
```
terraform {
    backend "s3" {
    bucket         = "mybucket"
    key            = "path/to/my/key"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dynamo"
    }
}
```

**Important:** The Partition Key should be `LockID` or else the state lock will **not work** as expected.

**Important:** If you want to change the resource monitoring based on your requirements, please look at the below link which shows how we can modify the resource block `aws_config_configuration_recorder` config present in `main.tf` :
(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder.html#recording_group)

**Important:** AWS Config needs **Service Linked Role** or else it won't be able to track resources changes. Hence, make sure to create and attach the linked service role to AWS Config resource. Look at `aws_iam_service_linked_role.tf` file, resource name `aws_iam_service_linked_role` how we create linked service role.
(https://registry.terraform.io/providers/hashicorp/aws/3.6.0/docs/resources/iam_service_linked_role)


## Configuration

### General

If you want to update your code to the latest version, use your terminal to go to your aws-config-notification `cd aws-config-notification-eventbridge` and type the following command:

```bash
git pull
terraform init
terraform plan -out output.tfplan
terraform apply output.tfplan
```

If you changed nothing more than the config or the modules, this should work without any problems.
Type `git status` to see your changes, if there are any, you can reset them with `git reset --hard` After that, git pull should be possible.


## Contributing Guidelines

Contributions of all kinds are welcome, not only in the form of code but also with regards bug reports and documentation.

Please keep the following in mind:

- **Bug Reports**: Make sure you're running the latest version. If the issue(s) still persist: please open a clearly documented issue with a clear title.
- **Minor Bug Fixes**: Please send a pull request with a clear explanation of the issue or a link to the issue it solves.
- **Major Bug Fixes**: please discuss your approach in an GitHub issue before you start to alter a big part of the code.
- **New Features**: please please discuss in a GitHub issue before you start to alter a big part of the code. Without discussion upfront, the pull request will not be accepted / merged.

Thanks for your help in making AWS Config notification!!!


## Important
This application in compatible to run in `Windows`, `Linux`, `OSX` .
To install all the dependencies required for this application run the following command: `terraform init` 

> ~ Debashish Choudhury


