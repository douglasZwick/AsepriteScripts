do
  local updateInterval = 0.05

  local layerHolders = {}
  local tags = {}
  local friends = {}
  local enemies = {}

  local tagString       = "t"
  local xTagString      = "x"
  local affectorString  = "a"
  local friendString    = "f"
  local enemyString     = "e"

  local basicPattern    = "%s*:%s*(%w+)"

  local tagPattern      = tagString      .. basicPattern
  local xTagPattern     = xTagString     .. basicPattern
  local affectorPattern = affectorString .. basicPattern
  local friendPattern   = friendString   .. basicPattern
  local enemyPattern    = enemyString    .. basicPattern

  local refreshNeeded = false

  function PrintLayerHolders()
    local output = "Layer Holders:\n"
    for _, entry in ipairs(layerHolders) do
      local name = entry.layer.name
      local vis = tostring(entry.isVisible)
      local xTags = entry.xTags
      local affectors = entry.affectors
      local m = name .. " | Vis: " .. vis .. " | xTags: "
      for xTag, _ in pairs(xTags) do
        m = m .. xTag .. " "
      end
      m = m .. "| Affectors: "
      for affector, _ in pairs(affectors) do
        m = m .. affector .. " "
      end
      output = output .. m .. "\n"
    end
    print(output)
  end

  function PrintTagTable(tableToPrint, name)
    name = name or ""
    local output = "Printing " .. name .. " --\n"
    for key, _ in pairs(tableToPrint) do
      output = output .. "  " .. key .. " :\n"
      local subTable = tableToPrint[key]
      for _, layerHolder in ipairs(subTable) do
        output = output .. "    " .. layerHolder.layer.name .. "\n"
      end
    end
    print(output)
  end

  function AddLayerHolderToContainer(layerHolder, container, key)
    local subTable = container[key]

    if subTable == nil then
      subTable = {}
      container[key] = subTable
    end

    table.insert(subTable, layerHolder)
  end

  function AddTag(layerHolder, tag)
    AddLayerHolderToContainer(layerHolder, tags, tag)
  end

  function AddFriend(layerHolder, affector)
    AddLayerHolderToContainer(layerHolder, friends, affector)
  end

  function AddEnemy(layerHolder, affector)
    AddLayerHolderToContainer(layerHolder, enemies, affector)
  end

  function AddLayerHolder(layerToAdd)
    local layerHolder =
    {
      layer = layerToAdd,
      isVisible = layerToAdd.isVisible,
      xTags = {},
      affectors = {},
    }

    local data = layerToAdd.data
    local tagMatches = string.gmatch(data, tagPattern)
    local xTagMatches = string.gmatch(data, xTagPattern)
    local affectorMatches = string.gmatch(data, affectorPattern)
    local friendMatches = string.gmatch(data, friendPattern)
    local enemyMatches = string.gmatch(data, enemyPattern)

    for tag in tagMatches do
      AddTag(layerHolder, tag)
    end

    for xTag in xTagMatches do
      layerHolder.xTags[xTag] = true
      AddTag(layerHolder, xTag)
    end

    for affector in affectorMatches do
      layerHolder.affectors[affector] = true
    end

    for affector in friendMatches do
      AddFriend(layerHolder, affector)
    end

    for affector in enemyMatches do
      AddEnemy(layerHolder, affector)
    end

    table.insert(layerHolders, layerHolder)
  end

  function AddTree(layerTable)
    for _, currentLayer in ipairs(layerTable) do
      AddLayerHolder(currentLayer)
      if currentLayer.isGroup then
        AddTree(currentLayer.layers)
      end
    end
  end

  function Initialize()
    layerHolders = {}
    tags = {}
    friends = {}
    enemies = {}

    if app.sprite == nil then return end

    AddTree(app.sprite.layers)
  end

  function HideTagExcept(tag, exception)
    for _, layerHolder in ipairs(tags[tag]) do
      if layerHolder == exception then goto continue end
      if layerHolder.layer.isVisible then
        layerHolder.layer.isVisible = false
        refreshNeeded = true
      end
      ::continue::
    end
  end

  function AffectorWasShown(affector)
    local subTable = friends[affector]
    if subTable == nil then goto continue end

    for _, friend in ipairs(subTable) do
      if not friend.layer.isVisible then
        friend.layer.isVisible = true
        refreshNeeded = true
      end
    end

    ::continue::

    subTable = enemies[affector]
    if subTable == nil then return end

    for _, enemy in ipairs(subTable) do
      if enemy.layer.isVisible then
        enemy.layer.isVisible = false
        refreshNeeded = true
      end
    end
  end

  function AffectorWasHidden(affector)
    local subTable = friends[affector]
    if subTable == nil then goto continue end

    for _, friend in ipairs(subTable) do
      if friend.layer.isVisible then
        friend.layer.isVisible = false
        refreshNeeded = true
      end
    end

    ::continue::

    subTable = enemies[affector]
    if subTable == nil then return end

    for _, enemy in ipairs(subTable) do
      if not enemy.layer.isVisible then
        enemy.layer.isVisible = true
        refreshNeeded = true
      end
    end
  end

  function LayerWasShown(layerHolder)
    for xTag, _ in pairs(layerHolder.xTags) do
      HideTagExcept(xTag, layerHolder)
    end

    for affector, _ in pairs(layerHolder.affectors) do
      AffectorWasShown(affector)
    end
  end

  function LayerWasHidden(layerHolder)
    for affector, _ in pairs(layerHolder.affectors) do
      AffectorWasHidden(affector)
    end
  end

  function CheckLayerVisibility(layerHolder)
    local prevVisible = layerHolder.isVisible
    local currVisible = layerHolder.layer.isVisible
    if currVisible and not prevVisible then
      LayerWasShown(layerHolder)
    elseif not currVisible and prevVisible then
      LayerWasHidden(layerHolder)
    end
    layerHolder.isVisible = currVisible
  end

  function Update()
    if app.sprite == nil then return end

    refreshNeeded = false

    for i, layerHolder in ipairs(layerHolders) do
      CheckLayerVisibility(layerHolder)
    end

    if refreshNeeded then
      app.refresh()
    end
  end

  -- local dlg = Dialog { title = "Layer Tags" }

  function OnSpriteChanged(e)
    Initialize()
  end

  local changeListenerCode = app.sprite.events:on("change", OnSpriteChanged)
  local updateTimer = Timer{ interval = updateInterval, ontick = Update }
  local beforecommandListenerCode = nil
  updateTimer:start()

  function Cleanup()
    app.sprite.events:off(changeListenerCode)
    app.events:off(beforecommandListenerCode)
    updateTimer:stop()
  end

  function OnRefresh()
    -- PrintTagTable(enemies, "Enemies")
  end

  function OnBeforeCommand(e)
    if e.name == "RunScript" or e.name == "Exit" then
      Cleanup()
    elseif e.name == "Refresh" then
      OnRefresh()
    end
  end

  beforecommandListenerCode = app.events:on("beforecommand", OnBeforeCommand)

  Initialize()
end
