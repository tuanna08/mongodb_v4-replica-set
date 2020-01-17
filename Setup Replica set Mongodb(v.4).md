# Setup Replica set Mongodb(v.4) on ubuntu 18.04 lts with keyfile authorition

```

------------+---------------------------+---------------------------+------------
            |                           |                           |
        eth0|192.168.55.80          eth0|192.168.55.81          eth0|192.168.55.82
+-----------+-----------+   +-----------+-----------+   +-----------+-----------+
|    [ replica set 01 ] |   |    [ replica set 02 ] |   |    [ replica set 03 ] |
|                       |   |                       |   |                       |
|  mongodb              |   |      mongodb          |   |        mongodb        |
|  node-exporter        |   |      node-exporter    |   |     node-exporter     |
|  mongo-exporter       |   |      mongo-exporter   |   |      mongo-exporter   |
|                       |   |                       |   |                       |
|                       |   |                       |   |                       |
|                       |   |                       |   |                       |
+-----------------------+   +-----------+-----------+   +-----------------------+

------------+------------
            |
        eth0|192.168.55.83
+-----------+-----------+
|    [ Arbiter ]        |
|                       |
|        mongodb        |
|        Prometheus     |
|        grafana        |
|                       |
|                       |
|                       |
+-----------------------+
```


### 1: Install MongoDB on all node
```
$ cat /etc/hosts
192.168.55.80    node01	node01.local
192.168.55.81    node02	node02.local
192.168.55.82    node03	node03.local
192.168.55.83    node03	node04.local
```
Go ahead update the repositories, add the mongodb repostory, update and install mongodb:
```
$ sudo apt update
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
$ echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
$ sudo apt update
$ sudo apt install mongodb-org -y
```

Verify that mongodb is installed:
```
$ mongod --version
db version v4.0.10
git version: c389e7f69f637f7a1ac3cc9fae843b635f20b766
OpenSSL version: OpenSSL 1.1.1  11 Sep 2018
allocator: tcmalloc
modules: none
build environment:
    distmod: ubuntu1804
    distarch: x86_64
    target_arch: x86_64
```

### 2: Keyfile Authorization
All nodes will use the same preshared key to autenticate the members that will contribute to the replca set. Let's create the directory where the file will be stored:
```
$ sudo mkdir /var/lib/mongodb-pki
```
Use openssl or anything similar to generate a random key(on node 1):
```
$ openssl rand -base64 741 > keyfile
```
Copy the file over to the other nodes with scp:
```
$ scp ./keyfile node02:/root/keyfile
$ scp ./keyfile node03:/root/keyfile
$ scp ./keyfile node04:/root/keyfile
```
Move the keyfile in place on all nodes and change the permissions of the file:
```
$ sudo mv keyfile /var/lib/mongodb-pki/keyfile
$ sudo chmod 600 /var/lib/mongodb-pki/keyfile
$ sudo chown -R mongodb:mongodb /var/lib/mongodb-pki
```

### 3: Configure Mongod all node

```
$ sudo nano /etc/mongod.conf

# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0


# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo

#security:

#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options:

#auditLog:

#snmp:

operationProfiling:
  mode: "slowOp"
  slowOpThresholdMs: 50

security:
  authorization: enabled
  keyFile: /var/lib/mongodb-pki/keyfile

replication:
  replSetName: demo-replset
```

```
$ sudo systemctl enable mongod
$ sudo systemctl restart mongod
```

Verify that the port is listening:
```
root@node03:~# sudo netstat -tulpn | grep 27017
tcp        0      0 0.0.0.0:27017           0.0.0.0:*               LISTEN      3255/mongod

```
Go ahead and do the exact same on the other all nodes.


### 4: Initialize the MongoDB Replica Set
When mongodb starts for the first time it allows an exception that you can logon without authentication to create the root account, but only on localhost. The exception is only valid until you create the user:
```
root@node01:~# mongo --host 127.0.0.1 --port 27017
MongoDB shell version v4.0.14
connecting to: mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("1a91c1e2-e484-4734-8296-54c92ce6a5e1") }
MongoDB server version: 4.0.14
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	http://docs.mongodb.org/
Questions? Try the support group
	http://groups.google.com/group/mongodb-user
>
```
Switch to the admin database and initialize the mongodb replicaset:
```
> use admin
switched to db admin
> rs.initiate()
{
    "info2" : "no configuration specified. Using a default configuration for the set",
    "me" : "10.163.68.26:27017",
    "ok" : 1
}
```
Now that we have initialized our replicaset config, create the admin user and apply the root role:
```
civo-demo-replset:PRIMARY> db.createUser({user: "mongo-admin", pwd: "mongo-pass", roles: [{role: "root", db: "admin"}]})
Successfully added user: {
    "user" : "mongo-admin",
    "roles" : [
        {
            "role" : "root",
            "db" : "admin"
        }
    ]
}
civo-demo-replset:PRIMARY> exit
```
Now that we have exited the mongo shell, logon to mongodb with the created credentials also pointing at the replica set in the connection string:
```
root@node01:~# mongo --host demo-replset/node01:27017 --username mongo-admin --password mongo-pass --authenticationDatabase admin
MongoDB shell version v4.0.14
connecting to: mongodb://node01:27017/?authSource=admin&gssapiServiceName=mongodb&replicaSet=demo-replset
2020-01-10T03:57:49.311+0000 I NETWORK  [js] Starting new replica set monitor for demo-replset/node01:27017
2020-01-10T03:57:49.314+0000 I NETWORK  [js] Successfully connected to node01:27017 (1 connections now open to node01:27017 with a 5 second timeout)
Implicit session: session { "id" : UUID("2bd9a008-e63c-4bf2-92b5-3758ee902a5c") }
MongoDB server version: 4.0.14
Server has startup warnings:
2020-01-10T03:47:11.665+0000 I STORAGE  [initandlisten]
2020-01-10T03:47:11.665+0000 I STORAGE  [initandlisten] ** WARNING: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine
2020-01-10T03:47:11.665+0000 I STORAGE  [initandlisten] **          See http://dochub.mongodb.org/core/prodnotes-filesystem
---
Enable MongoDB's free cloud-based monitoring service, which will then receive and display
metrics about your deployment (disk utilization, CPU, operation statistics, etc).

The monitoring data will be available on a MongoDB website with a unique URL accessible to you
and anyone you share the URL with. MongoDB may use this information to make product
improvements and to suggest MongoDB products and deployment options to you.

To enable free monitoring, run the following command: db.enableFreeMonitoring()
To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
---

demo-replset:PRIMARY>


```
```
rs.status()
demo-replset:PRIMARY> rs.add("node02:27017")

```
add Arbiter

```
rs.addArb("node04:27017")
```

We can verify if we are on the primary by doing the following:

```
demo-replset:PRIMARY> rs.isMaster()['ismaster']
true
demo-replset:PRIMARY> rs.isMaster()['me']
node01:27017
```

We first need to instruct mongodb that we want to read:
```
demo-replset:PRIMARY>  rs.slaveOk()

```

