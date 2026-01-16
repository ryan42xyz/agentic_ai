# DAPP 认证与路由机制分析文档

## 概述

DAPP系统采用基于JWT的认证机制和多集群路由架构，支持两种不同的请求处理模式。本文档详细分析了系统的认证流程、路由逻辑和集群管理机制。

## 1. 认证机制

### 1.1 JWT Token系统

**核心组件**: `JwtUtils` 类
- **密钥**: 使用固定密钥 "adtkls" 进行签名
- **算法**: HS256签名算法
- **有效期**: 36小时
- **载荷**: JWT ID为用户ID

**主要方法**:
```java
public String createJWT(String uuid)     // 创建JWT token
public boolean parseToken(String jwt)    // 验证token有效性
public String getUuid(String jwt)        // 从token提取用户ID
public String getCluster(String token)   // 从token获取集群信息
```

### 1.2 登录流程

**普通登录** (`UserServiceImpl.login`):
1. 验证用户名和密码
2. 检查用户状态
3. 生成JWT token (用户ID作为JWT ID)
4. 缓存用户信息到 `DappCache.UserCache`
5. 返回token给客户端

**Google OAuth登录** (`UserServiceImpl.googleLogin`):
1. 验证Google access token
2. 获取用户邮箱信息
3. 自动创建或查找用户
4. 生成JWT token并缓存用户信息

### 1.3 请求头要求

- **X-TOKEN**: JWT认证token
- **cluster**: 指定目标集群名称

## 2. 路由架构

### 2.1 Spring Cloud Gateway配置

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: infra-dev
          uri: no://op
          predicates:
            - Path=/api/**
```

### 2.2 两种路由模式

#### 模式1: GlobalFilter 智能转发

**适用场景**: `/api/**` 路径的请求
**处理流程**:

1. **路径转换**: `/api/xxx` → `/xxx`
2. **认证验证**:
   - 检查 `X-TOKEN` header
   - 验证JWT token有效性
   - 提取用户信息并添加到请求头
3. **集群路由**:
   - 优先使用token中的集群信息
   - 其次使用header中的 `cluster` 参数
   - 最后使用默认集群
4. **请求转发**: 转发到目标集群的相应端点

**认证规则**:
- `/api` 开头的请求**必须**携带有效的 `X-TOKEN`
- 非 `/api` 开头的请求通常不需要token
- 登录相关路径 (`/user/login`, `/user/google/login`) 例外

#### 模式2: Management批量处理

**适用场景**: 需要跨集群操作的管理功能
**典型示例**: Template更新操作

```java
// 获取所有存活集群
List<ClusterEntity> list = clusterRepository.getByStatus("alive");
for (ClusterEntity clusterEntity : list) {
    // 向每个集群发送更新请求
    CommonResponse commonResponse = HttpRequest.sendPostRequestToDapp(
        clusterEntity.getProtocol() + "://"
        + clusterEntity.getHost() + ":" + clusterEntity.getPort()
        + "/app/update-template", record, "token", cluster);
}
```

### 2.3 本地过滤器 (LocalFilter)

**作用**: 判断哪些API需要在本地处理，避免不必要的跨集群调用

**本地处理的路径**:
- `central` - 中央管理功能
- `menu`, `role`, `user` - 用户管理
- `chart`, `template` - 模板管理
- `global`, `traffic` - 全局配置
- `cluster`, `node` - 集群管理
- 其他管理功能路径

## 3. 核心组件详解

### 3.1 GlobalFilter类

**职责**: 
- JWT token验证
- 用户信息缓存
- 集群路由决策
- 请求转发

**关键逻辑**:
```java
// 1. 路径处理
String newPath = path.replaceAll("/api/", "/");

// 2. Token验证
if (req.getHeaders().containsKey("X-TOKEN")) {
    String token = req.getHeaders().get("X-TOKEN").get(0);
    if (!jwtUtils.parseToken(token)) {
        newPath = "/central/invalid-token";
    }
}

// 3. 集群路由
if (req.getHeaders().containsKey("cluster")) {
    cluster = DappCache.ClustersCache.getIfPresent(
        req.getHeaders().get("cluster").get(0));
}

// 4. 本地过滤
if (localFilter(newPath)) {
    cluster = DappCache.ClustersCache.getIfPresent(DappCache.cluster);
}
```

### 3.2 缓存机制

**DappCache组件**:
- `UserCache`: 缓存用户信息 (用户ID → 用户详情)
- `ClustersCache`: 缓存集群信息
- `dappUserCache`: 缓存集群间的认证token

## 4. 请求示例分析

### 4.1 API请求示例

```bash
curl 'https://dapp-central.dv-api.com/api/request/requested/list/global' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'cluster: aws-uswest2-mgt-a'
```

**处理流程**:
1. 匹配 `/api/**` 路由规则
2. GlobalFilter处理:
   - 路径转换: `/api/request/requested/list/global` → `/request/requested/list/global`
   - 集群路由: 根据 `cluster: aws-uswest2-mgt-a` 路由到指定集群
   - 由于包含 `global`，通过localFilter判定为本地处理
3. 转发到本地集群处理

### 4.2 Template更新示例

```java
// 模式2: 批量更新所有集群的template
@PostMapping("/app/update-template")
public CommonResponse updateTemplate(@RequestBody DeployTemplateEntity record) {
    // 1. 本地保存template
    // 2. 获取所有存活集群
    // 3. 向每个集群发送更新请求
}
```

## 5. 安全机制

### 5.1 Token安全
- JWT签名验证
- Token过期检查 (36小时)
- 用户状态验证
- 缓存机制提高性能

### 5.2 路由安全
- 集群白名单验证
- 本地过滤防止不当转发
- 认证token在集群间传递

## 6. 系统特点

### 6.1 优势
1. **透明路由**: 客户端无需关心具体集群位置
2. **批量操作**: 支持一次操作影响多个集群
3. **缓存优化**: 减少重复的数据库查询和验证
4. **灵活路由**: 支持基于token和header的动态路由

### 6.2 架构模式
- **API Gateway模式**: 统一入口和路由
- **微服务架构**: 支持多集群分布式部署
- **缓存策略**: 提高认证和路由性能
- **异步处理**: 批量操作使用异步执行

## 7. 配置要点

### 7.1 关键配置
- JWT密钥配置
- 集群信息配置
- Gateway路由规则
- 缓存策略配置

### 7.2 运维考虑
- 集群健康检查
- Token过期处理
- 缓存清理策略
- 跨集群网络连通性

---

**文档版本**: v1.0  
**创建日期**: 2025-09-25  
**适用版本**: DAPP当前版本
