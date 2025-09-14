#!/bin/bash

# 简单的进程管理脚本
# config.ini 例子
#[program]
#name = node_exporter
#exec_path = ./node_exporter
#args = --web.listen-address=:9100
#pid_file = /var/run/node_exporter.pid
#log_file = /var/log/node_exporter.log
#work_dir = /root/software/node_exporter
CONFIG_FILE="./config.ini"

# 显示帮助信息
show_help() {
    echo "Usage: $0 [OPTIONS] COMMAND"
    echo ""
    echo "Options:"
    echo "  -c, --config FILE    Configuration file path (default: ./config.ini)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Commands:"
    echo "  start     Start the program"
    echo "  stop      Stop the program"
    echo "  restart   Restart the program"
    echo "  status    Check program status"
    echo "  log       View program logs"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        start|stop|restart|status|log)
            COMMAND="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' not found!"
    exit 1
fi

# 读取配置项的函数
get_config() {
    local key="$1"
    # 使用grep和sed提取配置值
    grep -E "^[[:space:]]*${key}[[:space:]]*=" "$CONFIG_FILE" 2>/dev/null | \
        sed -e 's/^[^=]*=[[:space:]]*//' \
            -e 's/^[[:space:]]*//;s/[[:space:]]*$//' \
            -e 's/^"\|"$//g' \
            -e "s/^'\|'$//g"
}

# 从配置文件读取参数
PROG_NAME=$(get_config "name")
EXEC_PATH=$(get_config "exec_path")
ARGS=$(get_config "args")
PID_FILE=$(get_config "pid_file")
LOG_FILE=$(get_config "log_file")
USER=$(get_config "user")
WORK_DIR=$(get_config "work_dir")

# 如果没有配置work_dir，则使用脚本所在目录
if [ -z "$WORK_DIR" ]; then
    WORK_DIR="$(dirname "$(readlink -f "$0")")"
fi

# 检查必需参数
if [ -z "$PROG_NAME" ] || [ -z "$EXEC_PATH" ] || [ -z "$PID_FILE" ]; then
    echo "Error: Missing required parameters in config file"
    echo "Required: name, exec_path, pid_file"
    exit 1
fi

# 检查可执行文件
if [ ! -x "$EXEC_PATH" ]; then
    echo "Error: Executable '$EXEC_PATH' not found or not executable"
    exit 1
fi

# 创建日志目录（如果需要）
if [ -n "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null
fi

# 检查进程是否运行的函数
is_running() {
    if [ ! -f "$PID_FILE" ]; then
        return 1  # PID文件不存在
    fi

    local pid=$(cat "$PID_FILE" 2>/dev/null)
    if [ -z "$pid" ]; then
        return 1  # PID文件为空
    fi

    # 使用kill -0检查进程是否存在（更兼容）
    if kill -0 "$pid" 2>/dev/null; then
        return 0  # 进程正在运行
    else
        return 1  # 进程不存在
    fi
}

# 启动函数
start() {
    # 检查是否已经在运行
    if is_running; then
        echo "[$PROG_NAME] Already running (PID: $(cat "$PID_FILE"))"
        exit 0
    fi

    echo "[$PROG_NAME] Starting in directory: $WORK_DIR"

    # 构建命令
    local cmd="$EXEC_PATH"
    if [ -n "$ARGS" ]; then
        cmd="$cmd $ARGS"
    fi

    # 切换到工作目录
    cd "$WORK_DIR" || {
        echo "Error: Failed to change to working directory '$WORK_DIR'"
        exit 1
    }

    # 如果指定了用户，使用sudo
    if [ -n "$USER" ]; then
        # 使用sudo启动进程，并确保能正确获取PID
        if [ -n "$LOG_FILE" ]; then
            sudo -u "$USER" $cmd >> "$LOG_FILE" 2>&1 &
        else
            sudo -u "$USER" $cmd > /dev/null 2>&1 &
        fi
    else
        # 直接启动进程
        if [ -n "$LOG_FILE" ]; then
            $cmd >> "$LOG_FILE" 2>&1 &
        else
            $cmd > /dev/null 2>&1 &
        fi
    fi

    # 获取后台进程的PID
    local pid=$!

    # 等待一小段时间确保进程完全启动
    sleep 1

    # 验证进程是否成功启动
    if kill -0 $pid 2>/dev/null; then
        # 进程成功启动，写入PID文件
        echo $pid > "$PID_FILE"
        echo "[$PROG_NAME] Started successfully (PID: $pid)"
    else
        echo "[$PROG_NAME] Failed to start"
        rm -f "$PID_FILE" 2>/dev/null
        exit 1
    fi
}

# 停止函数
stop() {
    if ! is_running; then
        echo "[$PROG_NAME] Not running"
        exit 0
    fi

    local pid=$(cat "$PID_FILE")
    echo "[$PROG_NAME] Stopping (PID: $pid)..."

    kill $pid 2>/dev/null

    # 等待最多10秒
    local count=0
    while kill -0 $pid 2>/dev/null && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
    done

    # 如果进程仍然存在，强制杀死
    if kill -0 $pid 2>/dev/null; then
        echo "[$PROG_NAME] Force killing..."
        kill -9 $pid 2>/dev/null
        sleep 1
    fi

    rm -f "$PID_FILE"
    echo "[$PROG_NAME] Stopped successfully"
}

# 状态函数
status() {
    if is_running; then
        echo "[$PROG_NAME] Running (PID: $(cat "$PID_FILE"))"
        exit 0
    else
        echo "[$PROG_NAME] Not running"
        exit 1
    fi
}

# 日志查看函数
log() {
    if [ -z "$LOG_FILE" ]; then
        echo "Error: Log file not configured"
        exit 1
    fi

    if [ ! -f "$LOG_FILE" ]; then
        echo "Error: Log file '$LOG_FILE' not found"
        exit 1
    fi

    echo "[$PROG_NAME] Tailing log file: $LOG_FILE"
    tail -f "$LOG_FILE"
}

# 重启函数
restart() {
    stop
    start
}

# 执行命令
case "$COMMAND" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    log)
        log
        ;;
    *)
        echo "Error: No command specified"
        show_help
        exit 1
        ;;
esac
