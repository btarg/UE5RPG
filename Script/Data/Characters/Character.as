struct FCharacter {
    UPROPERTY()
    FString DisplayName;
    UPROPERTY()
    TArray<FSkill> Skills;
    UPROPERTY()
    FCharacterStats BaseStats;
    UPROPERTY()
    bool IsPlayerCharacter;
    
}