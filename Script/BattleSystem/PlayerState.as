class ARPGPlayerStateBase : APlayerState {

    UPROPERTY(BlueprintReadOnly)
    TArray<TSubclassOf<APlayerUnitBase>> Party;


    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Print("ARPGPlayerState BeginPlay");
    }

    UFUNCTION()
    void TestFunction()
    {
        Print("TestFunction");
    }
}