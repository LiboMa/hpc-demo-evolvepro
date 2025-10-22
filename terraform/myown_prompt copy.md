
I need a terraform project, and code base, which is used for initializing the aws cloud infrastructure compoment for aws parallelcluster, that includes to generate the VPC, and security groups, and shared storage both supporting EFS and Lusture FSx with minimual capacity setup(demo purpose), also can be configurable. Please show me the promot and let me review it, and then run it.

For detailed specification defined as follows:
1. shared storage: I am going to use EFS as the shared storage. and leave FSx lusture as the optional.

2. Networking and security gruop. and VPC, please keep it avaialble in three subnets, but I only need enable one subnet for all computing note.
3. setup proper and least privilegeas for shared storage and computing nodes.

4. terraform code can be modularized and reusable, and also must be continuesly updated by Kiro
5. Paralles cluster UI is optional, can be enabled or disabled.


When generating the code, please make sure each single steps it is working properly.
Please make sure the code is working properly, and also can be run without any error.


Finally, refer to following CONFIGURATION Template for ParallelCluster to generate the terraform modules.

```yaml
---

Region: us-east-2

Image:

  Os: ubuntu2404

HeadNode:

  InstanceType: g6.xlarge 

  Dcv:

    Enabled: true

  Networking:

    # SubnetId: subnet-0b5ba9b42ac7d3f8d

    SubnetId: subnet-08aa4b0ebdc6a4b73

    ElasticIp: true

    SecurityGroups:

      - sg-06629a91dbe5d43ce 

      # - sg-0533800406d730d7d

  Ssh:

    KeyName: 3s-hpc-key 

    # KeyName: sa-malibo-hpc  

  Iam:

    AdditionalIamPolicies:

      - Policy: arn:aws:iam::aws:policy/AmazonS3FullAccess

      - Policy: arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

      - Policy: arn:aws:iam::aws:policy/SecretsManagerReadWrite

  LocalStorage:

    RootVolume:

      Size: 120

      VolumeType: gp3

Scheduling:

  Scheduler: slurm

  SlurmSettings:

    ScaledownIdletime: 10

    QueueUpdateStrategy: TERMINATE

  SlurmQueues:

    # - Name: gpu-queue-h100-1

    #   CapacityType: CAPACITY_BLOCK 

    #   Networking:

    #     SubnetIds:

    #       # - subnet-05ab2157bfc154088  # Private subnet where compute nodes run

    #       - subnet-08aa4b0ebdc6a4b73 # Private subnet where compute nodes run

    #     SecurityGroups:

    #       - sg-06629a91dbe5d43ce # Existing security group from PCS cluster

    #     PlacementGroup:

    #       Enabled: true

    #   ComputeSettings:

    #     LocalStorage:

    #       RootVolume:

    #         Size: 120

    #         VolumeType: gp3

    #   ComputeResources:

    #     - Name: gpu-nodes-h100-1-p5

    #       InstanceType: p5.4xlarge

    #       MinCount: 0

    #       MaxCount: 5

    #   CapacityReservationTarget:

    #     # CapacityReservationId: cr-0acf0d45e6a6e45be 

    #     CapacityReservationId: cr-083bf84b0fe759052 

    - Name: gpu-queue-a100-8-p4d # 48 GB mem

      Networking:

        SubnetIds:

          # - subnet-05ab2157bfc154088  # Private subnet where compute nodes run

          - subnet-08aa4b0ebdc6a4b73 # Private subnet where compute nodes run

        SecurityGroups:

          - sg-06629a91dbe5d43ce # Existing security group from PCS cluster

        PlacementGroup:

          Enabled: true

      ComputeSettings:

        LocalStorage:

          RootVolume:

            Size: 120

            VolumeType: gp3

      ComputeResources:

        - Name: gpu-nodes-a100-8-p4d

          InstanceType: p4d.24xlarge

          MinCount: 0

          MaxCount: 5

          CapacityReservationTarget:

            # CapacityReservationId: cr-0acf0d45e6a6e45be 

            CapacityReservationId: cr-06ec517ae4a3d013e 

    - Name: gpu-queue-infernece

      Networking:

        SubnetIds:

          - subnet-08aa4b0ebdc6a4b73 # Private subnet where compute nodes run

          # - subnet-05ab2157bfc154088 # Private subnet where compute nodes run

        SecurityGroups:

          - sg-06629a91dbe5d43ce # Existing security group from PCS cluster

          # - sg-0533800406d730d7d # Existing security group from PCS cluster

        PlacementGroup:

          Enabled: true

      ComputeSettings:

        LocalStorage:

          RootVolume:

            Size: 120

            VolumeType: gp3

      ComputeResources:

        - Name: gpu-nodes-g6f-l4

          InstanceType: g6f.2xlarge

          MinCount: 0

          MaxCount: 10

    - Name: cpu-queue-high

      ComputeResources:

        - Name: highcpu-nodes

          InstanceType: c7i.16xlarge # 64 vCPUs, 128 GiB memory, 25Gbps network 

          MinCount: 0

          MaxCount: 50

      Networking:

        SubnetIds:

          # - subnet-05ab2157bfc154088 #Private subnet where compute nodes run

          - subnet-08aa4b0ebdc6a4b73 # Private 

          # - subnet-06629a91dbe5d43ce # private subnet where compute nodes run

        SecurityGroups:

          - sg-06629a91dbe5d43ce 

          # - sg-0533800406d730d7d # Existing security group from PCS cluster

      ComputeSettings:

        LocalStorage:

          RootVolume:

            Size: 120

            VolumeType: gp3

      Iam:

        AdditionalIamPolicies:

          - Policy: arn:aws:iam::aws:policy/AmazonS3FullAccess

          - Policy: arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

          - Policy: arn:aws:iam::aws:policy/SecretsManagerReadWrite

    - Name: cpu-queue-default 

      ComputeResources:

        - Name: defaultcpu-nodes

          InstanceType: c7i.2xlarge

          MinCount: 0

          MaxCount: 50

      Networking:

        SubnetIds:

          # - subnet-05ab2157bfc154088 #Private subnet where compute nodes run

          - subnet-08aa4b0ebdc6a4b73 # private subnet where compute nodes run

        SecurityGroups:

          - sg-06629a91dbe5d43ce 

          # - sg-0533800406d730d7d # Existing security group from PCS cluster

      ComputeSettings:

        LocalStorage:

          RootVolume:

            Size: 120

            VolumeType: gp3

      Iam:

        AdditionalIamPolicies:

          - Policy: arn:aws:iam::aws:policy/AmazonS3FullAccess

          - Policy: arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

          - Policy: arn:aws:iam::aws:policy/SecretsManagerReadWrite

Monitoring:

  DetailedMonitoring: false

  Logs:

    CloudWatch:

      Enabled: true

      RetentionInDays: 14

SharedStorage:

- MountDir: /shared

    Name: fsx-lustre-shared

    StorageType: FsxLustre

    FsxLustreSettings:

      FileSystemId: fs-0a0dc0dc7cd8de169 

# FileSystemId: fs-043cde79e94f1801e

Tags:

- Key: Environment

    Value: hpc-demo

- Key: Project

    Value: sansheng-hpc

- Key: Owner

    Value: hpc-for-sansheng
```

!!! DO NOT MODIFY MYOWN_PROMPT.MD !!!