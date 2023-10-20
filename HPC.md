# HPC2021  
## Login node 
jlkang@hpc2021.hku.hk: Reserved for file editing, compilation and job submission/management   
jlkang@hpc2021-io1.hku.hk && jlkang@hpc2021-io2.hku.hk: Reserved for file transfer, file management and data analysis/visualization   

```bash
ssh jlkang@hpc2021-io1.hku.hk
# jlkang@hpc2021-io1 Thu Dec 30 13:31:09 ~
pwd # /home/jlkang: $HOME
cd /lustre1/u/jlkang # /lustre1/u/jlkang: $WORK
cd /lustre1/g/sbs_schunter # /lustre1/g/sbs_schunter: PI Group Share
cd /tmp # /tmp
```

### Introduction of each dir
**/home/jlkang**: Long term, small size, 50GB per user, No scheduled clean-up, Daily Backup   
**/lustre1/u/jlkang**: Short term, high performance, 500GB per user, Files not accessed in the past 60 days are subject to clean-up by system
(Be reminded to move important data to $HOME), No Backup   
**/lustre1/g/sbs_schunter**: Moderate term, high performance, 5TB (Default) per PI group, shared between members in a research group, No scheduled clean-up   

```bash
# jlkang@hpc2021-io1 Thu Dec 30 13:52:49 /lustre1/g/sbs_schunter
mkdir Kang; cd Kang; pwd # /lustre1/g/sbs_schunter/Kang: all the files i will store here 
```

#### In /lustre1/
1. Avoid using “-l” option in “ls” command inside /lustre1   
2. Avoid having a large number of files in a single directory inside /lustre1   
3. Avoid accessing small files inside /lustre1   
4. **Keep your source code and executables under /home instead of /lustre1**   
5. Avoid repetitive “stat” operations against files inside /lustre1   
6. Avoid repetitive open/close operations against files inside /lustre1   
```bash
jlkang@hpc2021-io1 Thu Dec 30 13:58:26 /lustre1/g/sbs_schunter/Kang
$diskquota
Disk quotas for user jlkang at Thu Dec 30 14:09:56 HKT 2021
+--------------------+---------+------------------------------+---------------------------------+
|		      | Quota  | Block limits		      | File limits			|
| Filesystem	      | Usage  | used	quota	limit	grace | files	quota	limit	grace	|
+---------------------+--------+------------------------------+---------------------------------+
/home/jlkang             0.0%        0G     52G  [ZFS DOES NOT PROVIDE SOFT QUOTA]
/lustre1/u/jlkang        0.0%        0G    500G    510G      -        4     0G     0G      -
/lustre1/g/sbs_schunter  0.0%        0G   5120G   5130G      -        1     0G     0G      -
```
## Check the installed software in HPC
```bash
# jlkang@hpc2021-io1 Thu Dec 30 14:20:38 ~
module keyword raxml samtools # module keyword [word1] [word2]: Search for available modules matching the keyword(s)
module load raxml samtools # module load [modA] [modB] [modC]: Load the environment for the default version of modules named modA, modB and modC in corresponding order
module list # List any currently loaded module(s)
module load bcftools/1.14 # module load [mod]/[version]: Load the environment for the specified version of module
```

## Tips
1. When one module is in conflict with another (e.g different MPI libraries), the conflicting module may have to be unloaded before a desired one is loaded.   
2. some modules may depend on one another and hence they may be loaded/unloaded as a consequence of a subsequent module command in a dynamic fashion.   
3. To achieve automatic loading of a set of commonly used modules upon system login, user may add the module command in the shell profile (.bashrc).   
4. When caching error occurs while listing/loading modules, a user may delete the cache file and run the module command again.   
```bash
rm -f /home/jlkang/.lmod.d/.cache/*.lua
```

## Job Submission
```bash
# jlkang@hpc2021 Thu Dec 30 15:19:01 ~
vi script.cmd
```

script.cmd   
```bash
#!/bin/bash
#SBATCH --job-name=jmodeltest        # 1. Job name
#SBATCH --mail-type=BEGIN,END,FAIL    # 2. Send email upon events (Options: NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=jlkang@hku.hk     #    Email address to receive notification
#SBATCH --partition=amd               # 3. Request a partition
#SBATCH --qos=normal                  # 4. Request a QoS
#SBATCH --nodes=1                     #    Request number of node(s)
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=128
#SBATCH --mem-per-cpu=1G
#SBATCH --time=1-10:00:00             # 7. Job execution duration limit day-hour:min:sec
#SBATCH --output=%x_%j.out            # 8. Standard output log as $job_name_$job_id.out
#SBATCH --error=%x_%j.err             #    Standard error log as $job_name_$job_id.err
 
# print the start time
date
java -jar /home/jlkang/jmodeltest-2.1.10/jModelTest.jar -d single_copy.cds.concatenated.fasta -g 4 -i -f -AIC -BIC -a -tr 128
# print the end time
date
```

**Submit:**    
```bash
# jlkang@hpc2021 Thu Dec 30 15:19:32 ~
sbatch script.cmd
# Submitted batch job 112667
# jlkang@hpc2021 Thu Dec 30 15:26:08 ~
scancel 112667 # scancel <JobID>: cancel
# jlkang@hpc2021 Mon Apr 24 10:45:46 /lustre1/g/sbs_schunter/Kang/sea_urchin
sbatch --test-only script1.cmd # Check the waiting time
# sbatch: Job 1118951 to start at 2023-04-24T10:45:50 using 32 processors on nodes GPA-2-9 in partition amd
```
**Check job status:**
```bash
# jlkang@hpc2021 Thu Dec 30 15:22:35 ~
sq
# JOBID  PARTITION  NAME         ST   USER       QOS      NODES CPUS  TRES_PER_NODE TIME_LIMIT  TIME_LEFT   NODELIST(REASON)
# 112667 amd        jmodeltest   PD   jlkang     normal   1     1     N/A           1-10:00:00  1-10:00:00  (Resources)
sj # sj -j 1468368 : check the queue time for your submitted job
# Job ID: 1468368    Account: sbs_schunter                  2023-10-20 16:50:35
#╒═════════════════╤════════════════════════════════════════╤══════════════════╕
#│ User: jlkang    │ Name: diamond                          │ State: PENDING   │
#│  QoS: normal    │ Partition: amd                         │ Priority: 41180  │
#╞═════════════════╪════════════════════════════════════════╧══════════════════╡
#│      Submit     │ 2023-10-20 16:48:21                                       │
#│      Start      │ 2023-10-21 14:26:25                                       │
#│      End By     │ 2023-10-28 14:26:25                                       │
#╞═════════════════╪════════════════════╤══════════════════════════════════════╡
#│     Resource    │           Requests │ Current usage                        │
#├─────────────────┼────────────────────┼──────────────────────────────────────┤
#│         Node    │                  1 │ Pending for (Priority)...            │
#│          CPU    │                 32 │ Nil%                                 │
#│          RAM    │               32GB │ Nil%                                 │
#│    Wall time    │         7-00:00:00 │ 0:00                                 │
#│          GPU    │                N/A │ Nil                                  │
#└─────────────────┴────────────────────┴──────────────────────────────────────┘
```
