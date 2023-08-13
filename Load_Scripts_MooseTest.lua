local script_path = "C:/Users/Issen/Saved Games/DCS/Missions/Mission-Scripts/"

local script_list = { -- Load order must be correct
"Moose.lua", "SolarStorm.lua", "MooseTest.lua"}

local function load_scripts(path, list)
    for _, value in ipairs(list) do
        dofile(path .. value)
    end
end

if lfs then
    script_path = lfs.writedir() .. "Missions/Scripts/"

    env.info("Script Loader: LFS available, using relative script load path: " .. script_path)
else
    env.info("Script Loader: LFS not available, using default script load path: " .. script_path)
end

load_scripts(script_path, script_list)

-- todo:
-- #1 测试ZONE_UNIT功能,是否offset绑定的触发区可以跟随单位转动而变化
-- #2 测试爆炸功能是否会造成本单位的毁伤
