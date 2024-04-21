UENUM()
enum ESkillResult {
    SR_Success,
    SR_Critical,
    SR_Resisted,
    SR_Evaded,
    SR_Absorbed,
    SR_Reflected,
    SR_Fail,
    SR_NotEnoughHP,
    SR_NotEnoughSP
}

class UCombatComponent : UActorComponent
{

    UFUNCTION()
    ESkillResult UseSkill(FName SkillName, AUnitBase& Target, bool bIsReflected = false)
    {
        AUnitBase User = Cast<AUnitBase>(GetOwner());
        if (User == nullptr) {
            return ESkillResult::SR_Fail;
        }

        if (bIsReflected) {
            Print("Reflected skill!");
        }
        Print(User.CurrentDisplayName + " uses " + SkillName.ToString() + " on " + Target.CurrentDisplayName + "!");

        UObject TableObject = LoadObject(UDataTable::StaticClass(), "/Game/Data/SkillTable.SkillTable");
        UDataTable SkillDataTable = Cast<UDataTable>(TableObject);
        FSkill Skill;
        bool found = SkillDataTable.FindRow(SkillName, Skill);
        if (!found) {
            // Skill doesn't exist
            return ESkillResult::SR_Fail;
        }
        if (Skill.bCostsHP && User.CurrentHP < Skill.Cost) {
            Print("Not enough HP!");
            return ESkillResult::SR_NotEnoughHP;
        }
        if (!Skill.bCostsHP && User.CurrentSP < Skill.Cost) {
            Print("Not enough SP!");
            return ESkillResult::SR_NotEnoughSP;
        }
        if (Skill.bCostsHP) {
            User.TakeDamage(Skill.Cost);
        } else {
            User.CurrentSP -= Skill.Cost;
        }

        ESkillResult Result = ESkillResult::SR_Success;
        
        // damage is used for both damaging and healing
        float Damage = Math::RandRange(Skill.MinDamage, Skill.MaxDamage);


        if (Skill.Type == ESkillType::ST_Damage) {
            // chance to evade the skill
            float EvadeRandom = Math::RandRange(0.0f, 1.0f);
            if (EvadeRandom <= Target.GetStat(ECharacterStat::Evasion)) {
                return ESkillResult::SR_Evaded;
            }
            float CritDamageMultiplier = 2.0f;

            // check target affinity to the type
            FAffinity Affinity = Target.GetAffinityByDamageType(Skill.DamageType);
            if (Affinity.DamageType != nullptr) {
                // ignore almighty damage as it ignores all resistances
                if (Affinity.DamageType != UAlmightyDamage::StaticClass()) {
                    if (Affinity.AffinityType == EAffinityType::Weak) {
                        Result = ESkillResult::SR_Critical;
                    } else if (Affinity.AffinityType == EAffinityType::Resist) {
                        // based on str stat
                        Damage *= (1 - Target.GetStat(ECharacterStat::Strength));
                        Result = ESkillResult::SR_Resisted;
                    } else if (Affinity.AffinityType == EAffinityType::Immune) {
                        Damage = 0;
                        Result = ESkillResult::SR_Fail;
                    } else if (Affinity.AffinityType == EAffinityType::Absorb) {
                        // heal the target
                        Target.Heal(Damage);
                        Result = ESkillResult::SR_Absorbed;
                    } else if (Affinity.AffinityType == EAffinityType::Reflect && !bIsReflected) {
                        // Reflect the damage back to the user only if not already reflected
                        Target.CombatComponent.UseSkill(SkillName, User, true);
                        return ESkillResult::SR_Reflected;
                    }
                }
            }

            if (Skill.CritChance > 0) {
                // Generate a random float between 0 and 1
                float CritRandom = Math::RandRange(0.0f, 1.0f);

                // If the random float is less than or equal to the skill's crit chance, it's a critical hit
                if (CritRandom <= Skill.CritChance && Result != ESkillResult::SR_Fail) {
                    Result = ESkillResult::SR_Critical;
                }
            }

            // We may have set this to critical if the target is weak to the damage type
            if (Result == ESkillResult::SR_Critical) {
                Damage *= CritDamageMultiplier;
            }

            Target.TakeDamage(Damage);

        }
        else if (Skill.Type == ESkillType::ST_Heal) {
            Target.CurrentHP += Damage;
        } else if (Skill.Type == ESkillType::ST_Modifier) {
            Target.AddStatModifierByName(Skill.StatModifier);
        }


        return Result;

    }
}