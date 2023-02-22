local pollnet = require("mcm_pollnet_lib")

local REQUEST_TYPE =
{
    DEPENDENCY_REGISTRY = 1,
    DEPENDENCY_FILE = 2,
}

---Define the mcm_pollnet object
local mcm_pollnet = {
    log = print,
    callbacks = {
        [REQUEST_TYPE.DEPENDENCY_REGISTRY] = { },
        [REQUEST_TYPE.DEPENDENCY_FILE] = { }
    },
    awaiting_response = false,
    base_url = "https://raw.githubusercontent.com/RAX-Anomaly/anomaly-dependencies-project/main/dependencies/"
}

local function fire_callbacks(data)
    if mcm_pollnet.request_type == nil then
        return
    end

    if mcm_pollnet.callbacks[mcm_pollnet.request_type] == nil then
        mcm_pollnet.log("[MCM] [WebSocket] No callbacks found for message type: " .. mcm_pollnet.request_type)
        return
    end
    for _, callback_function in pairs(mcm_pollnet.callbacks[mcm_pollnet.request_type]) do
        if callback_function ~= nil then
            callback_function(data)
        end
    end
end

function mcm_pollnet.get_registry()
    mcm_pollnet.get(REQUEST_TYPE.DEPENDENCY_REGISTRY, mcm_pollnet.base_url .. "dependencies.registry")
end

function mcm_pollnet.get_dependency(path)
    mcm_pollnet.get(REQUEST_TYPE.DEPENDENCY_FILE, mcm_pollnet.base_url .. path)
end

function mcm_pollnet.get(request_type, url)
    mcm_pollnet.close()
    mcm_pollnet.request_type = request_type
    mcm_pollnet.request_url = url
    mcm_pollnet.socket = pollnet.http_get(mcm_pollnet.request_url)
    mcm_pollnet.awaiting_response = true
    mcm_pollnet.log("[MCM] [WebSocket] GET " .. mcm_pollnet.request_url)
end

function mcm_pollnet.listen()
    if mcm_pollnet.awaiting_response == false then
        return
    end

    local success, message = mcm_pollnet.socket:poll()

    if not success then
        mcm_pollnet.log("[MCM] [WebSocket] Failure: " .. message)
        mcm_pollnet.close()
        fire_callbacks(nil)
        return
    end

    if message and string.len(message) > 0 then
        --mcm_pollnet.log("[MCM] [WebSocket] Received: " .. message)
        mcm_pollnet.close()
        fire_callbacks(message)
    end
end

function mcm_pollnet.close()
    if mcm_pollnet.socket ~= nil then
        mcm_pollnet.socket:close()
        mcm_pollnet.socket = nil
    end
    mcm_pollnet.awaiting_response = false
end

return mcm_pollnet