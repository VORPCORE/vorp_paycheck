Config = {}

Config.DevMode = false -- to test when you restart script

Config.PayTime = 1000
-- this is a paycheck script that will be paying these jobs based on their grades
-- payments are done at every minute because people can crash so its a safety measure and that's why it's not here

--* FEATURE
-- support for custom onduty check SERVER SIDE ONLY you can add this bellow to any of the job entries
--[[

    IsOnDuty = function(source, job, grade)
        -- in here you can add your custom onduty check if your scripts dont use statebags
        --local isOnduty = exports.script_name:IsPlayerOnDuty(source) -- JUST AN EXAMPLE
        return true
    end,

]]

-- this is the payment for each grade allows you to make unique payments for each grade and without code repetition
Config.Grades = {
    law = {
        [0] = 0.20, -- pay 0.20 cents per minute
        [1] = 0.40, -- pay 0.40 cents per minute
        [2] = 0.60, -- pay 0.60 cents per minute
        [3] = 0.80, -- pay 0.80 cents per minute
    },
    medic = {
        [0] = 0.20, -- pay 0.20 cents per minute
        [1] = 0.40, -- pay 0.40 cents per minute
        [2] = 0.60, -- pay 0.60 cents per minute
        [3] = 0.80, -- pay 0.80 cents per minute
    },
    -- add more to make unique payments
}

-- make unique jobs and their ranks here to get them to be paid
Config.Jobs = {

    --POLICE
    BWSheriff = {                     -- job name
        payment = Config.Grades.law,
        mustbeonduty = true,          -- vorp_police works for this so leave true if you are using vorp police, other wise set to false unless you have scripts using statebags to go on duty
        statebagKey = 'isPoliceDuty', -- this is the statebag key for the job this already exists in vorp_police, if you use other scripts then change it
    },
    RhoSheriff = {
        payment = Config.Grades.law,
        mustbeonduty = true,
        statebagKey = 'isPoliceDuty',
    },
    SDSheriff = {
        payment = Config.Grades.law,
        mustbeonduty = true,
        statebagKey = 'isPoliceDuty',
    },
    StrSheriff = {
        payment = Config.Grades.law,
        mustbeonduty = true,
        statebagKey = 'isPoliceDuty',
    },
    ArmSheriff = {
        payment = Config.Grades.law,
        mustbeonduty = true,
        statebagKey = 'isPoliceDuty',
    },
    ValSheriff = {
        payment = Config.Grades.law,
        mustbeonduty = true,
        statebagKey = 'isPoliceDuty',
    },

    --MEDICS
    doctor = {
        payment = Config.Grades.medic,
        mustbeonduty = true,         -- if you dont have a script that uses statebags to go on duty then set to false vorp_medic works for this so leave true if you are using vorp medic
        statebagKey = 'isMedicDuty', -- this is the statebag key for the job this already exists in vorp_medic, if you use other scripts then change it
    },
    headdoctor = {
        payment = Config.Grades.medic,
        mustbeonduty = true,
        statebagKey = 'isMedicDuty',
    },
    shaman = {
        payment = Config.Grades.medic,
        mustbeonduty = true,
        statebagKey = 'isMedicDuty',
    },
    --add more jobs here
}
