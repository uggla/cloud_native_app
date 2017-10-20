Cloud Native Application
========================

This document purpose is to describe the Cloud Native Application training described below and which is in particular delivered to ENSIMAG IS students in 2017 and 2018.

Document writers:

 * Bruno.Cornec@hpe.com
 * Christophe.Larsonneur@dxc.com
 * Vincent.Misson@hpe.com
 * Rene.Ribaud@dxc.com

# Overview of the Assessment

## Objectives

The goal of this document is to describe the use case that will be used for the training of ENSIMAG students

## Reference documents

The main OpenStack entry point is at http://www.openstack.org

 * v1.0:	2016-09-29 - First version
 * v1.1:	2016-11-28 - Update with grade per part
 * v1.2:	2017-01-16 - Update with evaluation method
 * v2.0:	2017-09-25 - More focus on the DevOps life-cycle
 * v2.1:	2017-10-20 - Review to match 2017 expectations

# Customer Story

## Objectives

The goal of this training is to build the software factory that will do Continuous Integration and Continuous Deployment of a cloud native application.
The application is a lottery for an e-commerce site. This is an open source application.

## Goals & constraints

### Goals
As a company, the idea is to leverage an open source cloud native application to use it internally. Because the application is a cloud native one and will have to be frequently improved, the choice is to use the devops methodology to maintain this application into production.

As a consequence, practitioners will first have to:
 * Organize the team to work using devops best practices.
 * Automate the management of a virtual infrastructure (Infrastructure as code concept). Within this part we are using Openstack as our Infrastructure as a Service platform (IaaS) but this is an implementation choice. The same principles can be implemented on top of another IaaS platform like Eucalyptus, Cloudstack, Amazon AWS, Azure, Docker. 
 * Build production environment, the teachers team will provide two physical infrastructures for that purpose, one which will be pre-installed with an OpenStack distribution in which a tenant per group of student will be available for application development, and another one (set of 15 servers) which will be pre-installed with just a CentOS 7 Operating System. Students will configure the IaaS part on top of it to study the various components that they want to test.
 * Define and implement a CICD pipeline to easily test and deploy the application to staging area then production.
 * Put in place tooling to share/track application changes beetween team members/customers.
 * Ensure correct level of security within the factory. (no private keys or data available publicly, user access restriction, ports filtering...)

