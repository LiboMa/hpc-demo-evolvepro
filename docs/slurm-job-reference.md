# SLURM 作业处理参考指南

## 基本作业提交命令

### CPU队列作业提交

```bash
# 基本CPU作业提交
sbatch -p cpu-queue hellojob.sh

# 指定特定CPU实例类型
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-2xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-4xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-16xl" hellojob.sh

# 指定资源需求
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" --ntasks=16 --cpus-per-task=2 hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-4xl" --ntasks=8 --mem=32G hellojob.sh
```

### GPU队列作业提交

```bash
# 基本GPU作业提交
sbatch -p gpu-queue hellojob.sh

# 指定特定GPU实例类型
sbatch -p gpu-queue --constraint="gpu-nodes-g5" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-g6e" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p4d" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p5" hellojob.sh

# 指定GPU数量
sbatch -p gpu-queue --constraint="gpu-nodes-g6e" --gres=gpu:1 hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p4d" --gres=gpu:8 hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p5" --gres=gpu:8 hellojob.sh
```

### 内存优化队列作业提交

```bash
# 内存优化实例
sbatch -p memory-queue --constraint="mem-nodes-r7i-2xl" hellojob.sh
sbatch -p memory-queue --constraint="mem-nodes-r7i-8xl" hellojob.sh
sbatch -p memory-queue --constraint="mem-nodes-r7i-16xl" hellojob.sh

# 指定大内存需求
sbatch -p memory-queue --constraint="mem-nodes-r7i-8xl" --mem=200G hellojob.sh
```

## 作业脚本模板

### 基本CPU作业脚本
```bash
#!/bin/bash
#SBATCH --job-name=cpu-test
#SBATCH --partition=cpu-queue
#SBATCH --constraint=cpu-nodes-c7i-8xl
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=cpu-job-%j.out
#SBATCH --error=cpu-job-%j.err

echo "Job started at: $(date)"
echo "Running on node: $(hostname)"
echo "CPU info:"
lscpu | grep "Model name"
echo "Memory info:"
free -h

# 您的计算任务
echo "Running CPU-intensive task..."
stress --cpu 16 --timeout 300s

echo "Job completed at: $(date)"
```

### GPU作业脚本
```bash
#!/bin/bash
#SBATCH --job-name=gpu-test
#SBATCH --partition=gpu-queue
#SBATCH --constraint=gpu-nodes-g6e
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=gpu-job-%j.out
#SBATCH --error=gpu-job-%j.err

echo "Job started at: $(date)"
echo "Running on node: $(hostname)"
echo "GPU info:"
nvidia-smi

# 加载CUDA环境
module load cuda/12.0

# 您的GPU计算任务
echo "Running GPU computation..."
python3 gpu_training.py

echo "Job completed at: $(date)"
```

### 并行MPI作业脚本
```bash
#!/bin/bash
#SBATCH --job-name=mpi-job
#SBATCH --partition=cpu-queue
#SBATCH --constraint=cpu-nodes-c7i-16xl
#SBATCH --ntasks=64
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=04:00:00
#SBATCH --output=mpi-job-%j.out
#SBATCH --error=mpi-job-%j.err

echo "Job started at: $(date)"
echo "Running on nodes: $SLURM_JOB_NODELIST"
echo "Total tasks: $SLURM_NTASKS"

# 加载MPI环境
module load openmpi/4.1.0

# 运行MPI程序
mpirun -np $SLURM_NTASKS ./my_mpi_program

echo "Job completed at: $(date)"
```

### 数组作业脚本
```bash
#!/bin/bash
#SBATCH --job-name=array-job
#SBATCH --partition=cpu-queue
#SBATCH --constraint=cpu-nodes-c7i-4xl
#SBATCH --array=1-100
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH --output=array-job-%A_%a.out
#SBATCH --error=array-job-%A_%a.err

echo "Array job ID: $SLURM_ARRAY_JOB_ID"
echo "Array task ID: $SLURM_ARRAY_TASK_ID"
echo "Running on node: $(hostname)"

# 处理特定的数组任务
input_file="input_${SLURM_ARRAY_TASK_ID}.txt"
output_file="output_${SLURM_ARRAY_TASK_ID}.txt"

echo "Processing $input_file -> $output_file"
# 您的处理逻辑
./process_data.sh $input_file $output_file
```

## 作业管理命令

### 作业提交和监控
```bash
# 提交作业
sbatch job_script.sh

# 查看队列状态
squeue
squeue -u $USER
squeue -p cpu-queue
squeue -p gpu-queue

# 查看特定作业
squeue -j <job_id>

# 查看作业详细信息
scontrol show job <job_id>

# 查看节点信息
sinfo
sinfo -p cpu-queue
sinfo -p gpu-queue
scontrol show nodes
```

