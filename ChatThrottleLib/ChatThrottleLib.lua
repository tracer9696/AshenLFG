--
-- ChatThrottleLib compatibility shim for WoW 1.12 / Lua 5.0.
--
-- The bundled upstream ChatThrottleLib used Lua 5.1 syntax and post-vanilla
-- secure hook APIs, which prevents the addon from loading on a 1.12 client.
-- This keeps the small public API this addon bundle needs without using 5.1
-- syntax, the length operator, hooksecurefunc, or vararg forwarding.
--

local CTL_VERSION = 15
local _G = _G or getfenv()

if _G.ChatThrottleLib and _G.ChatThrottleLib.version and _G.ChatThrottleLib.version >= CTL_VERSION then
    return
end

if not _G.ChatThrottleLib then
    _G.ChatThrottleLib = {}
end

ChatThrottleLib = _G.ChatThrottleLib
local ChatThrottleLib = _G.ChatThrottleLib

ChatThrottleLib.version = CTL_VERSION
ChatThrottleLib.MAX_CPS = ChatThrottleLib.MAX_CPS or 800
ChatThrottleLib.MSG_OVERHEAD = ChatThrottleLib.MSG_OVERHEAD or 40
ChatThrottleLib.BURST = ChatThrottleLib.BURST or 4000

local function CTL_TableLength(t)
    if table.getn then
        return table.getn(t)
    end
    if getn then
        return getn(t)
    end
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

local function CTL_MessageSize(text, destination)
    return string.len(tostring(text or "")) + string.len(tostring(destination or "")) + ChatThrottleLib.MSG_OVERHEAD
end

function ChatThrottleLib:Init()
    if not self.Frame then
        self.Frame = CreateFrame("Frame")
    end

    self.Queue = self.Queue or {}
    self.avail = self.BURST
    self.LastAvailUpdate = GetTime()
    self.Frame:SetScript("OnUpdate", function()
        ChatThrottleLib:OnUpdate(arg1)
    end)
    self.Frame:Hide()
end

function ChatThrottleLib:UpdateAvail(elapsed)
    local now = GetTime()
    local delta = elapsed

    if not delta or delta <= 0 then
        delta = now - (self.LastAvailUpdate or now)
    end

    self.avail = math.min(self.BURST, (self.avail or 0) + self.MAX_CPS * delta)
    self.LastAvailUpdate = now
    return self.avail
end

function ChatThrottleLib:Enqueue(prioname, pipename, msg)
    table.insert(self.Queue, msg)
    self.Frame:Show()
end

function ChatThrottleLib:OnUpdate(elapsed)
    self:UpdateAvail(elapsed)

    while CTL_TableLength(self.Queue) > 0 do
        local msg = self.Queue[1]
        if msg.nSize and self.avail < msg.nSize then
            return
        end

        table.remove(self.Queue, 1)
        self.avail = self.avail - (msg.nSize or 0)

        if msg.kind == "addon" then
            if SendAddonMessage then
                SendAddonMessage(msg.prefix, msg.text, msg.chattype, msg.target)
            end
        else
            SendChatMessage(msg.text, msg.chattype, msg.language, msg.destination)
        end

        if type(msg.callbackFn) == "function" then
            msg.callbackFn(msg.callbackArg)
        end
    end

    self.Frame:Hide()
end

function ChatThrottleLib:SendChatMessage(prio, prefix, text, chattype, language, destination, queueName, callbackFn, callbackArg)
    if not text then
        return
    end

    local msg = {
        kind = "chat",
        text = text,
        chattype = chattype or "SAY",
        language = language,
        destination = destination,
        nSize = CTL_MessageSize(text, destination),
        callbackFn = callbackFn,
        callbackArg = callbackArg
    }

    self:Enqueue(prio or "NORMAL", queueName or prefix or "", msg)
end

function ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype, target, queueName, callbackFn, callbackArg)
    if not prefix or not text or not chattype then
        return
    end

    local msg = {
        kind = "addon",
        prefix = prefix,
        text = text,
        chattype = chattype,
        target = target,
        nSize = CTL_MessageSize(prefix .. text, target),
        callbackFn = callbackFn,
        callbackArg = callbackArg
    }

    self:Enqueue(prio or "NORMAL", queueName or prefix or "", msg)
end

ChatThrottleLib:Init()
