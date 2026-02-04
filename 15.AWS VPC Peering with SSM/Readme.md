# AWS VPC Peering Project with SSM

![Alt text](img/00.vpc_peering.png)


This README provides an overview of setting up VPC peering on AWS, including a step-by-step guide, testing instructions, and a real-world scenario.

## Overview
VPC peering enables private connectivity between two VPCs, allowing resources like EC2 instances to communicate as if they were in the same network. This is useful for secure, low-latency data transfer without using the public internet. We added SSM VPC Endpoints (Preferred — Keeps Everything Private)
This creates private links to AWS Systems Manager services, allowing the SSM Agent to register without internet. 


## Real-World Simulated Scenario Matching this Project
Following the acquisition of a smaller competitor, CloudVista Analytics—a mid-sized SaaS provider specializing in customer data platforms—tasked me as their DevOps engineer with securely connecting the newly acquired company’s AWS account

By establishing VPC peering, configuring non-transitive routing with proper CIDR propagation, tightening security group rules to allow only application-specific ports, deploying SSM interface endpoints for private management of both sides’ instances, and validating bidirectional connectivity with low-latency tests—all without NAT gateways or public exposure.

Hence, the need for a compliant, cost-effective, and high-performance network bridge that accelerated post-merger data integration while preserving strict tenant isolation and eliminating unnecessary internet egress costs.




## Prerequisites
- AWS account with VPC creation permissions.
- Two VPCs with non-overlapping CIDR blocks (e.g., VPC A: 10.0.0.0/16, VPC B: 172.31.0.0/16).
- Basic knowledge of AWS console navigation.


![Alt text](img/01.VPC_creation.png)


## Step-by-Step Setup Guide
1. **Create Peering Request**:
   - Go to VPC console > Peering connections > Create.
   - Specify requester VPC, accepter VPC, and create.

   ![Alt text](img/02.VPC_requester.png)

   ![Alt text](img/03.VPC_accepter.png)

   ![Alt text](img/04.2_diff_VPCs.png)

   ![Alt text](img/05a.create_peer_connection.png)


2. **Accept Request**:
   - In accepter VPC's console, accept the pending connection.

   ![Alt text](img/05b.peer_connect_accept.png)

   ![Alt text](img/05c.peer_connect_accept.png)

   ![Alt text](img/05d.peer_connect.png)



3. **Update Route Tables**:
   - Add routes in each VPC's route table pointing to the other's CIDR via the peering connection.

![Alt text](img/06a.route_tables.png)


![Alt text](img/06b1.copy_accepter_CIDR.png)


![Alt text](img/06b2.%20paste_requester_CIDR.png)


![Alt text](img/06b3.requester_route_updated.png)


![Alt text](img/06c1.copy_accepter_CIDR.png)


![Alt text](img/06c2.%20paste_accepter_CIDR.png)


![Alt text](img/06c3.accepter_route_updated.png)



4. **Create Subnets and Update Security Groups**:
   - Allow inbound traffic (e.g., ICMP) from the peered VPC's CIDR.

![Alt text](img/07a.requester_subnet.png)


![Alt text](img/07b.accepter_subnet.png)


![Alt text](img/07c.subnets.png)