### 作业控制
```bash
# 取消作业
scancel <job_id>

# 取消用户的所有作业
scancel -u $USER

# 取消特定队列的作业
scancel -p cpu-queue -u $USER

# 暂停作业
scontrol hold <job_id>

# 恢复作业
scontrol release <job_id>

# 修改作业优先级
scontrol update job=<job_id> priority=1000
```

### 作业历史和统计
```bash
# 查看作业历史
sacct
sacct -u $USER
sacct -j <job_id>

# 详细的作业统计
sacct -j <job_id> --format=JobID,JobName,Partition,Account,AllocCPUS,State,ExitCode,Start,End,Elapsed,MaxRSS

# 查看作业效率
seff <job_id>
```

## 高级作业提交选项

### 资源约束和要求
```bash
# 指定多个约束条件
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl&efa" hellojob.sh

# 排除特定节点
sbatch -p cpu-queue --exclude=node001,node002 hellojob.sh

# 指定特定节点
sbatch -p cpu-queue --nodelist=node003,node004 hellojob.sh

# 最小/最大节点数
sbatch -p cpu-queue --nodes=2-4 --ntasks=32 hellojob.sh
```

### 时间和优先级
```bash
# 设置作业时间限制
sbatch -p cpu-queue --time=02:30:00 hellojob.sh  # 2小时30分钟
sbatch -p cpu-queue --time=1-12:00:00 hellojob.sh  # 1天12小时

# 设置作业优先级
sbatch -p cpu-queue --nice=100 hellojob.sh

# 设置作业依赖
sbatch -p cpu-queue --dependency=afterok:<job_id> hellojob.sh
```

### 通知和邮件
```bash
# 作业完成时发送邮件
sbatch -p cpu-queue --mail-type=END --mail-user=user@example.com hellojob.sh

# 多种通知类型
sbatch -p cpu-queue --mail-type=BEGIN,END,FAIL --mail-user=user@example.com hellojob.sh
```

## 特定应用场景

### 机器学习训练
```bash
# 单GPU训练
sbatch -p gpu-queue --constraint="gpu-nodes-g6e" --gres=gpu:1 --mem=32G train_model.sh

# 多GPU训练
sbatch -p gpu-queue --constraint="gpu-nodes-p4d" --gres=gpu:8 --ntasks=1 --cpus-per-task=32 train_distributed.sh

# 超参数调优（数组作业）
sbatch -p gpu-queue --constraint="gpu-nodes-g5" --gres=gpu:1 --array=1-50 hyperparameter_search.sh
```

### 科学计算
```bash
# 大内存计算
sbatch -p memory-queue --constraint="mem-nodes-r7i-16xl" --mem=400G large_memory_job.sh

# 高性能计算（HPC）
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-16xl&efa" --ntasks=128 --ntasks-per-node=16 hpc_simulation.sh

# 长时间运行的作业
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" --time=7-00:00:00 long_running_job.sh
```

### 数据处理
```bash
# 并行数据处理
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" --array=1-1000%20 process_data_chunk.sh

# I/O密集型作业
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-4xl" --mem=64G io_intensive_job.sh
```

## 监控和调试

### 实时监控
```bash
# 监控作业输出
tail -f slurm-<job_id>.out

# 监控资源使用
sstat -j <job_id> --format=AveCPU,AvePages,AveRSS,AveVMSize

# 监控GPU使用（在计算节点上）
watch -n 1 nvidia-smi
```

### 性能分析
```bash
# 查看作业性能统计
sacct -j <job_id> --format=JobID,MaxRSS,AveRSS,MaxVMSize,AveCPU,Elapsed,State

# 分析作业效率
seff <job_id>

# 查看节点负载
sinfo -o "%20N %10c %10m %25f %10G"
```

## 最佳实践

### 1. 资源估算
```bash
# 先用小规模测试
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-2xl" --time=00:10:00 test_job.sh

# 根据测试结果调整资源
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" --time=02:00:00 production_job.sh
```

### 2. 错误处理
```bash
# 设置重试机制
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-4xl" --requeue retry_job.sh

# 检查点和恢复
sbatch -p gpu-queue --constraint="gpu-nodes-g6e" --signal=SIGUSR1@60 checkpoint_job.sh
```

### 3. 成本优化
```bash
# 使用较小的实例进行开发
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-2xl" dev_job.sh

# 生产环境使用合适的实例
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-16xl" production_job.sh
```

这个参考指南涵盖了SLURM作业处理的各个方面，您可以根据具体需求选择合适的命令和配置。
