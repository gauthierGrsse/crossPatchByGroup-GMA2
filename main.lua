-- Gauthier G.
-- v1.0
-- CrossPatchByGroup
-- variable
local tempGroup = 9999 -- id du groupe temporaire, attention il va etre modifie sans confirmation

-- Shortcut
local cmd = gma.cmd
local setvar = gma.show.setvar
local getvar = gma.show.getvar
local function sleep()
    gma.sleep(0.1)
end
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

local function inList(tableau, element)
    for key, value in pairs(tableau) do
        if value == element then
            return true
        end
    end
    return false
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

local function findFixtureInGroup(group)
    -- Récupération du fichier XML du groupe
    cmd("Export Group " .. group .. ' \"tempgroup\" /nc')
    local fichierPath = gma.show.getvar('PATH') .. '/importexport/tempgroup.xml'

    -- Ouverture du fichier et stockage dans une variable lua
    local fichier = io.open(fichierPath, "r")
    io.input(fichier)
    local textXML = io.read("*all")
    io.close(fichier)

    -- Creation table groupe
    local fixtureGroup = {}

    -- Lecture du fichier pour trouver les fixture ID
    local cursorPos = 1 -- Curseur de lecture pour pas lire 2 fois la même chose
    local running = true
    while running == true do
        if string.find(textXML, 'fix_id="', cursorPos) then
            local tempPos = string.find(textXML, 'fix_id="', cursorPos) + 1 -- position de la ligne fixture ID
            cursorPos = tempPos + 1 -- on déplace le curseur apres pour ne pas lire cet ID 2 fois
            local tempText = string.sub(textXML, tempPos + 7, tempPos + 12) -- on récupère le fixture ID
            tempPos = string.find(tempText, '"') -- on recupère la position du " de fin pour nettoyer la merde au bout
            tempText = string.sub(tempText, 0, tempPos - 1) -- on récupère tout avant le "
            echo("Find fixture ID " .. tempText .. " in group " .. group)
            tempText = tonumber(tempText)
            fixtureGroup[length(fixtureGroup) + 1] = tempText -- On ajoute le fixture ID dans le tableau
        else
            running = false
        end
    end

    return fixtureGroup
end

local function getPatchOfFixture(fixtureID)
    return property.get(getobj.child(getobj.handle("Fixture " .. fixtureID), 0), 4)
end

local function patchFixture(fixtureID, DmxAdress)
    cmd('Assign Fixture ' .. fixtureID .. ' At Dmx ' .. DmxAdress .. ' /nc')
end

