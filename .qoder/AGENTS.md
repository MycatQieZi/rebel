# Project Agents Configuration

## Rebel - 叛逆者审视机制

### 项目级集成规则

当在本项目中进行编码时，主Agent应遵循以下规则来集成叛逆者机制:

### 微审视集成

每次完成编码任务后，主Agent应:

1. 读取 `.rebel/state.json` 获取当前状态
2. 将 `task_counter` 加 1
3. 执行快速检查（目标一致性、命名规范、导入整洁、安全风险）
4. 更新 `last_micro_audit` 时间戳
5. 如果发现异常，输出 `[Rebel Micro] WARN` 消息
6. 检查是否达到标准审视间隔（`task_counter >= standard_audit_interval`）

### 标准审视触发

当 `task_counter >= standard_audit_interval` 时:

1. 读取 `.rebel/config.yaml` 获取评估规则
2. 执行四大维度评估
3. 计算综合健康指数
4. 更新危机等级
5. 生成审视报告
6. 重置 `task_counter` 为 0
7. 保存审视记录到 `.rebel/audit-history/`
8. 更新 `.rebel/state.json` 和 `.rebel/health-trends.json`

### 手动触发

用户可通过以下命令触发:

- `/rebel` - 执行标准审视
- `/rebel --deep` - 执行深度审视
- `/rebel --status` - 查看项目健康状态
- `/rebel --coup` - 手动发起政变提案
- `/rebel --dimension <name>` - 审视指定维度
- `/rebel --history` - 查看审视历史

### 数据文件

所有叛逆者数据存储在 `.rebel/` 目录下:

```
.rebel/
  config.yaml           # 规则引擎配置（用户可修改）
  state.json            # 运行状态（自动维护）
  health-trends.json    # 健康趋势（自动维护）
  audit-history/        # 审视历史记录
  coup-history/         # 政变历史记录
```

### 注意事项

- 主Agent不应修改 `.rebel/` 目录下的文件（除 config.yaml 经用户批准外）
- 审视过程中遵循只读原则
- 所有变更必须通过政变提案审批
