#!/bin/bash
sudo apt-get update
sudo apt-get install iptables-persistent
# 函数：添加端口转发规则
add_forwarding_rule() {
    echo "请输入宿主机的IP地址:"
    read -r host_ip
    
    echo "请输入宿主机的端口:"
    read -r host_port
    
    echo "请输入内网IP地址:"
    read -r internal_ip
    
    echo "请输入内网端口:"
    read -r internal_port
    
    sudo iptables -t nat -A PREROUTING -p tcp --dport "$host_port" -j DNAT --to-destination "$internal_ip":"$internal_port"
    sudo iptables -t nat -A POSTROUTING -p tcp -d "$internal_ip" --dport "$internal_port" -j SNAT --to-source "$host_ip"
    
    # 保存规则到持久规则文件
    sudo iptables-save | sudo tee /etc/iptables/rules.v4 >/dev/null
    
    echo "已成功添加端口转发规则：$host_port -> $internal_ip:$internal_port"
}

# 函数：删除端口转发规则
delete_forwarding_rule() {
    echo "请输入宿主机的IP地址:"
    read -r host_ip
    
    echo "请输入宿主机的端口:"
    read -r host_port
    
    echo "请输入内网IP地址:"
    read -r internal_ip
    
    echo "请输入内网端口:"
    read -r internal_port
    
    sudo iptables -t nat -D PREROUTING -p tcp --dport "$host_port" -j DNAT --to-destination "$internal_ip":"$internal_port"
    sudo iptables -t nat -D POSTROUTING -p tcp -d "$internal_ip" --dport "$internal_port" -j SNAT --to-source "$host_ip"
    
    echo "已成功删除端口转发规则：$host_port -> $internal_ip:$internal_port"
}

# 函数：列出已添加的端口转发规则
list_forwarding_rules() {
    sudo iptables -t nat -L PREROUTING --line-numbers
}

# 主程序
# 加载持久规则文件
sudo iptables-restore < /etc/iptables/rules.v4

while true; do
    echo "请选择要执行的操作:"
    echo "1. 添加端口转发规则"
    echo "2. 删除端口转发规则"
    echo "3. 查看已添加的端口转发规则"
    echo "4. 退出"
    read -r choice
    
    case $choice in
        1)
            add_forwarding_rule
            ;;
        2)
            delete_forwarding_rule
            ;;
        3)
            list_forwarding_rules
            ;;
        4)
            echo "已退出脚本."
            break
            ;;
        *)
            echo "无效的选项，请重新选择."
            ;;
    esac
    
    echo
done
