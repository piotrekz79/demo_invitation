#run TNO South topology
cd /home/${USER}
sudo mn --custom /home/${USER}/demo_invitation/coco_multidomain_invitation.py --topo tnosouth --controller remote,127.0.0.1
