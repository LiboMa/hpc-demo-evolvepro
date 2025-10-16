# SLURM 参数使用说明

## 基本作业提交格式

```bash
sbatch [选项] 脚本文件
sbatch [选项] --wrap="命令"
```

## 队列和约束参数

### 指定队列 (-p, --partition)
```bash
sbatch -p cpu-queue hellojob.sh
sbatch -p gpu-queue hellojob.sh
sbatch -p memory-queue hellojob.sh
```

### 指定节点约束 (--constraint)
```bash
# CPU节点约束
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-2xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-4xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-16xl" hellojob.sh

# GPU节点约束
sbatch -p gpu-queue --constraint="gpu-nodes-g5" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-g6e" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p4d" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p5" hellojob.sh

# 内存优化节点约束
sbatch -p memory-queue --constraint="mem-nodes-r7i-2xl" hellojob.sh
sbatch -p memory-queue --constraint="mem-nodes-r7i-8xl" hellojob.sh
sbatch -p memory-queue --constraint="mem-nodes-r7i-16xl" hellojob.sh
```

### 组合约束条件
```bash
# 多个约束条件（AND）
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl&efa" hellojob.sh

# 可选约束条件（OR）
sbatch -p gpu-queue --constraint="gpu-nodes-g6e|gpu-nodes-p4d" hellojob.sh
```

## 资源分配参数

### CPU资源
```bash
# 指定任务数
sbatch --ntasks=16 hellojob.sh

# 指定每个任务的CPU数
sbatch --cpus-per-task=4 hellojob.sh

# 指定节点数
sbatch --nodes=2 hellojob.sh

# 指定每个节点的任务数
sbatch --ntasks-per-node=8 hellojob.sh
```

### 内存资源
```bash
# 指定总内存
sbatch --mem=32G hellojob.sh

# 指定每个CPU的内存
sbatch --mem-per-cpu=2G hellojob.sh

# 指定每个任务的内存
sbatch --mem-per-task=4G hellojob.sh
```

### GPU资源
```bash
# 指定GPU数量
sbatch --gres=gpu:1 hellojob.sh
sbatch --gres=gpu:2 hellojob.sh
sbatch --gres=gpu:8 hellojob.sh

# 指定特定GPU类型
sbatch --gres=gpu:a100:2 hellojob.sh
sbatch --gres=gpu:v100:4 hellojob.sh
```

## 时间和优先级参数

### 时间限制
```bash
# 分钟格式
sbatch --time=30 hellojob.sh

# 小时:分钟格式
sbatch --time=02:30 hellojob.sh

# 天-小时:分钟:秒格式
sbatch --time=1-12:30:00 hellojob.sh

# 常用时间设置
sbatch --time=00:30:00 hellojob.sh  # 30分钟
sbatch --time=02:00:00 hellojob.sh  # 2小时
sbatch --time=1-00:00:00 hellojob.sh  # 1天
```

### 优先级和调度
```bash
# 设置优先级
sbatch --nice=100 hellojob.sh

# 设置QOS
sbatch --qos=high hellojob.sh
```

## 节点选择参数

### 指定/排除节点
```bash
# 指定特定节点
sbatch --nodelist=node001,node002 hellojob.sh

# 排除特定节点
sbatch --exclude=node003,node004 hellojob.sh

# 节点数量范围
sbatch --nodes=2-4 hellojob.sh
```

## 作业依赖参数

```bash
# 等待指定作业完成
sbatch --dependency=afterok:12345 hellojob.sh

# 等待多个作业完成
sbatch --dependency=afterok:12345:12346 hellojob.sh

# 等待作业开始后
sbatch --dependency=after:12345 hellojob.sh

# 等待作业失败后
sbatch --dependency=afternotok:12345 hellojob.sh
```

## 输出和通知参数

### 输出文件
```bash
# 指定输出文件
sbatch --output=job-%j.out hellojob.sh

# 指定错误文件
sbatch --error=job-%j.err hellojob.sh

# 合并输出和错误
sbatch --output=job-%j.log --error=job-%j.log hellojob.sh
```

### 邮件通知
```bash
# 作业结束时通知
sbatch --mail-type=END --mail-user=user@example.com hellojob.sh

# 多种通知类型
sbatch --mail-type=BEGIN,END,FAIL --mail-user=user@example.com hellojob.sh
```

## 数组作业参数

```bash
# 基本数组作业
sbatch --array=1-100 hellojob.sh

# 限制并发数量
sbatch --array=1-1000%20 hellojob.sh  # 最多同时运行20个

# 指定特定索引
sbatch --array=1,5,10-20 hellojob.sh
```

## 实际使用示例

### CPU密集型作业
```bash
sbatch -p cpu-queue \
       --constraint="cpu-nodes-c7i-8xl" \
       --ntasks=16 \
       --cpus-per-task=2 \
       --mem=64G \
       --time=02:00:00 \
       cpu_job.sh
```

### GPU训练作业
```bash
sbatch -p gpu-queue \
       --constraint="gpu-nodes-g6e" \
       --gres=gpu:1 \
       --cpus-per-task=8 \
       --mem=32G \
       --time=04:00:00 \
       train_model.sh
```

### 大内存作业
```bash
sbatch -p memory-queue \
       --constraint="mem-nodes-r7i-16xl" \
       --ntasks=1 \
       --mem=400G \
       --time=06:00:00 \
       big_memory_job.sh
```

### MPI并行作业
```bash
sbatch -p cpu-queue \
       --constraint="cpu-nodes-c7i-16xl" \
       --ntasks=64 \
       --ntasks-per-node=16 \
       --mem-per-cpu=2G \
       --time=03:00:00 \
       mpi_job.sh
```

### 多GPU分布式训练
```bash
sbatch -p gpu-queue \
       --constraint="gpu-nodes-p4d" \
       --gres=gpu:8 \
       --ntasks=1 \
       --cpus-per-task=32 \
       --mem=200G \
       --time=12:00:00 \
       distributed_training.sh
```

### 超参数调优数组作业
```bash
sbatch -p gpu-queue \
       --constraint="gpu-nodes-g5" \
       --gres=gpu:1 \
       --array=1-50%5 \
       --cpus-per-task=4 \
       --mem=16G \
       --time=01:00:00 \
       hyperparameter_search.sh
```

## 作业脚本内的SBATCH指令

```bash
#!/bin/bash
#SBATCH --job-name=my-job
#SBATCH --partition=cpu-queue
#SBATCH --constraint=cpu-nodes-c7i-8xl
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=job-%j.out
#SBATCH --error=job-%j.err

# 作业内容
echo "Job started on $(hostname)"
# 您的计算任务...
```

## 常用环境变量

作业运行时可用的环境变量：
- `$SLURM_JOB_ID` - 作业ID
- `$SLURM_JOB_NAME` - 作业名称
- `$SLURM_NTASKS` - 总任务数
- `$SLURM_CPUS_PER_TASK` - 每任务CPU数
- `$SLURM_JOB_NODELIST` - 节点列表
- `$SLURM_ARRAY_TASK_ID` - 数组作业索引
- `$CUDA_VISIBLE_DEVICES` - 可见GPU设备

这些参数可以灵活组合使用，根据您的具体计算需求选择合适的配置。
