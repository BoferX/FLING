local hashFunction
local scriptId =
    getfenv()[
    "This is t" ..
        "he key check libr" ..
            --
            "ary used by Luarmor," ..
                " documentation can be" ..
                    " view" ..
                        "ed at h" ..
                            "ttps://docs.luarmor." ..
                                "net/luarm" .. "or-user-manual-and-" .. "f.a.q#key" .. "-check-library"
]
print(scriptId)
do
    local function normalizeUInt32(value)
        return value % 4294967296
    end
    
    local function bitwiseXor(left, right)
        local result, bitPosition = 0, 1
        while left > 0 or right > 0 do
            local leftBit = left % 2
            local rightBit = right % 2
            if leftBit ~= rightBit then
                result = result + bitPosition
            end
            left = math.floor(left / 2)
            right = math.floor(right / 2)
            bitPosition = bitPosition * 2
        end
        return result
    end
    
    local function rotateLeft(value, bits)
        return normalizeUInt32(value * 2 ^ bits)
    end
    
    local function rotateRight(value, bits)
        return math.floor(value / 2 ^ bits) % 4294967296
    end
    
    function hashFunction(input)
        local hashState = {
            [1] = 0x5ad69b68,
            [2] = 0x03b7222a,
            [3] = 0x2d074df6,
            [4] = 0xcb4fff2d
        }
        local constants = {[1] = 0x01c3, [2] = 0xa408, [3] = 0x964d, [4] = 0x4320}
        
        local inputLength = #input
        local position = 1
        while position <= inputLength do
            local chunk = 0
            for byteIndex = 0, 3 do
                local charPosition = position - 1 + byteIndex
                if charPosition < inputLength then
                    local charCode = input:byte(charPosition + 1)
                    chunk = chunk + charCode * 2 ^ (8 * byteIndex)
                end
            end
            chunk = normalizeUInt32(chunk)
            
            for round = 1, 4 do
                local temp = bitwiseXor(hashState[round], chunk)
                local nextState = hashState[round % 4 + 1]
                temp = bitwiseXor(temp, nextState)
                temp = normalizeUInt32(rotateLeft(temp, 5) + rotateRight(temp, 2) + constants[round])
                
                local shiftAmount = (round - 1) * 5 % 32
                local rotatedChunk = rotateRight(chunk, shiftAmount)
                temp = bitwiseXor(temp, rotatedChunk)
                temp = normalizeUInt32(temp)
                
                local thirdState = hashState[(round + 1) % 4 + 1]
                temp = normalizeUInt32(temp + thirdState)
                hashState[round] = normalizeUInt32(temp)
            end
            position = position + 4
        end
        
        for round = 1, 4 do
            local temp = hashState[round]
            local nextState = hashState[round % 4 + 1]
            local thirdState = hashState[(round + 2) % 4 + 1]
            
            temp = normalizeUInt32(temp + nextState)
            temp = bitwiseXor(temp, thirdState)
            
            local shiftAmount = round * 7 % 32
            temp = normalizeUInt32(rotateLeft(temp, shiftAmount) + rotateRight(temp, 32 - shiftAmount))
            hashState[round] = temp
        end
        
        local hexParts = {}
        for i = 1, 4 do
            hexParts[i] = string.format("%08X", hashState[i])
        end
        return table.concat(hexParts)
    end
end

local httpService
local httpClient = game:GetService("HttpService")
local function decodeJson(jsonString)
    print(jsonString)
    return httpClient:JSONDecode(jsonString)
end

local requestFunction = syn and syn.request or request or http_request

local function checkKey(key)
    local currentTime = os.time()
    key = tostring(key)
    scriptId = tostring(scriptId)
    
    local response = requestFunction({
        Method = "GET",
        Url = "https://sdkapi-public.luarmor.net/sync"
    })
    
    response = decodeJson(response.Body)
    local nodes = response.nodes
    local selectedNode = nodes[math.random(1, #nodes)]
    
    local checkUrl = selectedNode .. "check_key?key=" .. key .. "&script_id=" .. scriptId
    setclipboard(checkUrl)
    
    local serverTime = response.st
    local timeDifference = serverTime - currentTime
    currentTime = currentTime + timeDifference
    
    response = requestFunction({
        Method = "GET",
        Url = checkUrl,
        Headers = {
            ["clienttime"] = tostring(currentTime),
            ["catcat128"] = hashFunction(key .. "_cfver1.0_" .. scriptId .. "_time_" .. currentTime)
        }
    })
    
    return decodeJson(response.Body)
end

local function validateScriptId()
    scriptId = tostring(scriptId)
    if not scriptId:match("^[a-f0-9]{32}$") then
        return
    end
    pcall(writefile, scriptId .. "-cache.lua", "recache is required")
    wait(0.1)
    pcall(delfile, scriptId .. "-cache.lua")
end

local function loadScript()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/" .. tostring(scriptId) .. ".lua"))()
end

return setmetatable(
    {},
    {
        __index = function(self, key)
            local hashedKey = hashFunction(key)
            -- hashFunction(key)
            if hashedKey == "30F75B193B948B4E965146365A85CBCC" then
                return checkKey
            end
            if hashedKey == "2BCEA36EB24E250BBAB188C73A74DF10" then
                return validateScriptId
            end
            if hashedKey == "75624F56542822D214B1FE25E8798CC6" then
                return loadScript
            end
            return nil
        end,
        __newindex = function(self, key, value)
            if key == "script_id" then
                scriptId = value
            end
        end
    }
)
