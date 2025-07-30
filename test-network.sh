#!/bin/bash

echo "=== Docker 网络连通性测试脚本 ==="
echo ""

# 检查容器运行状态
echo "1. 检查容器状态..."
docker-compose ps
echo ""

# 测试 API 到 MongoDB 的连接
echo "2. 测试 API -> MongoDB 连接..."
docker-compose exec api ping -c 2 mongodb || echo "❌ MongoDB 连接失败"
echo ""

# 测试 API 到 RAG API 的连接
echo "3. 测试 API -> RAG API 连接..."
docker-compose exec api ping -c 2 rag_api || echo "❌ RAG API 连接失败"
echo ""

# 测试 API 到 Meilisearch 的连接
echo "4. 测试 API -> Meilisearch 连接..."
docker-compose exec api ping -c 2 meilisearch || echo "❌ Meilisearch 连接失败"
echo ""

# 测试 RAG API 到 VectorDB 的连接
echo "5. 测试 RAG API -> VectorDB 连接..."
docker-compose exec rag_api ping -c 2 vectordb || echo "❌ VectorDB 连接失败"
echo ""

# 检查网络
echo "6. 检查 Docker 网络..."
docker network ls | grep librechat
echo ""

# 检查容器网络配置
echo "7. 检查容器网络详情..."
docker inspect $(docker-compose ps -q) | grep -A 10 "NetworkMode\|Networks" || echo "无法获取网络信息"
echo ""

echo "测试完成！"