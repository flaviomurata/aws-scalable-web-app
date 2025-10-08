# AWS Academy Lab Project - Cloud Web Application Builder
This repository contains a Proof of Concept for the "Cloud Web Application Builder" lab project from AWS Academy. The project's goal is to design and deploy a scalable, secure, and highly available cloud-based web application for managing student records.

## Solution requirements
The solution must meet the following requirements:

- **Functional:** The solution meets the functional requirements, such as the ability to view, add, delete, or modify the student records, without any perceivable delay.

- **Load balanced:** The solution can properly balance user traffic to avoid overloaded or underutilized resources.

- **Scalable:** The solution is designed to scale to meet the demands that are placed on the application.

- **Highly available:** The solution is designed to have limited downtime when a web server becomes unavailable.

- **Secure:**
  - The database is secured and can’t be accessed directly from public networks.
  - The web servers and database can be accessed only over the appropriate ports.
  - The web application is accessible over the internet.
  - The database credentials aren’t hardcoded into the web application.

- **Cost optimized:** The solution is designed to keep costs low.

- **High performing:** The routine operations (viewing, adding, deleting, or modifying records) are performed without a perceivable delay under normal, variable, and peak loads.

---
## Phase 1: Planning the design and estimating cost
This initial phase involved creating an architectural diagram to visualize the target solution and estimating the 12-month operational cost in the `us-east-1` Region using the AWS Pricing Calculator.

