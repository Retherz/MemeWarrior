MemeWarrior_Overpower = 0;
MemeWarrior_OverpowerID = 0;
MemeWarrior_BloodthirstID = 0;
MemeWarrior_WhirlwindID = 0;
MemeWarrior_HamstringID = 0;
MemeWarrior_PummelID = 0;

function MemeWarrior_OnEvent()
  if(strfind(arg1, "dodge")) then
    MemeWarrior_Overpower = GetTime();
  end
end


function MemeWarrior_OnLoad()
  if(GetSpellName(1, "spell") ~= nil) then
    local _, englishClass = UnitClass("player");
    if(englishClass ~= "WARRIOR") then
      MemeWarrior_AddOnFrame:SetScript("OnUpdate", nil);
      MemeWarrior_AddOnFrame:SetScript("OnEvent", nil);
      return;
    end
    MemeWarrior_SetSpellIDs();
    MemeWarrior_AddOnFrame:SetScript("OnUpdate", nil);
    MemeWarrior_AddOnFrame:SetScript("OnEvent", MemeWarrior_OnEvent);
  end
end

local frame = CreateFrame("Frame", "MemeWarrior_AddOnFrame");
MemeWarrior_AddOnFrame:SetScript("OnEvent", MemeWarrior_OnEvent);
MemeWarrior_AddOnFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
MemeWarrior_AddOnFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
MemeWarrior_AddOnFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES");
MemeWarrior_AddOnFrame:SetScript("OnUpdate", MemeWarrior_OnLoad);

function MemeWarrior_SetSpellIDs()
  local i = 1
  while true do
   local spellName = GetSpellName(i, "spell")
    if(spellName == "Overpower") then
      MemeWarrior_OverpowerID = i;
    elseif(spellName == "Whirlwind") then
      MemeWarrior_WhirlwindID = i;
    elseif(spellName == "Bloodthirst") then
      MemeWarrior_BloodthirstID = i;
    elseif(spellName == "Pummel") then
      MemeWarrior_PummelID = i;
    elseif(spellName == "Hamstring") then
      MemeWarrior_HamstringID = i;
    end
    if not spellName then
      break
    end
   i = i + 1
  end
end

function MemeWarrior_GetCooldown(id)
  local duration, cd = GetSpellCooldown(id, "spell");
  if(cd == 0) then
    return 0;
  else
    return cd - (GetTime() - duration);
  end
end

function MemeWarrior_Rock()
  if(not MemeWarrior_OverpowerReady() and not MemeWarrior_IsBerserker()) then
    CastSpellByName("Berserker Stance");
  end
  if(UnitHealth("target") <= 20) then
    Bloodexecute();
    return;
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) <= 0) then
    CastSpellByName("Bloodthirst");
  elseif(MemeWarrior_GetCooldown(MemeWarrior_WhirlwindID) <= 0) then
    CastSpellByName("Whirlwind");
  elseif(MemeWarrior_OverpowerReady()) then
    CastSpellByName("Battle Stance");
    CastSpellByName("Overpower");
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) > 1.5 and UnitMana("player") > 40) then
    Pummelstring();
  end
  if(UnitMana("player") > 50) then
    HeroicCleave();
  end
end

function MemeWarrior_SoftRock()
  if(not MemeWarrior_OverpowerReady() and not MemeWarrior_IsBerserker()) then
    CastSpellByName("Berserker Stance");
  end
  if(UnitHealth("target") <= 20) then
  CastSpellByName("Execute");
    --Bloodexecute();
    return;
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) <= 0) then
    CastSpellByName("Bloodthirst");
  elseif(MemeWarrior_OverpowerReady()) then
    CastSpellByName("Battle Stance");
    CastSpellByName("Overpower");
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) > 1.5 and UnitMana("player") > 40) then
    Pummelstring();
  end
  if(UnitMana("player") > 50) then
    CastSpellByName("Heroic Strike");
  end
end

function Bloodexecute()
  --if(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) <= 0) then
    --local b,c,d=UnitAttackPower("player");
    --local n = UnitMana("player");
    --if(((n>29) and (b+c+d)/0.45>(600+(n-10)*15))) then
      --CastSpellByName("Bloodthirst");
      --return;
    --end
  --end
  CastSpellByName("Execute");
end

function Pummelstring()
  if(MemeWarrior_GetCooldown(MemeWarrior_PummelID) > 0) then
    CastSpellByName("Hamstring");
  else
    CastSpellByName("Pummel");
  end
end

function HeroicCleave()
  if(GetNumRaidMembers() > 0) then
    local data, playerCount, threat100 = KLHTM_GetRaidData();
    if(math.floor(mod.table.raiddata[UnitName("player")] * 100 / threat100 + 0.5) > 90) then
     CastSpellByName("Cleave");
      return;
    end
  end
  CastSpellByName("Heroic Strike");
end

function MemeWarrior_IsBerserker()
	local _, _, active, _ = GetShapeshiftFormInfo(3);
	return active == 1
end

function MemeWarrior_OverpowerReady()
  return MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) > 1.5 and MemeWarrior_GetCooldown(MemeWarrior_WhirlwindID) > 1.5 and GetTime() - MemeWarrior_Overpower < 2 and MemeWarrior_GetCooldown(MemeWarrior_OverpowerID);
end
