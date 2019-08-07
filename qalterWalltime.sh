

#Alter wall time
#sudo qalter -l walltime=128:00:00 792331i
sudo /lustre/sw/torque/2.5.8/bin/qalter -l walltime=1828:00:00 205837


#Interactive qsub session.....
qsub -I -l walltime=10:00:00
