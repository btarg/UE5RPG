UENUM()
enum ESkillType {
    ST_Damage,
    ST_Heal,
    ST_Modifier
}

struct FSkill {
    UPROPERTY()
    FString Name; // friendly identifier
    UPROPERTY()
    FString Description; // description that appears in the UI
    UPROPERTY()
    ESkillType Type;
    UPROPERTY()
    bool bCanBeJunctioned; // if true, can be junctioned to a stat

    UPROPERTY()
    TSubclassOf<UDamageType> DamageType;
    // UPROPERTY(Category = "Damage skills")
    // int32 Damage; // damage to apply if the skill is ST_DAMAGE
    UPROPERTY(Category = "Damage skills")
    int32 MinDamage;
    UPROPERTY(Category = "Damage skills")
    int32 MaxDamage;

    UPROPERTY(Category = "Damage skills")
    float32 CritChance; // chance to crit (0-1)

    UPROPERTY()
    int32 Cost;
    UPROPERTY()
    bool bCostsHP; // if true, cost is taken from HP instead of MP

    // if both are false, can only target self  
    UPROPERTY()
    bool bCanTargetAllies;
    UPROPERTY()
    bool bCanTargetEnemies;

    UPROPERTY(Category = "Stat Modifier")
    FName StatModifierToApply; // stat modifier to apply if skill is ST_MODIFIER
    UPROPERTY(Category = "Stat Modifier")
    float StatModifierApplicationChance; // chance to apply the stat modifier (0-1)
    UPROPERTY(Category = "Stat Modifier")
    FStatModifier JunctionedStatModifier; // stat modifier to apply permanently while junctioned
}