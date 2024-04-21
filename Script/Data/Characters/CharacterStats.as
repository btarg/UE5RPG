UENUM()
enum ECharacterStat {
    MaxHP,
    MaxSP,
    Strength,
    Defense,
    Evasion,
    Vitality
}

struct FCharacterStatEntry {
    UPROPERTY()
    ECharacterStat StatKey;

    UPROPERTY()
    float StatValue;
}

struct FCharacterStats {
    UPROPERTY()
    TArray<FCharacterStatEntry> Stats;
}

struct FStatModifier {
    UPROPERTY()
    FString Name;

    UPROPERTY()
    FString Description;

    UPROPERTY()
    TMap<ECharacterStat, float> StatMultipliers;

    UPROPERTY()
    int32 TurnDuration;

    UPROPERTY()
    bool bCanStack;
}