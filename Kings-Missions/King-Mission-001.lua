-- 【题目】
-- 使用MOOSE任务框架，向玩家显示一条消息。
-- 【流程提示】
-- 将MOOSE框架的脚本文件添加至任务文件中并使其加载。
-- 编写一个脚本文件，在其中使用MOOSE框架的MESSAGE类向玩家展示消息。
-- 将该脚本文件添加到任务文件中，并使其在MOOSE框架加载完成后再加载。
-- 【保密期限】
-- 2022-12-10 24:00前
-- 【成果上传位置】
-- 群文件 -> [第1期课题成果汇总]
-- 【其他】
-- 因为是第1期，所以简单点

-- 参考 https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Core.Message.html

local MessageAll = MESSAGE:New("消息展示", "测试", 120 )
MessageAll:ToAll()