![projetoaws-task1](https://github.com/user-attachments/assets/4958b943-7bef-431c-8a66-e11cd9fb6eb1)
<img width="698" height="76" alt="image" src="https://github.com/user-attachments/assets/305c70d2-bc8b-452c-bbc2-202268f25563" />

## Phase 2: Creating a basic functional web application
The objective of this phase was to deploy a functional web application on a single virtual machine to serve as a baseline Proof of Concept (POC).

### Task 1: Creating the Virtual Network
A new **Virtual Private Cloud (VPC)** was created to provide a logically isolated network environment. To prepare for future requirements and minimize reconfiguration, the VPC was configured with:
* Two **public subnets** across two different Availability Zones (AZs).
* Two **private subnets** across the same two AZs.
* An **Internet Gateway** attached to the VPC to allow communication between instances in the public subnets and the internet.
* A **NAT Gateway** placed in a public subnet to allow instances in the private subnets to initiate outbound traffic to the internet (e.g., for software updates) while remaining inaccessible from the public internet.

<img width="1658" height="810" alt="VPC configuration with public and private subnets" src="https://github.com/user-attachments/assets/2198f2b8-a42e-4aec-93e5-e61dd7a0c5f0" />

### Task 2 & 3: Deploying and Testing the Monolithic Application
A single **Amazon EC2** instance was launched into one of the public subnets. The instance was configured using a user data script (`UserdataScript-phase-2.sh`) that automatically installed:
1.  The Node.js web application.
2.  A local MySQL database directly on the same instance.

This created a monolithic deployment where both the application and database tiers reside on the same server. The application was then tested by accessing its public IPv4 address to ensure all functionalities—viewing, adding, deleting, and modifying student records—were working correctly.


https://github.com/user-attachments/assets/4efa0895-811a-4b29-a529-1cf38de032bc


---

## Phase 3: Decoupling the application components
The goal of this phase was to separate the web and database layers to improve security, manageability, and scalability. This involved migrating the database to a managed service and ensuring the web server could securely connect to it.

### Task 1 & 2: Provisioning a Managed Database
An **Amazon Relational Database Service (Amazon RDS)** instance running the MySQL engine was provisioned. To meet security requirements, the RDS instance was deployed across the private subnets in two Availability Zones. A database-specific security group was configured to only allow inbound traffic on the MySQL port (3306) from the web server's security group, effectively isolating it from the public internet.

<img width="1639" height="769" alt="RDS instance deployed in private subnets" src="https://github.com/user-attachments/assets/197b8bab-3553-4fea-898e-0275f8a6d6c2" />

### Task 3 & 4: Securing Database Credentials
To avoid hardcoding database credentials in the application, **AWS Secrets Manager** was used. First, an **AWS Cloud9** environment was provisioned to serve as a development environment for running AWS CLI commands. Using the Cloud9 terminal, a new secret was created in Secrets Manager to securely store the RDS database endpoint, username, and password.

```
aws secretsmanager create-secret \
    --name Mydbsecret \
    --description "Database secret for web app" \
    --secret-string "{\"user\":\"<username>\",\"password\":\"<password>\",\"host\":\"<RDS Endpoint>\",\"db\":\"<dbname>\"}"
```

<img width="1629" height="792" alt="image" src="https://github.com/user-attachments/assets/3018efe0-649c-4240-a9cf-2c0454003d7e" />

### Task 5-7: Deploying the Web Server and Migrating Data
A new EC2 instance was launched to host the web application. This instance was configured with:
* The `UserdataScript-phase-3.sh` script, which installs the application and its dependencies. This version of the script is designed to fetch database credentials from AWS Secrets Manager instead of connecting to a local database.
* An **IAM Role** (`LabInstanceProfile`) attached to the instance, granting it the necessary permissions to read the secret from Secrets Manager.

Finally, the data from the original database (on the Phase 2 EC2 instance) was migrated to the new Amazon RDS database using a script run from the Cloud9 environment. The application was then tested to confirm that it could successfully connect to the RDS database and perform all required operations.

```
mysqldump -h <EC2instancePrivateip> -u nodeapp -p --databases STUDENTS > data.sql

mysql -h <RDSEndpoint> -u nodeapp -p  STUDENTS < data.sql
```

---

## Phase 4: Implementing High Availability and Scalability
The final phase focused on transforming the architecture into a highly available and automatically scalable solution capable of handling variable traffic loads, as required for the peak admissions period.

### Task 1: Implementing Load Balancing
An **Application Load Balancer (ALB)** was created to distribute incoming web traffic across multiple EC2 instances. The ALB was configured to listen for HTTP traffic on port 80 and was deployed across the two public subnets to ensure it remains available even if one Availability Zone fails. The ALB serves as the single public-facing endpoint for the application.

<img width="1656" height="683" alt="image" src="https://github.com/user-attachments/assets/c7280cec-4b11-4bd1-8f8c-189508b9561f" />

### Task 2: Implementing Auto Scaling
An **Amazon EC2 Auto Scaling group** was implemented to automatically adjust the number of web server instances based on demand. The configuration involved:
1.  Creating an **Launch Template** from the fully configured web server instance from Phase 3. <img width="1418" height="600" alt="image" src="https://github.com/user-attachments/assets/d83f0d2e-977b-4851-bfd3-33240ee12064" />
2.  Configuring the **Auto Scaling Group** to use the launch template, maintain a desired number of instances across both Availability Zones, and connect to the ALB's target group. <img width="1590" height="706" alt="image" src="https://github.com/user-attachments/assets/128c075f-fb39-43e0-af6c-f99a73268529" />
3.  Setting up a **Target Tracking Scaling Policy**, which automatically adds or removes instances to keep the average CPU utilization across the fleet at a specified level (e.g., 50%). <img width="783" height="548" alt="image" src="https://github.com/user-attachments/assets/cbd9ab81-f2e1-4034-b1d1-977f9bf4fbcb" />

### Task 3 & 4: Final Testing and Validation
The application was accessed using the ALB's public DNS name to ensure the entire system was functional. To validate the auto-scaling capability, a load test was performed from the Cloud9 environment using the provided `loadtest` script.

During the test, we monitored the Auto Scaling group's activity and confirmed that it automatically launched new EC2 instances as CPU utilization increased. After the test concluded and CPU usage dropped, the group automatically terminated the extra instances, demonstrating the solution's elasticity and cost-efficiency. This final architecture successfully meets all the project's requirements for a highly available, scalable, and secure web application.

<img width="1648" height="796" alt="image" src="https://github.com/user-attachments/assets/451e99d5-cb71-4ea7-8787-4540b3462300" />

```
loadtest -t 600 --rps 1000 -c 500 -k <<ELB URL>>
```
<img width="1648" height="796" alt="image" src="https://github.com/user-attachments/assets/e81cd0cb-6f39-439a-ba54-a29cc7ae9287" />
<img width="1648" height="796" alt="image" src="https://github.com/user-attachments/assets/0367a49a-cfc5-49d7-8ae3-d95539e97d6f" />


