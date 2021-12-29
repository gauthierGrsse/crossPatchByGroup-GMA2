-- Gauthier G.
-- v0.1
-- CrossPatchByGroup

-- Shortcut
local cmd = gma.cmd
local setvar = gma.show.setvar
local getvar = gma.show.getvar
local sleep = gma.sleep
local confirm = gma.gui.confirm
local msgbox = gma.gui.msgbox
local textinput = gma.textinput
local progress = gma.gui.progress
local getobj = gma.show.getobj
local property = gma.show.property

local function feedback(text)
    gma.feedback("Plugin CrossPatchByGroup : " .. text)
end

local function echo(text)
    gma.echo("Plugin CrossPatchByGroup : " .. text)
end

local function error(text)
    gma.gui.msgbox("Plugin CrossPatchByGroup ERROR", text)
    gma.feedback("Plugin CrossPatchByGroup ERROR : " .. text)
end

local function blindEdit(mode)
    if mode then
        cmd('BlindEdit On')
    else
        cmd('BlindEdit Off')
    end
end

local function length(tableau)
    local count = 0
    for index, value in pairs(tableau) do
        count = count + 1
    end
    echo("Lenght table : " .. count)
    return count
end

local function inputList(name)
    local list = {}
    local running = true
    while running == true do
        local temp = tonumber(textinput(name .. " list", ""))
        if temp then
            list[length(list) + 1] = temp
        else
            running = false
        end
    end
    echo("Input list " .. name .. " : " .. table.concat(list, ", "))
    return list
end

local function start(argCmd)
    local group = textinput("Group", "0")

    -- Récupération du fichier XML du groupe
    cmd("Export Group "..group..' \"tempgroup\" /nc')
    local fichierPath = gma.show.getvar('PATH') .. '/importexport/tempgroup.xml'

    -- Ouverture du fichier et stockage dans une variable lua
    local fichier = io.open(fichierPath, "r")
    io.input(fichier)
    local textXML = io.read("*all")
    io.close(fichier)

    -- Recherche des fixture ID
    local tempPos = string.find(textXML, 'fix_id="') + 1    -- position de la fixture ID
    echo(tempPos)
    local tempText = string.sub(textXML, tempPos + 7, tempPos + 11)    -- on récupère le fixture ID
    echo(tempText)
    tempPos = string.find(tempText, '"')    -- on recupère la position du " de fin pour nettoyer
    echo(tempPos)
    tempText = string.sub(tempText, 0, tempPos - 1) -- on récupère tout avant le "
    feedback(tempText)
end

return start