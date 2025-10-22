
I need a terraform project, and code base, which is used for initializing the aws cloud infrastructure compoment for aws parallelcluster, that includes to generate the VPC, and security groups, and shared storage both supporting EFS and Lusture FSx with minimual capacity setup(demo purpose), also can be configurable. Please show me the promot and let me review it, and then run it.

For detailed specification defined as follows:
1. shared storage: I am going to use EFS as the shared storage. and leave FSx lusture as the optional.

2. Set Networking, configurable VPC, and subnets, please keep it avaialble in three subnets, but I only need enable one subnet for all computing note. Set Security Groups with correct rules based on the storage and networking access requirements and aws cloud compoments.

3. Setup proper and least privilegeas for shared storages and computing nodes, and Headnodes.

4. terraform code can be modularized and reusable, and also must be continuesly updated by Kiro
5. Paralles cluster UI is optional, can be enabled or disabled.


When generating the code, please make sure each single steps it is working properly.
Please make sure the code is working properly, and also can be run without any error.


Finally, refer to following CONFIGURATION Template for ParallelCluster to generate the terraform modules.

```yaml
Region: us-east-2
Image:
  Os: ubuntu2204
HeadNode:
  InstanceType: g6.xlarge
  Dcv:
    Enabled: true
  Networking:
    SubnetId: subnet-0658147f48575aef2
    ElasticIp: true
    SecurityGroups:
      - sg-092d4d3a99788549e
  Ssh:
    KeyName: sa-malibo-hpc-east-2
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
    # High-Performance GPU Queue for training/HPC workloads
    - Name: high-gpu-queue
      Networking:
        SubnetIds:
          - subnet-0fabe4bd4f84d0cdc
        SecurityGroups:
          - sg-0dcbc076c351e37e6
      ComputeSettings:
        LocalStorage:
          RootVolume:
            Size: 120
            VolumeType: gp3
      ComputeResources:
        - Name: high-gpu-nodes
          InstanceType: p5.4xlarge
          MinCount: 0
          MaxCount: 4
      Iam:
        AdditionalIamPolicies:
          - Policy: arn:aws:iam::aws:policy/AmazonS3FullAccess
          - Policy: arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
          - Policy: arn:aws:iam::aws:policy/SecretsManagerReadWrite

    # GPU Queue for inference workloads
    - Name: gpu-queue-inference
      Networking:
        SubnetIds:
          - subnet-0fabe4bd4f84d0cdc
        SecurityGroups:
          - sg-0dcbc076c351e37e6
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

    # High CPU Queue
    - Name: cpu-queue-high
      ComputeResources:
        - Name: highcpu-nodes
          InstanceType: c7i.16xlarge
          MinCount: 0
          MaxCount: 50
      Networking:
        SubnetIds:
          - subnet-0fabe4bd4f84d0cdc
        SecurityGroups:
          - sg-0dcbc076c351e37e6
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

    # Default CPU Queue
    - Name: cpu-queue-default
      ComputeResources:
        - Name: defaultcpu-nodes
          InstanceType: c7i.xlarge
          # InstanceType: c7a.xlarge
          MinCount: 0
          MaxCount: 50
      Networking:
        SubnetIds:
          - subnet-0fabe4bd4f84d0cdc
        SecurityGroups:
          - sg-0dcbc076c351e37e6
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

SharedStorage:
  - MountDir: /shared
    Name: shared-efs
    StorageType: Efs
    EfsSettings:
      FileSystemId: fs-0f795a9ddaee0453e
      # AccessPointId: fsap-091e6876c48e7111e
      # EncryptionInTransit: true

Monitoring:
  DetailedMonitoring: false
  Logs:
    CloudWatch:
      Enabled: true
      RetentionInDays: 14

Tags:
  - Key: Project
    Value: ParallelCluster
  - Key: ManagedBy
    Value: Terraform
  - Key: Environment
    Value: dev

```

!!! DO NOT MODIFY MYOWN_PROMPT.MD !!!