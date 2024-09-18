#!/bin/bash

log_file="mint_log.txt"
success_count=0

if [ -z "$1" ]; then
    echo "未提供必要的参数。用法：$0 <最大费率>"
    exit 1
fi

echo "Minting Script Started at $(date)" | tee -a $log_file

while true; do
    feeRate=$(curl -s 'https://explorer.unisat.io/fractal-mainnet/api/bitcoin-info/fee' | jq -r '.data.fastestFee')
    # 检查 feeRate 是否为 null 或者不是数字
    if [ "$feeRate" == "null" ] || ! [[ "$feeRate" =~ ^[0-9]+$ ]]; then
        echo "获取的费率为 null 或非数字，跳过当前循环" | tee -a $log_file
        sleep 5
        continue
    fi

    # 增加100到feeRate
    feeRate=$(($feeRate + 100))

    echo "正在使用当前 $feeRate 费率进行 Mint" | tee -a $log_file

    if [ "$feeRate" -gt "$1" ]; then
        echo "费率超过 $1, 跳过当前循环" | tee -a $log_file
        sleep 20
        continue
    fi

    command="yarn cli mint -i cc1b4c7e844c8a7163e0fccb79a9ade20b0793a2e86647825b7c05e8002b9f6a_0 20 --fee-rate $feeRate"

    $command
    command_status=$?

    if [ $command_status -ne 0 ]; then
        echo "命令执行失败，退出循环" | tee -a $log_file
        exit 1
    else
        success_count=$((success_count + 1))
        echo "成功mint了 $success_count 次" | tee -a $log_file
    fi

done