### Constraints
 * Application should only expose http[s] (ports 80 and 443) to the external network.
 * All materials should be kept on public git repository (github e.g.) with an Open Source license (Cf: https://opensource.org/licenses prefer the popular ones). Please note that your github history should reflect changes to the factory/infrastructure/application. Also, you should commit properly with a your personal credentials (email preferred) with a unique account.
 * There is no restriction regarding the tools to implement the pipeline. It could be external services and/or on premise tools. However, be prepared to justify some choices.

## Bonus goals
 * Put in place monitoring to ensure application in working as expected.
 * Put in place name resolution.
 * Improve applications.
 * Optimize testing duration.
 * Communication dashboard  about application health to users.
 * Performance of the application improvement by scaling services.
 * Application reliability.

# Application information

## Application schema
![applicaiton schema](schema/archi_docker.png)


## Application description

 * 1 Web + reverse proxy provides a page with 5 visible parts/micro-services: I, S, B, W and P.
 * I(dentification) service: receives http request from customer (link with customer ID) and look for it into DB.
 * S(tatus) service: detect whether customer already played or not, status stored in the DB.
 * B(utton) service: button widget allowing the customer to play. Only when not already done.
 * W(orker) service that computes whether the customer won or not, called by B. If won, post an image representing what has been won into OpenStack Swift or Redis with customer ID. Then post by e-mail via an external provider a message to admins using a message bus. This service is povided by a 3rd party, so it can not be changed. As this service is really slow, scaling it should be considered.
 * P(icture) service: Look into Swift or Redis with customer ID to display the image of the customer, empty if no image.
 * Redis or Swift can be used to store data.
 * Rabbitmq is used to pass message from service B to service W1 and W2.
 * W1 services that listen on the messaging bus and write to the database.
 * W2 services that listen on the messaging bus and send http requests to mailgun external services.

## Application materials (code, doc etc...)
https://github.com/uggla/cloud_native_app


## Deliverables

 * On Gihub:
   * Pipeline design documents.
   * Application code.
   * Heat template/ansible playbooks/scripts for Infra group.

 * Video that will present the CICD of the application in a new empty tenant.

## Teachers support

Teachers will provide a remote access to the production platform (set of servers preinstalled with a CentOS 7 distribution) that the team will have to setup from an OpenStack perspective and deliver teams could deploy their application on it. Teachers will also provide a pre-production platform running an OpenStack distribution as a development environment for the application developers for testing purposes.

A mailing list has been created to provide remote support to students during the whole period. Various people will so be available to answer questions and help with regards to platform setup and access. The mailing-list address is ensimag-openstack@lists.osp.hpe.com 

# Agenda

Each session is 3 hours long

## First session

 * Project explanation: Overall Goals & method (groups, prod platform, TD systems for tests). No formal solution will be directly given, students will have to build the solution by themselves. Many approaches are possible.  The teachers team role will be after the 2 first sessions and generic presentations on all concepts to help them in the realization of that application and its setup.
 * Cloud fundamentals: IaaS  (Bruno)
 * OpenStack architecture & example (Bruno)
 * Production platform exaplanation (Bruno)
 * OpenVPN setup
 * Waystation creation (see below)  --> pb need group defined.
 * Home work:
   * Continue to explore OpenStack from both UI & CLI
   * Create 9 groups of 5 students (one country per group), assign specialization (ops, devs, middleware, ... + backup), tool choice left to students, but licensing should be correct (prefer Open Source)

## Second session

 * Cloud fundamentals: DevOps (Christophe)
 * Application overview (René)
 * Infrastructure as Code: OpenStack API as TD
 * Project explanation: Architecture of the use case - Specifications - Design Constraints & Goals (GitHub, automation, )
 * Home work: Continue to explore OpenStack API (Dev), Start Prod Infra setup

## Third session

* Prod infra setup continued: Ability to launch a VM from an image using a heat template, attached to a network and a storage, and an object storage. private and public net are available and a floating IP attached to the VM.
* Application architecture done: microservices identified, HA solved, Scalability solved. Design done (Paper work, UML ?).

## Fourth session

 * Prod infra setup finished: Ability to launch a VM from an image using a heat template, attached to a network and a storage, and an object storage. private and public net are available and a floating IP attached to the VM.
 * Application development ongoing

## Fifth session

 * Prod infra setup review if needed
 * Application development ongoing

## Sixth session

 * Prod infra setup review if needed
 * Application development done

## Seventh session

 * Synthesis and integration
 * Group Presentation

## Eigth session

 * Evaluation of the projects

# Evaluation and evaluation method

Evaluation will be 15' per group and an additional 15' for the infra team.

Each group should send an estimate of the time taken to deploy the full stack and on which platform they're confident it will work.

First you'll have to redeploy the full stack at start of the evaluation on the infra built by the infra team.

Before the evaluation, the systems used to perform the demonstration (OpenStack based infrastructure) should be ready to avoid loosing time in setup phase and concentrate on demo and explanations. Bastion should preexist, as well as the stack.

Then, the functional evaluation will be done on that infrastructure with explanation of choices, methods and tools used. 

 * Plan to have a backup video.
 * A presentation to explain the major steps and choices might be useful, but not mandatory

Send all deliverables planned in advance of the evaluation to allow time for teachers to look at them.

Questions will be asked to:

 * have an overall view on group work and student work in the group
 * each student has to explain his role in the development of the full stack


| Points | Topic to evaluate |
| ------ | ----------------- |
| **4**  | **For Dev team**<br><ul><li>On Gihub:</li><ul><li>Heat template/ansible playbooks/scripts for dev group</li><li>Performance and tests results</li><li>Application code</li></ul><li>Application design document</li><li>Present the automatic deployment of the application in a new empty tenant and make reliability checks.</li></ul>|
| **4**  | **For Infra team** - Additional IaaS platform:<br><ul><li>available</li><li>operational</li><li>with the mandatory components</li><li>and optional ones needed by the development teams</li><li>On Gihub:</li><li>Heat template/ansible playbooks/scripts for Infra group</li>|
| **6**  | <ul><li>1 Web page with 5 parts/micro-services: I, S, B, W and P. Work independently of each other</li><li>I(dentification) service: receives http request from customer (link with customer ID) and look for it into DB</li><li>S(tatus) service: detect whether customer already played or not, status stored in the DB.</li><li>B(utton) service: button widget allowing the customer to play. Only when not already done.</li><li>W(orker) service that computes whether the customer won or not (provided), called by B. If won, post an image representing what has been won into OpenStack Swift with customer ID. Then post by e-mail via an external provider a message to admins (using a message bus if possible). Button is gray if the customer has already played.</li><li>P(icture) service: Look into Swift with customer ID to display the image of the customer, empty if no image..</li></ul> |
| **10** | <ul><li>IaaS platform chosen is OpenStack. The install has to provide the following services: Nova, Glance, Keystone, Cinder, Swift, Heat, Neutron. One tenant per group has to be created. 2 users (user, account used for automation and admin) have to be created per tenant.</li><li>The W micro-service cannot be changed by the students.</li><li>Each part of the web page has to be implemented as a micro-service</li><li>Ability to redeploy the application on another tenant or another OpenStack instance.</li><li>DB should be persistent with regards to VMs failures.</li><li>DB and W service should be on a separate private network</li><li>Application should be publicly available on the external network. Only http[s] (ports 80 and 443) will be available from outside.</li><li>Application should support nicely the death of any one of the 5 micro-services and manage scalability.</li><li>All materials should be kept on public git repository (github e.g.) with an Open Source license (Cf: https://opensource.org/licenses prefer the popular ones). App should be deployed from Git up to the infra.</li></ul>|



# Howto create your bastion vm on prod environment

# Connection :
1. Connect using openvpn.
2. Connect to the Openstack Dashboard.
IP du dashboard OpenStack de prod (Helion):
3. To log use : http://10.11.50.26
    * domain : default
    * user name : groupeX    (X = number of your group)
    * password : The password for your group that you should have received by mail.

At that step, you shoud be connected in your respective tenant (groupeX) with a fresh environment.
You need to create a minimal infrastructure, a bastion server using the dashboard.

This openstack has a lot more services than the one we used in the first session. (note that swift and cinder are not yet available which is a problem only for service P and B)
The neutron network service is available, and you will have to use it to create your networks that will host the bastion server.

## Create a private network:

1. Open the menu and click on network then choose networks subitem.
2. Create a new network.
    * Name : you can use whatever name, but as an example we will use "private"
    * Subnet name : private_subnet
    * Network address : CIDR of your network, you can choose what you want, here as an example we can use 10.0.1.0/24.
    * Gateway : 10.0.1.254
    * In subnet details just provide the DNS : 10.11.50.1

This will be your private network, we will deploy our admin VMs inside that network.
You can see there is another network called external-network. This network is a public one. It will be used to provide access to VM from the outside by mapping a floating ip.
However before that, we need to connect private network and external network with a router.

## Create a router:

1. Open the menu and click on network then choose routers subitem.
2. Create a router
    * Name : router1  (as an example)
    * External network : external-network
3. Click on the router1 just created and add an interface to the private network.
4. You can verify in network topology that you have a router in beetween external network and internal one.

Now the networking should be in place.

# Create your bastion (admin) server and access it :

1. Deploy a new vm via the dashboard (launch a new instance)
    * Name: bastion
    * Image: Fedora or Ubuntu (the one you prefer, they have both recent openstack tools)
    * Flavor: m1.small
    * Network: private1  (not the external)
    * Security group: default
    * Key pair: Generate your keypair or provide your ssh pub key.

2. Associate a floating ip to your server (via compute --> Accès & Sécurité --> IP flottantes)
This is a bit tricky, you need first to allocate a floating ip (this will give you an IP on the external network)
Then you will associate this external ip to your bastion VM on the private network.

Ex : in the instance dashboard you should see in the IP column :
VM name :bastion

    10.0.1.5

Floating IPs:

    10.11.50.71


3. Open the menu and click on compute then choose access and security subitem.
4. Manage the default security group to allow Ingress ssh(port 22)
5. You should be able to log on your vm using the floating ip and the ssh key created before.   (please ask if you need assistance with ssh)
    Ex: ssh fedora@10.11.50.71

6. You can install the openstack client to manage the API and do automation. (assuming there is no errors in the above parts)
Ex: dnf install python-openstackclient    --> this will install a recent version of the openstack client on Fedora
7. Get your openrc files by opening the menu and click on compute then choose access and security subitem and menu API access.
Here you can download a rcfile that will give you all the settings to connect to your environment.
You just need to source that file to export the OS* required environment variables.

Note :
Consider the default security group as your admin subnet. Restrict access to it to only ssh.
Applications should be deployed in their respective networks and corresponding security groups.

Advice 1 : do not create a lot of security groups, you will become crazy managing them. A good approach is to map a security group per network and open the required ports.

Advice 2 : look at the orchestration part and mostly service heat. Sounds like an easy way to deploy stuff although not mandatory.

Advice 3 : using IP is painfull in a cloud environment, prefer names.
