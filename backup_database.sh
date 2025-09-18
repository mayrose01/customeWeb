#!/bin/bash

# 数据库备份脚本
# 用于定期备份开发环境和生产环境数据库

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BACKUP_DIR="/Users/huangqing/enterprise/backups"
DEV_DB="enterprise_dev"
PROD_SERVER="catusfoto.top"
PROD_DB="enterprise_prod"
SSH_KEY="/Users/huangqing/enterprise/enterprise_prod.pem"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 创建备份目录
create_backup_dir() {
    log_step "创建备份目录..."
    mkdir -p "$BACKUP_DIR"
    log_info "备份目录: $BACKUP_DIR"
}

# 备份开发环境数据库
backup_dev_database() {
    log_step "备份开发环境数据库..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/dev_backup_$timestamp.sql"
    
    mysqldump -u root -proot "$DEV_DB" > "$backup_file"
    
    if [ $? -eq 0 ]; then
        log_info "开发环境备份成功: $backup_file"
        # 压缩备份文件
        gzip "$backup_file"
        log_info "备份文件已压缩: ${backup_file}.gz"
    else
        log_error "开发环境备份失败"
        return 1
    fi
}

# 备份生产环境数据库
backup_prod_database() {
    log_step "备份生产环境数据库..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/prod_backup_$timestamp.sql"
    
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$PROD_SERVER "mysqldump -u root -proot $PROD_DB" > "$backup_file"
    
    if [ $? -eq 0 ]; then
        log_info "生产环境备份成功: $backup_file"
        # 压缩备份文件
        gzip "$backup_file"
        log_info "备份文件已压缩: ${backup_file}.gz"
    else
        log_error "生产环境备份失败"
        return 1
    fi
}

# 清理旧备份文件（保留最近7天）
cleanup_old_backups() {
    log_step "清理旧备份文件..."
    
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete
    
    log_info "已清理7天前的备份文件"
}

# 显示备份统计
show_backup_stats() {
    log_step "备份统计..."
    
    local dev_count=$(find "$BACKUP_DIR" -name "dev_backup_*.sql.gz" | wc -l)
    local prod_count=$(find "$BACKUP_DIR" -name "prod_backup_*.sql.gz" | wc -l)
    local total_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    
    echo "开发环境备份数量: $dev_count"
    echo "生产环境备份数量: $prod_count"
    echo "备份目录总大小: $total_size"
}

# 主函数
main() {
    log_info "开始数据库备份..."
    
    create_backup_dir
    backup_dev_database
    backup_prod_database
    cleanup_old_backups
    show_backup_stats
    
    log_info "数据库备份完成！"
}

# 检查参数
if [ "$1" = "--dev-only" ]; then
    log_info "仅备份开发环境..."
    create_backup_dir
    backup_dev_database
    show_backup_stats
elif [ "$1" = "--prod-only" ]; then
    log_info "仅备份生产环境..."
    create_backup_dir
    backup_prod_database
    show_backup_stats
else
    main
fi
