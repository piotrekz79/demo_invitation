#run TNO North topology
cd /home/${USER}
sudo mn --custom /home/${USER}/demo_invitation/coco_multidomain_invitation.py --topo tnonorth --controller remote,127.0.0.1
