# My DevOps_Project 

## Project 14: Understanding IP Addressing and CIDR Notations

### Darey.io DevOps Bootcamp

### Purpose: Learning IP addressing, Subnetting and Cidr Notations.


![Alt text](00.network.png)



### What are IP Addresses? 

An IP address is a unique identifier that allows devices to communicate on the internet or a local network. IP stands for Internet Protocol, which is the set of rules that governs how data is sent and received over the network. An IP address consists of four numbers separated by dots, such as 192.168.1.1. Each number can range from 0 to 255, and the combination of the four numbers can identify any device on the network.

There are two versions of IP addresses: IPv4 and IPv6. IPv4 is the original version that was created in 1983, but it has a limited number of addresses (about 4.3 billion). IPv6 is the newer version that was introduced in 1995, and it has a much larger number of addresses (about 340 undecillion). IPv6 addresses are written as eight groups of four hexadecimal digits separated by colons, such as 2001:db8:0:1234:0:567:8:1.


### Subnetting and Subnet MASK

Subnetting is the process of dividing a network into two or more smaller networks. It helps to improve IP addressing efficiency and network security. A subnet mask is a number that distinguishes the network address and the host address within an IP address.

![Alt text](01.Ip_addr.png)


A subnet mask is a 32-bit number that defines a range of IP addresses available within a network. It allows subnetting, the process of dividing a network into smaller subnets, to make the routing of data more efficient and secure. A subnet mask is used by the router to identify the network address from the IP address. 


### Classful And Classless Addressing

Classful addressing was introduced in 1981 to solve the problem of limited IP address space. However, it had some limitations, such as:

a. It could not accommodate networks with more than 16,384 hosts.
b. It could not support multicast or anycast addressing.
c. It could not use private IP addresses for internal networks.


Classless addressing was introduced in 1993 to overcome these limitations. It uses a two-part view of IP addresses: network prefix and host identifier. The network prefix is fixed by the subnet mask, while the host identifier can vary depending on the subnet size. Classless addressing also uses CIDR notation to indicate the length of the network prefix.

Some advantages of classless addressing are:

a. It can support networks with up to 2^32 hosts.

b. It can support multicast and anycast addressing.

c. It can use private IP addresses for internal networks.

Some disadvantages of classless addressing are:

a. It requires more complex routing algorithms and protocols.

b. It may cause fragmentation or packet loss due to variable length headers.

c. It may increase security risks due to NAT.


#### IP Address Classes:

* Class A IP address: This class uses the first 8 bits to identify the network, and the remaining 24 bits to identify hosts on that network. The range of IP addresses is from 0.0.0.0 to 127.255.255.255. This class is used for very large networks, such as big organizations. For example, the IP address 10.1.2.3 belongs to Class A, with a network ID of 10 and a host ID of 1.2.3.   The public IP range for Class A is from 1.0.0.0 to 127.255.255.2551. The private IP range for Class A is from 10.0.0.0 to 10.255.255.255.


* Class B IP address: This class uses the first 16 bits to identify the network, and the remaining 16 bits to identify hosts on that network. The range of IP addresses is from 128.0.0.0 to 191.255.255.255. This class is used for medium-sized networks, such as multinational companies. For example, the IP address 172.16.4.5 belongs to Class B, with a network ID of 172.16 and a host ID of 4.5. The public IP range for Class B is from 128.0.0.0 to 191.255.255.2552. The private IP range for Class B is from 172.16.0.0 to 172.31.255.255.


* Class C IP address: This class uses the first 24 bits to identify the network, and the remaining 8 bits to identify hosts on that network. The range of IP addresses is from 192.0.0.0 to 223.255.255.255. This class is used for small networks, such as small companies or colleges. For example, the IP address 192.168.1.6 belongs to Class C, with a network ID of 192.168.1 and a host ID of 6. The public IP range for Class C is from 192 .0 .0 .0 to 223 .255 .255 .255 3. The private IP range for Class C is from 192 .168 .0 .0 to 192 .168 .255 .255 3.

