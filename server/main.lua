---@class Paycheck
---@field private amount number
---@field private mustbeonduty boolean
---@field private paused boolean
---@field private source number
---@field private Pay fun(self: Paycheck)
---@field private Pause fun(self: Paycheck)
---@field private Resume fun(self: Paycheck)
---@field private Destroy fun(self: Paycheck)
---@field private HandlePaymentThread fun(self: Paycheck)
---@field private ChangeAmount fun(self: Paycheck, amount: number)
---@field private IsOnDuty fun(self: Paycheck, source: number)
local Paycheck = {}
Paycheck.__index = Paycheck
Paycheck.__call = function()
    return "Paycheck"
end

local Core = exports.vorp_core:GetCore()
local paycheck = {}

---@constructor
function Paycheck:new(source, amount, mustbeonduty, isOnDuty)
    local properties = { source = source, amount = amount, mustbeonduty = mustbeonduty, paused = true, IsOnDuty = isOnDuty or false }
    return setmetatable(properties, Paycheck)
end

---@methods
function Paycheck:Pay()
    local isInSession <const> = Player(self.source).state.IsInSession
    if not isInSession then return end

    if self.IsOnDuty and not self:IsOnDuty(self.source) then return end

    local user <const> = Core.getUser(self.source)
    if not user then return end

    local character <const> = user.getUsedCharacter
    character:addCurrency(0, self.amount)
end

function Paycheck:Pause()
    if self.paused then return end
    self.paused = true
end

function Paycheck:ChangeAmount(amount)
    self.amount = amount
end

function Paycheck:Resume()
    if not self.paused then return end
    self.paused = false
    self:HandlePaymentThread()
end

function Paycheck:Destroy()
    self.paused = true
    self = nil
end

function Paycheck:HandlePaymentThread()
    CreateThread(function()
        while not self.paused do
            Wait(60000)
            self:Pay()
        end
    end)
end

local function addUserToPaycheck(source, character)
    local job <const> = Config.Jobs[character.job]
    if not job then return end

    local amount <const> = job.payment[character.jobGrade]
    if not amount then return end

    paycheck[source] = Paycheck:new(source, amount, job.mustbeonduty, job.IsOnDuty)

    if not job.mustbeonduty then
        return paycheck[source]:HandlePaymentThread()
    end

    local statebagKey <const> = job.statebagKey
    if not statebagKey then return end

    AddStateBagChangeHandler(statebagKey, ('player:%s'):format(source), function(bagName, _, value, _, replicated)
        print(bagName, _, value, _, replicated)
        if not replicated then return end

        repeat Wait(0) until GetPlayerFromStateBagName(bagName) ~= 0
        local _source <const> = GetPlayerFromStateBagName(bagName)

        if not paycheck[_source] then return end -- player is not in paycheck possible cheater

        if value then
            print("player is on duty", paycheck[source].amount)
            paycheck[_source]:Resume()
        else
            print("player is off duty")
            paycheck[_source]:Pause()
        end
    end)
end

--* player selected character check it can have a payment
AddEventHandler('vorp:SelectedCharacter', function(source, character)
    if paycheck[source] then return end -- player already has a paycheck
    addUserToPaycheck(source, character)
end)

--* handle on job or grade change
AddEventHandler('vorp:playerJobChange', function(source, newjob, oldjob)
    SetTimeout(1000, function()
        if paycheck[source] then
            local job <const> = Config.Jobs[newjob]
            if not job then return end
            local user <const> = Core.getUser(source)
            if not user then return end

            local character <const> = user.getUsedCharacter
            local amount <const> = job.payment[character.grade]
            if not amount then return end

            paycheck[source]:ChangeAmount(amount) -- job changed so we need to update the paycheck amount too
        else
            -- player doesnt exist in paychecks check if they need a paycheck
            local user <const> = Core.getUser(source)
            if not user then return end
            local character <const> = user.getUsedCharacter
            addUserToPaycheck(source, character)
        end
    end)
end)

--* player dropped
AddEventHandler('playerDropped', function()
    local _source <const> = source

    if paycheck[_source] then
        paycheck[_source]:Destroy()
        paycheck[_source] = nil
    end
end)

--* resource start dev mode
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if not Config.DevMode then return end

    for _, player in ipairs(GetPlayers()) do
        local user <const> = Core.getUser(tonumber(player))
        if not user then return end
        local character <const> = user.getUsedCharacter
        addUserToPaycheck(tonumber(player), character)
    end
end)
