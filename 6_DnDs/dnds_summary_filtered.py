#!/usr/bin/env python3
"""
修正的codeml结果解析脚本
"""
import os
import re
import pandas as pd
import numpy as np
from scipy.stats import chi2

def parse_codeml_file_corrected(file_path):
    """修正的解析函数"""
    results = {
        'gene': os.path.basename(file_path).replace('_output.txt', ''),
        'm0_omega': np.nan,
        'm0_lnl': np.nan,
        'm1a_lnl': np.nan,
        'm2a_lnl': np.nan,
        'lrt_stat': np.nan,
        'lrt_pvalue': np.nan,
        'positive_sites': 0,
        'status': '失败'
    }
    
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        if not content.strip():
            return results
        
        # 提取M0 omega值 - 修正模式
        m0_omega_match = re.search(r'omega \(dN/dS\)\s*=\s*([\d.]+)', content)
        if m0_omega_match:
            results['m0_omega'] = float(m0_omega_match.group(1))
        
        # 提取所有lnL值 - 使用更精确的模式
        lnl_pattern = r'lnL\(ntime:\s*\d+\s+np:\s*\d+\):\s*([-]?\d+\.\d+)'
        lnl_matches = re.findall(lnl_pattern, content)
        
        # 按照模型顺序提取lnL值
        if len(lnl_matches) >= 3:
            results['m0_lnl'] = float(lnl_matches[0])  # 第一个是M0
            results['m1a_lnl'] = float(lnl_matches[1])  # 第二个是M1a
            results['m2a_lnl'] = float(lnl_matches[2])  # 第三个是M2a
        
        # 计算LRT检验 (M1a vs M2a)
        if (not np.isnan(results['m1a_lnl']) and 
            not np.isnan(results['m2a_lnl']) and
            results['m2a_lnl'] > results['m1a_lnl']):  # 确保M2a似然值大于M1a
            
            lrt_stat = 2 * (results['m2a_lnl'] - results['m1a_lnl'])
            if lrt_stat >= 0:
                results['lrt_stat'] = lrt_stat
                results['lrt_pvalue'] = chi2.sf(lrt_stat, 2)  # 2个自由度
        
        # 提取正选择位点 - 从BEB分析中
        # 查找BEB分析部分的正选择位点 (*: P>95%; **: P>99%)
        beb_section = re.search(r'Bayes Empirical Bayes.*?(?=\n\n|\Z)', content, re.DOTALL)
        if beb_section:
            beb_content = beb_section.group(0)
            # 计算Pr(w>1) > 0.95的位点数量
            positive_pattern = r'(\d+)\s+[A-Z]\s+(\d\.\d{3})\*?\*?'
            positive_matches = re.findall(positive_pattern, beb_content)
            
            # 筛选P>0.95的位点
            significant_sites = [site for site, prob in positive_matches if float(prob) > 0.95]
            results['positive_sites'] = len(significant_sites)
        
        results['status'] = '成功'
        
    except Exception as e:
        results['status'] = f'解析错误: {str(e)}'
        print(f"解析错误 {file_path}: {e}")
    
    return results

# 解析所有结果文件
print("=== 开始解析codeml结果文件 ===")
all_results = []
results_dir = "codeml_parallel_results"

for file_name in os.listdir(results_dir):
    if file_name.endswith('_output.txt'):
        file_path = os.path.join(results_dir, file_name)
        result = parse_codeml_file_corrected(file_path)
        all_results.append(result)

# 创建DataFrame
df = pd.DataFrame(all_results)

# 添加分类信息
df['selection_type'] = pd.cut(df['m0_omega'], 
                             bins=[-np.inf, 0.5, 0.9, 1.1, 20.0, np.inf],
                             labels=['Purifying', 'Relaxed', 'Neutral', 'Positive', 'WrongPositive'])

# 保存结果
output_file = 'corrected_dnds_analysis.csv'
df.to_csv(output_file, index=False, float_format='%.6f')

# 生成统计报告
print("\n=== 分析结果统计 ===")
print(f"总基因数: {len(df)}")
success_count = len(df[df['status'] == '成功'])
print(f"成功解析: {success_count}")
print(f"失败解析: {len(df) - success_count}")

print("\n选择类型分布:")
print(df['selection_type'].value_counts())

print("\ndN/dS值统计:")
print(df['m0_omega'].describe())

# LRT检验结果分析
valid_lrt = df[~np.isnan(df['lrt_pvalue'])]
print(f"\n有效LRT检验数: {len(valid_lrt)}")

if len(valid_lrt) > 0:
    significant_genes = valid_lrt[valid_lrt['lrt_pvalue'] < 0.05]
    print(f"显著正选择基因数 (p < 0.05): {len(significant_genes)}")
    
    if len(significant_genes) > 0:
        print("\n显著正选择基因:")
        for idx, row in significant_genes.iterrows():
            print(f"  {row['gene']}: p-value = {row['lrt_pvalue']:.6f}, "
                  f"正选择位点数 = {row['positive_sites']}")

print(f"\n结果已保存到: {output_file}")

# 检查示例基因的结果
sample_gene = "evm_model_Chr1_100"  # 用您实际的基因名
sample_result = df[df['gene'] == sample_gene]
if not sample_result.empty:
    print(f"\n示例基因 {sample_gene} 的结果:")
    print(f"  M0 omega: {sample_result.iloc[0]['m0_omega']}")
    print(f"  M0 lnL: {sample_result.iloc[0]['m0_lnl']}")
    print(f"  M1a lnL: {sample_result.iloc[0]['m1a_lnl']}")
    print(f"  M2a lnL: {sample_result.iloc[0]['m2a_lnl']}")
    print(f"  LRT统计量: {sample_result.iloc[0]['lrt_stat']}")
    print(f"  LRT p值: {sample_result.iloc[0]['lrt_pvalue']}")
    print(f"  正选择位点数: {sample_result.iloc[0]['positive_sites']}")