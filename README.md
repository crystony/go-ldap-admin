## Go Ldap Admin
fork from https://github.com/opsre/go-ldap-admin

### 主要改动：
1. 添加 postgres 数据库支持
2. 系统启动时，初始化 ldap 默认 root
3. ui 支持修改 api 路径。需要修改前端配置文件 config.js 中的 BASE_API，默认是 /
4. ui 静态资源改为相对路径
5. api 默认路径 /ldap-admin/api

### docker 镜像
1. 地址：[cnxc/go-ldap-admin](https://hub.docker.com/r/cnxc/go-ldap-admin)
2. 构建脚本
```shell
docker buildx build -t "cnxc/go-ldap-admin:0.5.18_2025-04-02" --platform linux/amd64,linux/arm64 . --push
```
