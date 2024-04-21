class UInventoryComponent : UActorComponent
{
    UPROPERTY()
    TArray<FName> LearnedSkills;
    UPROPERTY()
    TMap<FName, int32> DrawnSkills;
    UPROPERTY()
    TMap<FName, int32> Items;
    
}