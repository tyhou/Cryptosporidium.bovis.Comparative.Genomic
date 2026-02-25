#!/bin/bash
# codeml_analysis_parallel.sh - 支持后台和多线程运行

# 设置工作目录
CDS_DIR="cleaned_cds"
OUTPUT_DIR="codeml_parallel_results"
TREE_FILE="all_hap_23bov_filter_maf0.05_mis0.9.recode.min4.treefile"
LOG_FILE="codeml_analysis.log"
MAX_JOBS=48  # 同时运行的任务数，根据CPU核心数调整

# 创建输出目录
mkdir -p $OUTPUT_DIR

# 检查依赖
if ! command -v codeml &> /dev/null; then
    echo "错误: codeml 未安装!" | tee -a $LOG_FILE
    exit 1
fi

if [ ! -f "$TREE_FILE" ]; then
    echo "错误: 树文件 $TREE_FILE 不存在!" | tee -a $LOG_FILE
    exit 1
fi

if [ ! -d "$CDS_DIR" ]; then
    echo "错误: CDS目录 $CDS_DIR 不存在!" | tee -a $LOG_FILE
    exit 1
fi

# 获取FASTA文件列表
FASTA_FILES=($CDS_DIR/*.fasta)
if [ ${#FASTA_FILES[@]} -eq 0 ]; then
    echo "错误: 在 $CDS_DIR 目录下没有找到.fasta文件!" | tee -a $LOG_FILE
    exit 1
fi

echo "找到 ${#FASTA_FILES[@]} 个FASTA文件" | tee -a $LOG_FILE
echo "开始时间: $(date)" | tee -a $LOG_FILE

# 作业计数器
JOB_COUNT=0

# 处理每个基因的函数
process_gene() {
    local GENE_FILE=$1
    local GENE_NAME=$(basename "$GENE_FILE" .fasta)
    
    echo "$(date): 开始处理 $GENE_NAME" | tee -a $LOG_FILE
    
    # 检查序列文件
    if [ ! -s "$GENE_FILE" ]; then
        echo "$(date): 警告: $GENE_FILE 为空或不存在，跳过" | tee -a $LOG_FILE
        return 1
    fi
    
    # 创建控制文件
    local CTL_FILE="codeml_${GENE_NAME}.ctl"
    
    cat > "$CTL_FILE" << EOF
      seqfile = $GENE_FILE
      treefile = $TREE_FILE
      outfile = $OUTPUT_DIR/${GENE_NAME}_output.txt
      noisy = 9
      verbose = 0  # 减少输出
      runmode = 0
      seqtype = 1
      CodonFreq = 2
      clock = 0
      aaDist = 0
      model = 0
      NSsites = 0 1 2
      icode = 0
      fix_kappa = 0
      kappa = 2
      fix_omega = 0
      omega = 1
      cleandata = 1
EOF
    
    # 运行codeml（非交互式）
    echo "" | codeml "$CTL_FILE" > "$OUTPUT_DIR/${GENE_NAME}_log.txt" 2>&1
    
    local EXIT_CODE=$?
    
    # 清理临时文件
    rm -f "$CTL_FILE" 2>/dev/null
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "$(date): 完成: $GENE_NAME" | tee -a $LOG_FILE
    else
        echo "$(date): 失败: $GENE_NAME (退出码: $EXIT_CODE)" | tee -a $LOG_FILE
    fi
    
    return $EXIT_CODE
}

# 导出函数以便在子shell中使用
export -f process_gene
export CDS_DIR OUTPUT_DIR TREE_FILE LOG_FILE

# 使用GNU Parallel进行并行处理（如果可用）
if command -v parallel &> /dev/null; then
    echo "使用GNU Parallel进行并行处理..." | tee -a $LOG_FILE
    printf "%s\n" "${FASTA_FILES[@]}" | parallel -j $MAX_JOBS --progress --joblog parallel_joblog.txt \
        'process_gene {}'
    
else
    echo "使用内置并行处理..." | tee -a $LOG_FILE
    
    # 简单的并行处理实现
    for GENE_FILE in "${FASTA_FILES[@]}"; do
        # 如果正在运行的任务数达到最大值，等待
        while [ $(jobs -r | wc -l) -ge $MAX_JOBS ]; do
            sleep 1
        done
        
        # 在后台运行任务
        process_gene "$GENE_FILE" &
        
        JOB_COUNT=$((JOB_COUNT + 1))
        if [ $((JOB_COUNT % 10)) -eq 0 ]; then
            echo "$(date): 已提交 $JOB_COUNT 个任务" | tee -a $LOG_FILE
        fi
    done
    
    # 等待所有后台任务完成
    echo "$(date): 等待所有任务完成..." | tee -a $LOG_FILE
    wait
fi

echo "========================================" | tee -a $LOG_FILE
echo "所有基因处理完成!" | tee -a $LOG_FILE
echo "完成时间: $(date)" | tee -a $LOG_FILE
echo "结果保存在: $OUTPUT_DIR" | tee -a $LOG_FILE
echo "日志文件: $LOG_FILE" | tee -a $LOG_FILE
echo "========================================" | tee -a $LOG_FILE

# 生成统计报告
echo "=== 运行统计 ===" | tee -a $LOG_FILE
echo "总任务数: ${#FASTA_FILES[@]}" | tee -a $LOG_FILE
echo "成功任务数: $(ls -1 $OUTPUT_DIR/*_output.txt 2>/dev/null | wc -l)" | tee -a $LOG_FILE
echo "失败任务数: $(grep -c "失败" $LOG_FILE 2>/dev/null)" | tee -a $LOG_FILE