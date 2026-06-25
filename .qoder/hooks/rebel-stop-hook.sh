#!/bin/bash
# Rebel Stop Hook - 叛逆者任务完成钩子
# 在每次Agent完成响应后自动执行，更新叛逆者状态
# Qoder 通过 stdin 传入 JSON 输入

# 从 stdin 读取 Qoder 传入的 JSON
INPUT_JSON=$(cat)

# 防止无限循环（关键！）
STOP_HOOK_ACTIVE=$(echo "$INPUT_JSON" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# 项目根目录
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
REBEL_STATE="$PROJECT_DIR/.rebel/state.json"

# 检查是否启用了叛逆者机制
if [ ! -f "$REBEL_STATE" ]; then
  exit 0
fi

# 读取当前 task_counter
TASK_COUNTER=$(jq -r '.task_counter // 0' "$REBEL_STATE" 2>/dev/null)
AUDIT_INTERVAL=$(jq -r '.standard_audit_interval // 5' "$REBEL_STATE" 2>/dev/null)

# 递增任务计数器
NEW_COUNTER=$((TASK_COUNTER + 1))
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 检查是否应该触发标准审视
SHOULD_AUDIT="false"
if [ "$NEW_COUNTER" -ge "$AUDIT_INTERVAL" ]; then
  SHOULD_AUDIT="true"
  NEW_COUNTER=0
fi

# 更新 state.json
jq --argjson counter "$NEW_COUNTER" \
   --arg time "$CURRENT_TIME" \
   '.task_counter = $counter | .last_micro_audit = $time' \
   "$REBEL_STATE" > "$REBEL_STATE.tmp" && mv "$REBEL_STATE.tmp" "$REBEL_STATE"

# 如果需要触发审视，输出提示到 stderr（Qoder 会展示给用户）
if [ "$SHOULD_AUDIT" = "true" ]; then
  echo "[Rebel] 已达到审视间隔（${AUDIT_INTERVAL}次任务 | 当前计数: ${TASK_COUNTER}），建议执行 /rebel 进行标准审视" >&2
fi

exit 0
#!/bin/bash
# Rebel Stop Hook - 叛逆者任务完成钩子
# 在每次Agent完成响应后自动执行，更新叛逆者状态

# 防止无限循环（关键！）
STOP_HOOK_ACTIVE=$(echo "$INPUT_JSON" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# 项目根目录
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
REBEL_STATE="$PROJECT_DIR/.rebel/state.json"
REBEL_CONFIG="$PROJECT_DIR/.rebel/config.yaml"

# 检查是否启用了叛逆者机制
if [ ! -f "$REBEL_STATE" ]; then
  exit 0
fi

# 读取当前 task_counter
TASK_COUNTER=$(jq -r '.task_counter // 0' "$REBEL_STATE" 2>/dev/null)
AUDIT_INTERVAL=$(jq -r '.standard_audit_interval // 5' "$REBEL_STATE" 2>/dev/null)

# 递增任务计数器
NEW_COUNTER=$((TASK_COUNTER + 1))
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 检查是否应该触发标准审视
SHOULD_AUDIT="false"
if [ "$NEW_COUNTER" -ge "$AUDIT_INTERVAL" ]; then
  SHOULD_AUDIT="true"
  NEW_COUNTER=0
fi

# 更新 state.json
jq --argjson counter "$NEW_COUNTER" \
   --arg time "$CURRENT_TIME" \
   --argjson should_audit "$SHOULD_AUDIT" \
   '.task_counter = $counter | .last_micro_audit = $time' \
   "$REBEL_STATE" > "$REBEL_STATE.tmp" && mv "$REBEL_STATE.tmp" "$REBEL_STATE"

# 如果需要触发审视，输出提示（不会阻止Agent停止，只是信息性输出）
if [ "$SHOULD_AUDIT" = "true" ]; then
  echo "[Rebel] 已达到审视间隔（${AUDIT_INTERVAL}次任务），建议执行 /rebel 进行标准审视"
fi

exit 0
