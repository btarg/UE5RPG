UENUM()
enum EAffinityType {
    Weak,
    Resist,
    Immune,
    Reflect,
    Absorb
}

struct FAffinity {
    UPROPERTY()
    TSubclassOf<UDamageType> DamageType;
    UPROPERTY()
    EAffinityType AffinityType;
}