local function start(argCmd)
    if tonumber(getvar("selectedfixturescount")) == 0 then
        blindEdit(true)
        local groupAIndex = textinput("Group A", "0")
        local groupBIndex = textinput("Group B", "0")

        local groupAFixtures = findFixtureInGroup(groupAIndex)
        local groupBFixtures = findFixtureInGroup(groupBIndex)

        if length(groupAFixtures) ~= length(groupBFixtures) then -- Test si les 2 groupes font la meme longueur, sinon erreur
            error("Le groupe A et B ne comporte pas le meme nombre de fixture, cross patch impossible !")
            return false
        end

        local groupAPatch = {} -- creation du talbeau patch groupe A
        for key, value in pairs(groupAFixtures) do
            groupAPatch[length(groupAPatch) + 1] = getPatchOfFixture(value)
        end

        local groupBPatch = {} -- creation du talbeau patch groupe B
        for key, value in pairs(groupBFixtures) do
            groupBPatch[length(groupBPatch) + 1] = getPatchOfFixture(value)
        end

        -- Affichage d'un recap global du swap
        gma.feedback("--------------------------------------------------------------------------------------")
        for key, value in pairs(groupAFixtures) do
            if inList(groupBFixtures, value) then
                gma.feedback("Fixture ID " .. value .. " patch " .. groupAPatch[key] ..
                                 " <------- TAKE PATCH OF -------< Fixture ID " .. groupBFixtures[key] .. " patch " ..
                                 groupBPatch[key])
            else
                gma.feedback("Fixture ID " .. value .. " patch " .. groupAPatch[key] ..
                                 " <------- SWAP PATCH -------> Fixture ID " .. groupBFixtures[key] .. " patch " ..
                                 groupBPatch[key])
            end
        end
        gma.feedback("--------------------------------------------------------------------------------------")

        if confirm("CrossPatchByGroup",
            "Confirmez le cross patch entre le groupe " .. groupAIndex .. " et le groupe " .. groupBIndex .. " ?") then -- demande confirmation
            local patchedList = {} -- Liste des deja patchee

            local progressBar = progress.start("Patch group A") -- Affichage progress bar pour faire joli
            progress.setrange(progressBar, 0, length(groupAFixtures))
            local progressBarIndex = 0

            for key, value in pairs(groupAFixtures) do -- Patch du groupe A
                patchFixture(value, groupBPatch[key])
                patchedList[length(patchedList) + 1] = value -- Ajout de la fixture a la liste des deja patchee

                progressBarIndex = progressBarIndex + 1
                progress.set(progressBar, progressBarIndex)
                progress.settext(progressBar, "Fixture " .. value)
                sleep()
            end
            progress.stop(progressBar)

            progressBar = progress.start("Patch group A") -- Affichage progress bar pour faire joli
            progress.setrange(progressBar, 0, length(groupAFixtures))
            progressBarIndex = 0

            for key, value in pairs(groupBFixtures) do -- Patch du groupe B
                if inList(patchedList, value) then -- Test si fixture pas deja patchee
                    feedback("Fixture " .. value .. " deja patchee")
                else
                    patchFixture(value, groupAPatch[key])
                    patchedList[length(patchedList) + 1] = value -- Ajout de la fixture a la liste des deja patchee
                end

                progressBarIndex = progressBarIndex + 1
                progress.set(progressBar, progressBarIndex)
                progress.settext(progressBar, "Fixture " .. value)
                sleep()
            end
            progress.stop(progressBar)
            feedback("Cross Patch effectué")
        else
            feedback("Cross patch annule")
        end
        blindEdit(false)
    elseif tonumber(getvar("selectedfixturescount")) == 2 then -- si 2 fixture selectionnees
        cmd('Store Group ' .. tempGroup .. ' /o') -- on store dans un group temporaire pour recuperer l'id des machines
        cmd('SelFix Group ' .. tempGroup .. '')
        blindEdit(true)
        local fixture = findFixtureInGroup(tempGroup) -- on recupere les id

        gma.feedback("--------------------------------------------------------------------------------------")
        gma.feedback("Fixture ID " .. fixture[1] .. " patch " .. getPatchOfFixture(fixture[1]) ..
                         " <------- SWAP PATCH -------> Fixture ID " .. fixture[2] .. " patch " ..
                         getPatchOfFixture(fixture[2])) -- affichage
        gma.feedback("--------------------------------------------------------------------------------------")

        if confirm('CrossPatchByGroup', 'Voulez-vous inverser le patch entre la fixture ' .. fixture[1] ..
            ' et la fixture ' .. fixture[2] .. ' ?') then
            local patchFixture0 = getPatchOfFixture(fixture[1]) -- on met de cote le patch de la fixture 1
            patchFixture(fixture[1], getPatchOfFixture(fixture[2])) -- on patch la fixture 1 avec l'adresse de la fixture 2
            patchFixture(fixture[2], patchFixture0) -- et on patch la fixture 2 avec l'adresse de la fixt 1 avec l'adresse mise de cote
        else
            feedback("Cross patch annule")
        end
        blindEdit(false)
        feedback("Cross Patch effectué")
    else
        error("Nombre de fixture selectionnées n'est pas égal a deux.")
    end

end

return start
