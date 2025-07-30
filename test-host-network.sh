#!/bin/bash

echo "=== Host 网络模式测试脚本 ==="
echo ""

# 检查容器运行状态
echo "1. 检查容器状态..."
docker-compose -f docker-compose.legacy.yml ps
echo ""

# 检查宿主机端口占用
echo "2. 检查关键端口占用情况（9000+ 范围）..."
echo "MongoDB (9017):"
netstat -ln | grep :9017 || echo "   ❌ 端口 9017 未被占用"
echo "Meilisearch (9700):"
netstat -ln | grep :9700 || echo "   ❌ 端口 9700 未被占用"
echo "RAG API (${RAG_PORT:-9001}):"
netstat -ln | grep :${RAG_PORT:-9001} || echo "   ❌ 端口 ${RAG_PORT:-9001} 未被占用"
echo "LibreChat API (${PORT:-9080}):"
netstat -ln | grep :${PORT:-9080} || echo "   ❌ 端口 ${PORT:-9080} 未被占用"
echo "PostgreSQL (9432):"
netstat -ln | grep :9432 || echo "   ❌ 端口 9432 未被占用"
echo ""

# 测试本地服务连接
echo "3. 测试本地服务连接（9000+ 端口）..."
echo "测试 MongoDB:"
curl -s --connect-timeout 3 http://localhost:9017 > /dev/null && echo "   ✅ MongoDB 响应正常" || echo "   ❌ MongoDB 连接失败"

echo "测试 Meilisearch:"
curl -s --connect-timeout 3 http://localhost:9700/health > /dev/null && echo "   ✅ Meilisearch 响应正常" || echo "   ❌ Meilisearch 连接失败"

echo "测试 RAG API:"
curl -s --connect-timeout 3 http://localhost:${RAG_PORT:-9001}/health > /dev/null && echo "   ✅ RAG API 响应正常" || echo "   ❌ RAG API 连接失败"

echo "测试 LibreChat API:"
curl -s --connect-timeout 3 http://localhost:${PORT:-9080} > /dev/null && echo "   ✅ LibreChat API 响应正常" || echo "   ❌ LibreChat API 连接失败"
echo ""

# 检查容器网络模式
echo "4. 验证容器网络模式..."
for container in LibreChat chat-mongodb chat-meilisearch vectordb rag_api; do
    if docker inspect $container 2>/dev/null | grep -q '"NetworkMode": "host"'; then
        echo "   ✅ $container: host 网络模式"
    else
        echo "   ❌ $container: 非 host 网络模式或容器未运行"
    fi
done
echo ""

# 显示容器日志（如果有错误）
echo "5. 检查容器日志中的网络相关错误..."
for container in LibreChat chat-mongodb chat-meilisearch vectordb rag_api; do
    if docker ps --format "table {{.Names}}" | grep -q $container; then
        echo "检查 $container 日志:"
        docker logs $container 2>&1 | tail -5 | grep -i -E "(error|fail|connection|network)" || echo "   无明显网络错误"
        echo ""
    fi
done

echo "Host 网络测试完成！"
echo ""
echo "如果所有服务都显示 ✅，说明 host 网络配置成功。"
echo "如果有 ❌，请检查："
echo "  1. 端口冲突（其他程序占用了相同端口）"
echo "  2. 防火墙设置"
echo "  3. 容器启动顺序"