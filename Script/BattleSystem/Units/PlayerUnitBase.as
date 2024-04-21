class APlayerUnitBase : AUnitBase {

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();
    }
    //override on start turn
    UFUNCTION(BlueprintOverride)
    void StartUnitTurn()
    {
        Print("Player Unit Turn");
        Super::StartUnitTurn();
    }
}