![Alt text](img/08a.add_accepter_subnet_to_vpc's_route_table.png)


![Alt text](img/08b.add_requester_subnet_to_vpc's_route_table.png)


![Alt text](img/09a.requester_sg.png)


![Alt text](img/09b.accepter_sg.png)


![Alt text](img/09c._sg.png)


5. **Provision Test Instances**:
   - Launch EC2 instances in each VPC's subnet (e.g., t2.micro with Amazon Linux).

![Alt text](img/10a1.requester_instance.png)

![Alt text](img/10a2.requester_instance.png)

![Alt text](img/10b1.acceptance_instance.png)

![Alt text](img/10b2.acceptance_instance.png)


**Test Connectivity**:
If we are to keep everything private and test ffctivly. The only option is this: 

6. ** IAM Role: AmazonSSMManagedInstanceCore attached.
   
   *Create IAM role:
   
   ![Alt text](img/11a.IAM_role.png)

   ![Alt text](img/11b.Role_serve_ec2.png)

   ![Alt text](img/11c.IAM_role_SSM.png)

   ![Alt text](img/11d.IAM_role_SSM.png)

   ![Alt text](img/11e.IAM_role_SSM_created.png)
   
   
   *Attach role to EC2

   ![Alt text](img/12a.attach_ssm_role_ec2.png)

   ![Alt text](img/12b.attach_ssm_role_ec2.png)

   ![Alt text](img/12c.attach_ssm_role_ec2.png)

   
   *Reboot instance
   ![Alt text](img/13.reboot_instance.png)



7. **Create a Security Group for the Endpoints: 
   * Endpoint SG traffic: Endpoint SG allows inbound 443 from the Requester SG.
      -create SSM endpoint SG inside the Requester VPC.
      ![Alt text](img/14a.Prepare_ssm_endpoints_SG.png)
      
      ![Alt text](img/14b.Prepare_ssm_endpoints_SG.png)

      -edit inbound rule to HTTPS 443, Requester_VPC
      ![Alt text](img/14c.ssm_endpoints_SG_edit_inbound_rule.png)


   * SG Traffic: Requester SG allows outbound 443 to the Endpoint SG.
      -edit outbound rule by adding an HTTPS 443 rule to SSM_Endpoints_SG
      ![Alt text](img/15a.Requester_SG_edit_outbound_rule.png)

      ![Alt text](img/15b.Requester_SG_edit_outbound_rule.png)

      ![Alt text](img/15c.Requester_SG_outbound_rule.png)



8. ** Endpoints: All 3 SSM endpoints created in the Requester VPC.
   * create endpoints:

   - 01: com.amazonaws.us-east-1.ssm 
      ![Alt text](img/16a.Creating_first_SSM_endpoint.png)

      ![Alt text](img/16b.Creating_first_SSM_endpoint.png)

      ![Alt text](img/16c.Creating_first_SSM_endpoint.png)

      * Enable DNS hostnames and Enable DNS support must be set to True in your requester VPC settings

      ![Alt text](img/16d.endpoint_creation_error.png)  
      
      ![Alt text](img/16e.dns_hostnames_activated.png)

      ![Alt text](img/16g.SSM_first_endpoint_created.png) 

      ![Alt text](img/16f.dns_hostnames_activated&saved.png)

      ![Alt text](img/16g.SSM_first_endpoint_created.png)


      - 02: com.amazonaws.us-east-1.ssmmessages

      ![Alt text](img/17a.create_SSM_second_endpoint.png)

      ![Alt text](img/17b.create_SSM_second_endpoint.png)

      ![Alt text](img/17c.create_SSM_second_endpoint.png)

      ![Alt text](img/17d.SSM_second_endpoint_created.png)

      
      - 03: com.amazonaws.us-east-1.ec2messages

      ![Alt text](img/18a.create_SSM_third_endpoint.png)

      ![Alt text](img/18b.create_SSM_third_endpoint.png)

      ![Alt text](img/18c.create_SSM_third_endpoint.png)

      ![Alt text](img/18d.SSM_third_endpoint_created.png)
   
   
   

9. Confirm SSM EndPoints & SSM agent registration in System Manager
   * check Systems Manager > Fleet Manager > Managed nodes; instance should be "Online
   
   ![Alt text](img/19.3_SSM_endPoints.png)

   ![Alt text](img/20.Confirm_node_online.png.dns_hostnames_activated&saved.png)
   


10. Connect and Test:
   EC2 console → select Requester instance → Connect → Session Manager → Connect.
   Run ping 172.16.0.6 (Accepter private IP) to test peering.

   ![Alt text](img/21a.copy_accepter_ip.png)

   ![Alt text](img/22.click_connect_requester.png)

   ![Alt text](img/23.session_manager_connect.png)

   ![Alt text](img/25a.no_of_sessions_logged.png)


11. Other things you can do in this successful connection
      $ nc -zv 172.16.0.6 22  To check if SSH is open
      $ sudo systemctl status sshd  To check if SSH is running
      $ nc -zv 172.16.0.11 443 check if HTTPS is open
      $ cat /etc/os-release : Check OS name and release
      $ whoami: Check user operating

   ![Alt text](img/24a.ping_accepter_instance.png)

   ![Alt text](img/24b.test_other_commands.png)



12. Session Manager records

   ![Alt text](img/25a.no_of_sessions_logged.png)  


13. Instance Performance

   ![Alt text](img/26a.instances_perf.png)

   ![Alt text](img/26b.instances_perf.png)



## References
- [AWS VPC Peering Documentation](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html)
- [Create VPC Peering Connection](https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html)

