class AEnemyUnitBase : AUnitBase {
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();
    }
    UFUNCTION(BlueprintOverride)
    void StartUnitTurn()
    {
        Print("Enemy Unit Turn");
        Super::StartUnitTurn();
    }
}