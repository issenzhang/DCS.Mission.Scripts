-- 【题目】
-- 使用MOOSE任务框架，生成一组敌军，并定时销毁，销毁后再定时生成，循环往复。
-- 【流程提示】
-- 可以依托于编辑器中现有的敌军群组，由MOOSE框架控制该群组的生成与销毁。
-- 【保密期限】
-- 2022-12-14（周三）24:00前
-- 【成果上传位置】
-- 群文件 -> [第2期课题成果汇总]
-- 【其他】
-- 这期的题目对新手而言难度可能比较大，不过反正总结会在下周进行，所欲可以慢慢来。

-- 前期在ME内预先设置群组，群组名“groupTest”,设置为延迟出生。

local schedulerSpawnThenDestory = SCHEDULER:New(nil, SwpanThenDestory, {}, 30, 30)

function SwpanThenDestory()
    local spawner = SPAWN:New("groupTest")
    local group = spawner.Spawn()
    -- destroy group after 10 second.
    SCHEDULER:New(nil,
        function()
            group:Destroy()
        end, {}, 10)
end
