UENUM()
enum ESkillType {
    ST_Damage,
    ST_Heal,
    ST_Modifier
}

struct FSkill {
    UPROPERTY()
    FString Name;
    // Description that appears in the UI
    UPROPERTY()
    FString Description;
    // Type of skill: damage, heal, or modifier
    UPROPERTY()
    ESkillType Type;
    // If true, can be junctioned to a stat
    UPROPERTY()
    bool bCanBeJunctioned;

    UPROPERTY()
    TSubclassOf<UDamageType> DamageType;
    // Damage to apply if the skill is ST_DAMAGE
    UPROPERTY(Category = "Damage skills")
    int32 MinDamage;
    UPROPERTY(Category = "Damage skills")
    int32 MaxDamage;

    // Chance to crit (0-1)
    UPROPERTY(Category = "Damage skills")
    float32 CritChance;

    // Cost in SP or HP
    UPROPERTY()
    int32 Cost;
    // If true, cost is taken from HP instead of SP
    UPROPERTY()
    bool bCostsHP;

    // If both are false, can only target self  
    UPROPERTY()
    bool bCanTargetAllies;
    UPROPERTY()
    bool bCanTargetEnemies;

    // stat modifier to apply if skill is ST_MODIFIER
    UPROPERTY(Category = "Stat Modifier")
    FName StatModifierToApply;
    // Chance to apply the stat modifier (0-1)
    UPROPERTY(Category = "Stat Modifier")
    float StatModifierApplicationChance;
    // stat modifier to apply permanently while junctioned
    UPROPERTY(Category = "Stat Modifier")
    FStatModifier JunctionedStatModifier;
}