* Class D: This class is reserved for multicast addresses, which are used by applications such as video conferencing or streaming media services. Multicast addresses allow multiple devices on a network to receive data from a single source at once. There are two types of multicast addresses: unicast and broadcast. Unicast multicast addresses are used by specific groups of devices within a local area network (LAN)4. Broadcast multicast addresses are used by all devices within a LAN or an extended LAN (EAN).


* Class E: This class is also reserved for experimental purposes and has no defined use in practice.




#### Network Classes:

* Large network class: This class is suitable for networks that have more than 65,534 hosts, such as the Internet. This class requires a Class A IP address, which provides a large number of network IDs and host IDs. For example, the IP address 10.1.2.3 belongs to a large network class, with a subnet mask of 255.0.0.0.


* Medium network class: This class is suitable for networks that have between 254 and 65,534 hosts, such as a campus network. This class requires a Class B IP address, which provides a moderate number of network IDs and host IDs. For example, the IP address 172.16.4.5 belongs to a medium network class, with a subnet mask of 255.255.0.0.

* Small network class: This class is suitable for networks that have less than 254 hosts, such as a home network. This class requires a Class C IP address, which provides a small number of network IDs and host IDs. For example, the IP address 192.168.1.6 belongs to a small network class, with a subnet mask of 255.255.255.0.

![Alt text](02.network&ip.png)

#### Identifying the class of an IP address

If the value is in the range 1 to 127, the address belongs to class A.
If the value is in the range 128 to 191, the address belongs to class B.
If the value is in the range 192 to 223, the address belongs to class C.
If the value is in the range 224 to 239, the address belongs to class D.
If the value is in the range 240 to 255, the address belongs to class E.


#### IP Address Aggregator

A DevOps engineer might need an IP address aggregator for couple of reasons:

* To optimize network performance and bandwidth usage by combining multiple IP addresses into a single range.

* To simplify network configuration and management by reducing the number of IP addresses to deal with.

* To enhance network security and privacy by hiding the individual IP addresses behind a larger supernet.

* To facilitate network troubleshooting and monitoring by identifying the source or destination of network traffic.

Few aggregator tools and methods that can help a DevOps engineer perform an IP address aggregation, depending on their needs and preferences are:

* Using a supernet calculator: A supernet calculator is a web-based tool that can automatically generate the supernet of a given set of IP addresses. A supernet is the smallest network that contains all the given networks as subnets. For example, if you have 10.5.200.0/16 and 10.5.201.0/16 as your input networks, the supernet calculator will output 10.5.200.0/22 as the output network.

* Using an online service: There are some online services that offer IP address aggregation as part of their features. For example, suip.biz is a website that provides various online services based on Miloserdov.org2, such as IP ranges composing, information gathering, web application vulnerability scanners, and more. You can use this website to find out information about yourself or any website by using their IP address aggregator tool.

* Using a command-line tool: If you prefer to use a command-line tool for your IP address aggregation tasks, you can use tools such as Aggregate from ISC3. This tool can take multiple input files with one or more network IDs each in separate line in CIDR notation format, and output the aggregated network ID in CIDR notation format3. 

For example, if you have google-ip.txt with the following content:
66.249.64./20 66./249./80./20 74./125./57./240/29 216./239./44./0/24 216./239./45./0/24 23./251./128./23 23./251./129./24 23./251./130./23 23 ./251 ./130 ./24

You can run aggregate google-ip.txt to get the aggregated network ID as 66 ./249 ./64 ./20.





### References:


1. [Fortinet: What Is An IP Address? How Does It Work?](https://www.fortinet.com/resources/cyberglossary/what-is-ip-address)

2. [Computer NetworkingNotes: IP Address Classes Explained with Examples](https://www.computernetworkingnotes.com/networking-tutorials/ip-address-classes-explained-with-examples.html)

3. [Auvik: Classful and Classless Addressing Explained](https://www.auvik.com/franklyit/blog/classful-classless-addressing/)

4. [Subnet-Calculator](https://www.subnet-calculator.org/supernets.php)