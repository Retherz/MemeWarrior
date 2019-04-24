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
  if(not MemeWarrior_OverpowerReady(0) and not MemeWarrior_IsBerserker()) then
    CastSpellByName("Berserker Stance");
  end
  if(UnitHealth("target") <= 20) then
    Bloodexecute();
    return;
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) <= 0) then
    CastSpellByName("Bloodthirst");
  elseif(MemeWarrior_GetCooldown(MemeWarrior_WhirlwindID) <= 0) then
    CastSpellByName("Whirlwind");
  elseif(MemeWarrior_OverpowerReady(0)) then
    CastSpellByName("Battle Stance");
    CastSpellByName("Overpower");
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) > 1.5 and UnitMana("player") > 40) then
    CastSpellByName("Hamstring");
  end
  if(UnitMana("player") > 50) then
    HeroicCleave();
  end
end

function MemeWarrior_SoftRock()
  if(not MemeWarrior_OverpowerReady(1) and not MemeWarrior_IsBerserker()) then
    CastSpellByName("Berserker Stance");
  end
  if(UnitHealth("target") <= 20) then
    Bloodexecute();
    return;
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) <= 0) then
    CastSpellByName("Bloodthirst");
  elseif(MemeWarrior_OverpowerReady(0)) then
    CastSpellByName("Battle Stance");
    CastSpellByName("Overpower");
  elseif(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) > 1.5 and UnitMana("player") > 60) then
    CastSpellByName("Hamstring");
  end
  if(UnitMana("player") > 50) then
  CastSpellByName("Heroic Strike");
  end
end

function Bloodexecute()
  if(MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) <= 0) then
    local b,c,d=UnitAttackPower("player");
    local n = UnitMana("player");
    if(((n>29) and (b+c+d)/0.45>(600+(n-10)*15))) then
      CastSpellByName("Bloodthirst");
      return;
    end
  end
  CastSpellByName("Execute");
end

function HeroicCleave()
  if(GetNumRaidMembers() > 0) then
    if(MemeThreat() > 90) then
     CastSpellByName("Cleave");
      return;
    end
  end
  CastSpellByName("Heroic Strike");
end

function MemeThreat()
  local userThreat = klhtm.table.raiddata[UnitName("player")];
  userThreat = userThreat == nil and 0 or userThreat;
  local _, _, threat100 = KLHTM_GetRaidData();
  return math.floor(userThreat * 100 / threat100 +0.5);
end

function MemeWarrior_IsBerserker()
	local _, _, active, _ = GetShapeshiftFormInfo(3);
	return active == 1
end

function MemeWarrior_OverpowerReady(b)
  local start, _ = GetSpellCooldown(MemeWarrior_HamstringID, "spell");
  start = start ~= 0 and GetTime() * 2 - start or GetTime();
  return MemeWarrior_GetCooldown(MemeWarrior_BloodthirstID) > (1.5 - b) and MemeWarrior_GetCooldown(MemeWarrior_WhirlwindID) > (1.5 - b) and start - MemeWarrior_Overpower < 3 and MemeWarrior_GetCooldown(MemeWarrior_OverpowerID) == 0;
end
