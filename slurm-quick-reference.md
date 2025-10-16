# SLURM 快速参考卡片

## 常用提交命令模板

### CPU作业
```bash
# 小型CPU作业
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-2xl" --ntasks=4 --mem=16G --time=01:00:00 job.sh

# 中型CPU作业  
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" --ntasks=16 --mem=64G --time=04:00:00 job.sh

# 大型CPU作业
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-16xl" --ntasks=32 --mem=128G --time=12:00:00 job.sh
```

### GPU作业
```bash
# 单GPU训练
sbatch -p gpu-queue --constraint="gpu-nodes-g6e" --gres=gpu:1 --cpus-per-task=8 --mem=32G job.sh

# 多GPU训练
sbatch -p gpu-queue --constraint="gpu-nodes-p4d" --gres=gpu:8 --cpus-per-task=32 --mem=200G job.sh

# GPU推理
sbatch -p gpu-queue --constraint="gpu-nodes-g5" --gres=gpu:1 --cpus-per-task=4 --mem=16G job.sh
```

### 内存密集型作业
```bash
# 大内存作业
sbatch -p memory-queue --constraint="mem-nodes-r7i-8xl" --mem=200G --time=06:00:00 job.sh

# 超大内存作业
sbatch -p memory-queue --constraint="mem-nodes-r7i-16xl" --mem=400G --time=12:00:00 job.sh
```

## 作业管理命令

```bash
# 查看队列
squeue                    # 所有作业
squeue -u $USER          # 我的作业
squeue -p cpu-queue      # 特定队列

# 作业控制
scancel <job_id>         # 取消作业
scancel -u $USER         # 取消我的所有作业
scontrol hold <job_id>   # 暂停作业
scontrol release <job_id> # 恢复作业

# 查看信息
sinfo                    # 节点信息
scontrol show job <id>   # 作业详情
sacct -j <job_id>        # 作业历史
```

## 约束条件速查

| 实例类型 | 约束条件 | 适用场景 |
|---------|----------|----------|
| c7i.2xlarge | `cpu-nodes-c7i-2xl` | 轻量计算 |
| c7i.4xlarge | `cpu-nodes-c7i-4xl` | 中等计算 |
| c7i.8xlarge | `cpu-nodes-c7i-8xl` | 高性能计算 |
| c7i.16xlarge | `cpu-nodes-c7i-16xl` | 大规模并行 |
| g5.* | `gpu-nodes-g5` | GPU推理 |
| g6e.* | `gpu-nodes-g6e` | GPU训练 |
| p4d.* | `gpu-nodes-p4d` | 高端GPU训练 |
| p5.* | `gpu-nodes-p5` | 最新GPU训练 |
| r7i.* | `mem-nodes-r7i-*` | 大内存计算 |

## 时间格式

```bash
--time=30              # 30分钟
--time=01:30:00        # 1小时30分钟
--time=1-12:00:00      # 1天12小时
--time=7-00:00:00      # 7天
```

## 常用参数组合

```bash
# 交互式作业
srun -p cpu-queue --constraint="cpu-nodes-c7i-4xl" --pty bash

# 快速测试
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-2xl" --time=00:10:00 --wrap="echo test"

# 数组作业
sbatch -p cpu-queue --array=1-100%10 --time=01:00:00 array_job.sh

# 依赖作业
sbatch --dependency=afterok:12345 next_job.sh
```

这个参考指南涵盖了您在ParallelCluster上使用SLURM时最常用的参数和命令组合。
