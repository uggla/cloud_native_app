Cloud Native Application
========================

This document purpose is to describe the Cloud Native Application training described below and which is in particular delivered to ENSIMAG IS students in 2016 and 2017.

Document writers:

 * Bruno.Cornec@hpe.com
 * Rene.Ribaud@dxc.com
 * Christophe.Larsonneur@dxc.com

# Overview of the Assessment

## Objectives

The goal of this document is to describe the use case that will be used for the training of ENSIMAG students

## Reference documents

The main OpenStack entry point is at http://www.openstack.org

 * v1.0:	2016-09-29 - First version
 * v1.1:	2016-11-28 - Update with grade per part
 * v1.2:	2017-01-16 - Update with evaluation method
 * v2.0:	2017-09-25 - More focus on the DevOps life-cycle

# Customer Story

## Objectives

The goal of this training is to realize a promotional lottery for an e-commerce site

## Details

Customers of a big e-commerce site will receive a promotional email with a link to earn a price if they are lucky. The application should detect whether the player already played or not, and whether he won already or not. Each status should be kept with the date when it was performed. The application will provide a button allowing the customer to play, in case he didn't already, and the result of the computation which will happen behind the scene will give to the customer the nature of the article he has won, and display the corresponding image in the interface. Mails will be sent to admins when a winner is found.

Practitioners will first have to automate the management of a virtual infrastructure (Infrastructure as code concept). Within this part we are using Openstack as our Infrastructure as a Service platform (IaaS) but this is an implementation choice. The same principles can be implemented on top of another IaaS platform like Eucalyptus, Cloudstack, Amazon AWS, Azure, Docker. The teachers team will provide two physical infrastructures for that purpose, one which will be pre-installed with an OpenStack distribution in which a tenant per group of student will be available for application development, and another one (set of 15 servers) which will be pre-installed with just a CentOS 7 Operating System. Students will configure the IaaS part on top of it to study the various components that they want to test. 

This part will be **evaluated on 4 points**.

Then they will have to create a cloud native application to support the marketing activity. That application will consist of:
 * 1 Web page with 5 parts/micro-services: I, S, B, W and P.
 * I(dentification) service: receives http request from customer (link with customer ID) and look for it into DB (script to build it provided separately by teachers team).
 * S(tatus) service: detect whether customer already played or not, status stored in the DB. (DB choice left to students - HA to be seen). Can have a message bus to buffer requests.
 * B(utton) service: button widget allowing the customer to play. Only when not already done.
 * W(orker) service that computes whether the customer won or not (slow service provided by the teachers team with a REST API interface), called by B. If won, post an image representing what has been won into OpenStack Swift with customer ID. Then post by e-mail via an external provider a message to admins (using a message bus if possible). Button is gray if the customer has already played.
 * P(icture) service: Look into Swift with customer ID to display the image of the customer, empty if no image.

This part will be **evaluated on 6 points**.

The content provided by the teachers team will be referenced on the etherpad used to follow the exchanges on the project (https://etherpad.openstack.org/p/ENSIMAG_2017)

## Goals & constraints

The app must have the following goals & constraints:

 1. IaaS platform chosen is OpenStack. The install has to provide the following services: Nova, Glance, Keystone, Cinder, Swift, Heat, Neutron. One tenant per group has to be created. 2 users (user, account used for automation and admin) have to be created per tenant.
 2. The W micro-service is a third party software (provided by the teachers team) and cannot be changed by the students.
 3. Each part of the web page has to be implemented as a micro-service.
 4. Using automation, students should be able to redeploy their application on another tenant or another OpenStack instance. (Think to initial conditions, some steps can still remain manual).
 5. DB should be persistent with regards to VMs failures.
 6. DB and W service should be on a separate private network.
 7. Application should be publicly available on the external network. Only http[s] (ports 80 and 443) will be available from outside.
 8. Application should support nicely the death of any one of the 5 micro-services. (Page should still be displayed anyway, printing N/A is OK, having an error isn't). As well it should be scalable in case of insufficient resources.
 9. All materials should be kept on public git repository (github e.g.) with an Open Source license (Cf: https://opensource.org/licenses prefer the popular ones). App should be deployed from Git up to the infra, with either ansible, heat, or any other automation tool/script.

This part will be **evaluated on 10 points** (automation will be particularly important)

## Bonus goals and constraints

In addition, the app may have the following goals & constraints:

 1. The DB info should resist to failure and not loose records (Using a message bus e.g. to handle failures).
 2. The application provided has some latency. Use OpenStack to scale it up (message bus/ha proxy) in order to be able to exceed the 4 reqs on a lapse of 10 seconds. A LBaaS (Load Balancer as a Service) can also be used and provided as part of the solution.
 3. Monitoring, Security, Error case, Full HA, Full install/conf automation, Automatic Scalability.

This part will be **evaluated on 4 additional bonus points**.

## Deliverables

 * On Gihub: 
   * Heat template/ansible playbooks/scripts for Infra group
   * Performance and tests results
   * Application code
 * Application design document
 * Present the (almost !) automatic deployment of the application in a new empty tenant and make reliability checks.

## Teachers support

Teachers will provide a remote access to the pre-production platform (set of servers preinstalled with a CentOS 7 distribution) that the IaaS team will have to setup from an OpenStack perspective and deliver so the DevOps teams could deploy their application on it. Teachers will also provide a production platform running an OpenStack distribution as a development environment for the application developers for testing purposes. 
A mailing list has been created to provide remote support to students during the whole period. Various people will so be available to answer questions and help with regards to platform setup and access. The mailing-list address is ensimag-openstack@lists.osp.hpe.com 

# Agenda

Each session is 3 hours long

## First session

 * Project explanation: Overall Goals & method (groups, prod platform, TD systems for tests). The goal is to provide a cloud native application, providing redundancy and scalability, using an OpenStack infrastructure. No formal solution will be directly given, students will have to build the solution by themselves. Many approaches are possible.  The teachers team role will be after the 2 first sessions and generic presentations on all concepts to help them in the realization of that application and its setup.
 * Cloud fundamentals: IaaS  (Bruno)
 * OpenStack architecture & example (Bruno )
 * DevStack installation - stackrc + env var - image shared between groups (on ENSIMAG systems - nested with prepared VM or BM in B10) (Jérôme - Alexis - René)
 * Production platform exaplanation (Bruno)
 * Home work: 
   * Continue to explore OpenStack from both UI & CLI
   * Create 9 groups of 5 students (one country per group), assign specialization (ops, devs, middleware, ... + backup), tool choice left to students, but licensing should be correct (prefer Open Source)

## Second session

 * Cloud fundamentals: DevOps (Christophe)
 * 12 factors apps - micro services (Nicolas)
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
