local script_path = "C:/Users/Issen/Saved Games/DCS/Missions/Mission-Scripts/"

local script_list =
{
    -- Load order must be correct
    "Moose.lua",    
    "AAR_TRAIN.LUA",
    "map_BTM#1_nav&aar.lua"
}

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
