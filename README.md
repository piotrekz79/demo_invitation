# demo_invitation

This is a demonstration of multidomain CoCo with email-based VPN invitation system.
Under the hood, vpnintent framework is used.

Works on
.202 (TN2) & .201 (TS2)
Demo
1. Start ODL controller
 /home/coco/distribution-karaf-0.4.2-Berylium-SR2/bin/karaf

 needed features are

 feature:install odl-vpn-service-intent
 feature:install odl-dlux-all

If the controller fails, in check
~/install_scripts/install-odl-intent.sh

2. start mysql server ( if not running already: sudo service mysql status )

 The database (CoCoINV) is automatically populated based on mininet topology. 


3. Note: to run mininet (next step) for standard python installation we may need
 sudo pip install netaddr

 sudo apt-get install python-mysqldb

 or even before it

 sudo apt-get install libmysqlclient-dev

 sudo pip install exabgp
 
 exabgp will need this for communication with portal 

 sudo pip install httplib2

[DEBUG] to run test server
 sudo pip install tornado
 then run on TS (.201)

 ./exabgp_tmpdev/tornado-web.py

 this server listens on 5003 and accepts POST and dumps them to the console
 it pretends to be a portal module which will really 
 accept and process updates from BGP

4. Start mininet with predefined topologies


 To run TNO North topology, start (on .202)
 ./mntn.sh

 then to add initial configuration (BGP flows, GRE), run
 ./tnflows_gw.sh


 To run TNO North topology, start (on .201)
 ./mnts.sh

 then to add initial configuration (BGP flows, GRE), run
 ./tsflows_gw.sh


 Note: GRE tunnel endpoints configured in t?flows_gw.sh are likely to be reconfigured



5. Starting minites starts also exabgp route reflector (within a domain). It accepts REST calls on http://10.10.10.1:5001
which will originate from portal

[DEBUG]
To test, issue on TN 

curl --form "command=neighbor 10.3.0.254 announce route 10.2.1.128/25 next-hop 10.2.0.254 extended-community 0x0002FDE800000001 extended-community 0x8ABCBEEFDEADBEEF" http://10.10.10.1:5001/

on TS tornado server we should see json string with the BGP update (note ext-community strings were converted from hex to (long)int, first two bytes are type and subtype so for nonce we can use 6B only, not 8B

=======REQUEST=======
HTTPServerRequest(protocol='http', host='10.10.10.2:5003', method='POST', uri='/', version='HTTP/1.1', remote_ip='10.10.10.1', headers={'Host': '10.10.10.2:5003', 'Content-Type': 'application/json; charset=UTF-8', 'Content-Length': '512', 'Accept-Encoding': 'gzip, deflate', 'User-Agent': 'Python-httplib2/0.9.2 (gzip)'})
=======REQUEST BODY=======
'{ "exabgp": "3.4.8", "time": 1478009901, "host" : "TS2-ODL", "pid" : "2009", "ppid" : "1", "counter": 94, "type": "update", "neighbor": { "ip": "10.2.0.254", "address": { "local": "10.3.0.254", "peer": "10.2.0.254"}, "asn": { "local": "65030", "peer": "65020"}, "message": { "update": { "attribute": { "origin": "igp", "as-path": [ 65020 ], "confederation-path": [], "extended-community": [ 842122827661313, 9997075210298048239 ] }, "announce": { "ipv4 unicast": { "10.2.0.254": { "10.2.1.128/25": {  } } } } } }} }'


curl --form "command=neighbor 10.3.0.254 announce route 10.2.1.0/25 next-hop self extended-community 0x0002FDE800000001 extended-community 0xC0C0BEEFDEADBEEF" http://10.10.10.1:5001/

#0002 : route target
#FDFC : AS65020
#00000001 : 1st VPN so RT can be written as 65020:1

#C0C0 : experimatal extended community (rfc4360, p. 8)
#BEEFDEADBEEF : 6B token (nonce)

in case of problems with exabgp
kill -KILLALL exabgp
assure /var/run/exabgp has no pid file if exa is not supposed to be running

=== GARBAGE
 Demo
1) start ODL
/home/coco/vpnservice-karaf-intent/distribution-karaf-0.4.2-Berylium-SR2-clean/bin/karaf

needed features are

feature:install odl-vpn-service-intent
feature:install odl-dlux-all


2) start mysql
...

Note: if using topo_bbf1_db.py (recommended, see below) then the database is automatically
populated based on mininet topology. As a backup option, there is 
demo_bbf_clean.sql file which contains all needed but empty tables.
Use it in case of troubles, when 'factory reset' is needed etc. or when
you comment out line 402 in topo_bbf1db.py
402 |	databaseDump(net)
 

#DON'T RUN UNLESS YOU KNOW WHAT YOU ARE DOING

3) start mininet
cd /home/coco/demo_bbf
sudo python topo_bbf1_db.py

we may need
sudo pip install netaddr

sudo apt-get install python-mysqldb

or even before it

sudo apt-get install libmysqlclient-dev



4) kill arp flows (static arps installed on the hosts)
/home/coco/demo_bbf/del_arp_flows.sh

5) start CoCo portal
        5a) run Eclipse
               /home/coco/eclipse_ee/eclipse/eclipse
               use workspace  /home/coco/workspace_cocoIntent
        5b) within Eclipse go to "Servers" tab (bottom panel)
        5c) Right click "Tomcat v7.0 Server at localhost" and click "Start"

               note: dafault 8080 port conflicts with ODL; double click on the server name 
               in "Servers" tab and change http 1.1 port to, say, 9090

               IP/database name/password  may need to be adjusted
               navigate to  CoCo-agent/src/net/geant/coco/agent/portal/props
               adjust the values in config.properties and jdbc.properties

               also adjust Servers/Tomcat 7.0/context.xml

 

6)use the following link to start coco portal 
http://localhost:9090/CoCo-agent/static/index.html 

7) connect hosts (e.g., h1 and h2) in CoCo portal and check connectivity from mininet
mininet> xterm h1
ping 10.0.2.1
